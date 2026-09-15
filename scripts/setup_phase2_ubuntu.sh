#!/usr/bin/env bash
# ============================================================================
# 充电桩二期环境一键安装（Ubuntu 22.04）
#
# 会安装并配好：Java 11、MySQL、Python 虚拟环境、PySpark、Hadoop 3.3.6 伪分布式、
# Flask 大屏、预置分析结果。HDFS RPC 使用 8020，不占用 Qt 默认 TCP 9000。
#
# 在虚拟机执行（共享盘无执行权限时用 bash 调用即可）：
#   bash /mnt/hgfs/Small_s3/Charge_pile/scripts/setup_phase2_ubuntu.sh
#
# 可选环境变量：
#   SKIP_HADOOP=1     不装 Hadoop
#   SKIP_PYSPARK=1    不装 PySpark（只能看大屏，不能重算）
#   SKIP_FLASK=1      装完不自动启动大屏
#   RUN_SPARK=1       用本地 Spark 重算并覆盖 MySQL（默认不跑，用 sql 备份）
#
# 装好以后每天一键启动（含大屏 / ML / 一期后端）：
#   bash ~/start_charge_pile.sh
# ============================================================================
set -euo pipefail

if [[ "$(id -u)" -eq 0 ]]; then
  echo "请用普通用户执行（例如 bit），不要 sudo bash 整份脚本。需要时脚本会自己 sudo。"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC=""
for candidate in "$REPO_ROOT/bigscreen" "$REPO_ROOT/charging-bigscreen-export/charging-bigscreen-export"; do
  if [[ -f "$candidate/backend/app.py" ]]; then
    SRC="$candidate"
    break
  fi
done
[[ -n "$SRC" ]] || { echo "找不到 bigscreen/backend/app.py，当前仓库：$REPO_ROOT"; exit 1; }

RUNTIME="${CHARGING_SCREEN_HOME:-$HOME/charging-bigscreen}"
HADOOP_VERSION="${HADOOP_VERSION:-3.3.6}"
INSTALL_DIR="${HADOOP_INSTALL_DIR:-$HOME}"
HADOOP_HOME="$INSTALL_DIR/hadoop-$HADOOP_VERSION"
DATA_DIR="${HADOOP_DATA_DIR:-$HOME/hadoop-data}"
PIP_INDEX="${PIP_INDEX:-https://pypi.tuna.tsinghua.edu.cn/simple}"
HADOOP_MIRROR="${HADOOP_MIRROR:-https://mirrors.aliyun.com/apache/hadoop/common}"
PORT="${SERVER_PORT:-5000}"
DB_USER="${DB_USER:-charging}"
DB_PASSWORD="${DB_PASSWORD:-charging123}"
DB_NAME="${DB_NAME:-charging_screen}"
SKIP_HADOOP="${SKIP_HADOOP:-0}"
SKIP_PYSPARK="${SKIP_PYSPARK:-0}"
SKIP_FLASK="${SKIP_FLASK:-0}"
RUN_SPARK="${RUN_SPARK:-0}"

log()  { printf '\033[36m[%s]\033[0m %s\n' "$(date '+%H:%M:%S')" "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*"; }
die()  { printf '\033[31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

need_sudo() {
  command -v sudo >/dev/null 2>&1 || die "需要 sudo"
  sudo -n true 2>/dev/null || log "接下来会提示输入 sudo 密码"
}

detect_java_home() {
  if [[ -n "${JAVA_HOME:-}" && -x "$JAVA_HOME/bin/java" ]]; then
    echo "$JAVA_HOME"
    return
  fi
  local p
  for p in /usr/lib/jvm/java-11-openjdk-amd64 /usr/lib/jvm/java-17-openjdk-amd64; do
    if [[ -x "$p/bin/java" ]]; then
      echo "$p"
      return
    fi
  done
  if command -v java >/dev/null 2>&1; then
    dirname "$(dirname "$(readlink -f "$(command -v java)")")"
    return
  fi
  echo ""
}

# ---------------------------------------------------------------------------
log "仓库：$REPO_ROOT"
log "大屏源码：$SRC"
log "运行目录：$RUNTIME"
need_sudo

export DEBIAN_FRONTEND=noninteractive
log "[1/8] 安装系统包（Java / MySQL / Python / 工具）"
sudo apt-get update -y
sudo apt-get install -y \
  python3 python3-venv python3-pip \
  openjdk-11-jdk-headless \
  mysql-server mysql-client \
  rsync curl wget tar gzip unzip \
  openssh-client procps ca-certificates \
  net-tools iproute2

JAVA_HOME="$(detect_java_home)"
[[ -n "$JAVA_HOME" ]] || die "未找到 JAVA_HOME，请确认 openjdk-11-jdk-headless 已安装"
export JAVA_HOME
log "JAVA_HOME=$JAVA_HOME"
"$JAVA_HOME/bin/java" -version

if ! grep -q "$(hostname)" /etc/hosts 2>/dev/null; then
  log "写入 127.0.0.1 $(hostname) 到 /etc/hosts（Hadoop 需要主机名可解析）"
  echo "127.0.0.1 $(hostname)" | sudo tee -a /etc/hosts >/dev/null
fi

log "[2/8] 同步大屏代码到家目录（避开共享盘 noexec）"
mkdir -p "$RUNTIME"
rsync -a \
  --exclude '.venv' --exclude 'frontend/node_modules' --exclude '__pycache__' \
  --exclude 'config/database.env' --exclude 'deploy/hadoop_env.sh' \
  "$SRC/" "$RUNTIME/"
mkdir -p "$RUNTIME/frontend/dist" "$RUNTIME/logs" "$HOME/charging-bigscreen-logs"
if [[ -f "$REPO_ROOT/web/index.html" ]]; then
  rsync -a "$REPO_ROOT/web/" "$RUNTIME/frontend/dist/"
  log "已复制仓库 web/ 到 frontend/dist"
elif [[ ! -f "$RUNTIME/frontend/dist/index.html" ]]; then
  warn "没有现成前端产物。大屏接口仍可用，页面需稍后 npm run build"
fi
chmod +x "$RUNTIME/deploy/"*.sh 2>/dev/null || true

log "[3/8] 启动 MySQL 并导入大屏结果库"
sudo systemctl enable mysql >/dev/null 2>&1 || true
sudo systemctl start mysql
sleep 2
sudo mysql -e "SELECT 1" >/dev/null || die "MySQL 未能以 sudo mysql 登录（Ubuntu auth_socket）"
if [[ -f "$RUNTIME/sql/charging_screen.sql" ]]; then
  log "导入 $RUNTIME/sql/charging_screen.sql（可能 1～2 分钟）"
  sudo mysql < "$RUNTIME/sql/charging_screen.sql"
else
  warn "未找到 SQL 备份，只建空库"
  sudo mysql -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` DEFAULT CHARSET utf8mb4;"
fi
sudo mysql <<SQL
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL
cat > "$RUNTIME/config/database.env" <<EOF
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME
DATA_SOURCE=mysql
CACHE_TTL=30
EOF
log "MySQL 库 $DB_NAME 账号 $DB_USER 已就绪"

log "[4/8] Python 虚拟环境与依赖"
if [[ ! -x "$RUNTIME/.venv/bin/python" ]]; then
  python3 -m venv "$RUNTIME/.venv"
fi
"$RUNTIME/.venv/bin/python" -m pip install -U pip -i "$PIP_INDEX"
"$RUNTIME/.venv/bin/pip" install -r "$RUNTIME/backend/requirements.txt" -i "$PIP_INDEX"
if [[ "$SKIP_PYSPARK" != "1" ]]; then
  log "安装 PySpark 3.5.3（体积较大，请等待）"
  "$RUNTIME/.venv/bin/pip" install "pyspark==3.5.3" pandas==2.2.3 -i "$PIP_INDEX"
fi

if [[ "$RUN_SPARK" == "1" ]]; then
  log "本地 Spark 重算（会覆盖刚才导入的 MySQL 数据）"
  export PYSPARK_PYTHON="$RUNTIME/.venv/bin/python"
  export PYSPARK_DRIVER_PYTHON="$PYSPARK_PYTHON"
  ( cd "$RUNTIME" && .venv/bin/python spark/jobs/run_all.py --raw data/raw )
  ( cd "$RUNTIME" && .venv/bin/python spark/jobs/load_mysql.py )
fi

if [[ "$SKIP_HADOOP" != "1" ]]; then
  log "[5/8] 安装 Hadoop $HADOOP_VERSION 伪分布式（RPC :8020，避开 Qt :9000）"
  if [[ ! -d "$HADOOP_HOME" ]]; then
    tarball="$INSTALL_DIR/hadoop-$HADOOP_VERSION.tar.gz"
    url="$HADOOP_MIRROR/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz"
    alt="https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz"
    log "下载 $url"
    if ! wget -q --show-progress -O "$tarball" "$url"; then
      warn "镜像失败，改试 Apache 归档"
      wget -q --show-progress -O "$tarball" "$alt"
    fi
    tar -xzf "$tarball" -C "$INSTALL_DIR"
    rm -f "$tarball"
  fi
  ln -sfn "$HADOOP_HOME" "$INSTALL_DIR/hadoop"
  mkdir -p "$DATA_DIR"/{name,data,tmp}
  CONF="$HADOOP_HOME/etc/hadoop"

  mem_mb="$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)"
  yarn_mb=$((mem_mb * 40 / 100))
  [[ "$yarn_mb" -lt 1536 ]] && yarn_mb=1536
  [[ "$yarn_mb" -gt 3072 ]] && yarn_mb=3072
  alloc_mb=$((yarn_mb / 2))
  [[ "$alloc_mb" -lt 1024 ]] && alloc_mb=1024
  log "本机内存 ${mem_mb}MB，YARN NodeManager 分配 ${yarn_mb}MB"

  cat > "$CONF/hadoop-env.sh" <<EOF
export JAVA_HOME=$JAVA_HOME
export HADOOP_HOME=$HADOOP_HOME
export HDFS_NAMENODE_USER=$(id -un)
export HDFS_DATANODE_USER=$(id -un)
export HDFS_SECONDARYNAMENODE_USER=$(id -un)
export YARN_RESOURCEMANAGER_USER=$(id -un)
export YARN_NODEMANAGER_USER=$(id -un)
EOF

  cat > "$CONF/core-site.xml" <<EOF
<?xml version="1.0"?>
<configuration>
  <property><name>fs.defaultFS</name><value>hdfs://localhost:8020</value></property>
  <property><name>hadoop.tmp.dir</name><value>$DATA_DIR/tmp</value></property>
  <property><name>io.file.buffer.size</name><value>131072</value></property>
</configuration>
EOF

  cat > "$CONF/hdfs-site.xml" <<EOF
<?xml version="1.0"?>
<configuration>
  <property><name>dfs.replication</name><value>1</value></property>
  <property><name>dfs.namenode.name.dir</name><value>file://$DATA_DIR/name</value></property>
  <property><name>dfs.datanode.data.dir</name><value>file://$DATA_DIR/data</value></property>
  <property><name>dfs.namenode.http-address</name><value>localhost:9870</value></property>
  <property><name>dfs.permissions.enabled</name><value>false</value></property>
  <property><name>dfs.datanode.max.transfer.threads</name><value>4096</value></property>
</configuration>
EOF

  cat > "$CONF/mapred-site.xml" <<EOF
<?xml version="1.0"?>
<configuration>
  <property><name>mapreduce.framework.name</name><value>yarn</value></property>
  <property><name>mapreduce.application.classpath</name><value>\$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:\$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value></property>
</configuration>
EOF

  cat > "$CONF/yarn-site.xml" <<EOF
<?xml version="1.0"?>
<configuration>
  <property><name>yarn.resourcemanager.hostname</name><value>localhost</value></property>
  <property><name>yarn.resourcemanager.webapp.address</name><value>localhost:8088</value></property>
  <property><name>yarn.nodemanager.aux-services</name><value>mapreduce_shuffle</value></property>
  <property><name>yarn.nodemanager.resource.memory-mb</name><value>$yarn_mb</value></property>
  <property><name>yarn.scheduler.maximum-allocation-mb</name><value>$alloc_mb</value></property>
  <property><name>yarn.nodemanager.resource.cpu-vcores</name><value>2</value></property>
  <property><name>yarn.nodemanager.env-whitelist</name><value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value></property>
</configuration>
EOF
  echo localhost > "$CONF/workers"

  if [[ ! -f "$HOME/.ssh/id_rsa" ]]; then
    ssh-keygen -t rsa -N '' -f "$HOME/.ssh/id_rsa" >/dev/null
  fi
  mkdir -p "$HOME/.ssh"
  grep -q "$(cat "$HOME/.ssh/id_rsa.pub")" "$HOME/.ssh/authorized_keys" 2>/dev/null || \
    cat "$HOME/.ssh/id_rsa.pub" >> "$HOME/.ssh/authorized_keys"
  chmod 700 "$HOME/.ssh"
  chmod 600 "$HOME/.ssh/authorized_keys"
  ssh-keyscan -H localhost 127.0.0.1 2>/dev/null >> "$HOME/.ssh/known_hosts" || true

  cat > "$RUNTIME/deploy/hadoop_env.sh" <<EOF
# 由 scripts/setup_phase2_ubuntu.sh 生成
export JAVA_HOME=$JAVA_HOME
export HADOOP_HOME=$INSTALL_DIR/hadoop
export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop
export HADOOP_MAPRED_HOME=\$HADOOP_HOME
export PATH=\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH
export HDFS_NAMENODE_USER=\$(id -un)
export HDFS_DATANODE_USER=\$(id -un)
export HDFS_SECONDARYNAMENODE_USER=\$(id -un)
export YARN_RESOURCEMANAGER_USER=\$(id -un)
export YARN_NODEMANAGER_USER=\$(id -un)
export HDFS_RAW=/data/charging/raw
export HDFS_WAREHOUSE=/data/charging/warehouse
export HDFS_ADS=/data/charging/ads
export PYSPARK_PYTHON=$RUNTIME/.venv/bin/python
export PYSPARK_DRIVER_PYTHON=$RUNTIME/.venv/bin/python
EOF

  # shellcheck disable=SC1091
  source "$RUNTIME/deploy/hadoop_env.sh"

  if [[ ! -d "$DATA_DIR/name/current" ]]; then
    log "格式化 NameNode"
    hdfs namenode -format -force -nonInteractive >/dev/null
  fi

  log "启动 HDFS + YARN"
  hdfs --daemon start namenode
  hdfs --daemon start datanode
  yarn --daemon start resourcemanager
  yarn --daemon start nodemanager

  ok_hdfs=0
  for _ in $(seq 1 40); do
    if hdfs dfs -ls / >/dev/null 2>&1; then
      ok_hdfs=1
      break
    fi
    sleep 2
  done
  [[ "$ok_hdfs" == "1" ]] || die "HDFS 未就绪，请查看 NameNode 日志：$HADOOP_HOME/logs"

  log "上传原始 CSV 到 HDFS /data/charging/raw"
  hdfs dfs -mkdir -p /data/charging/raw /data/charging/warehouse /data/charging/ads
  hdfs dfs -put -f "$RUNTIME"/data/raw/*.csv /data/charging/raw/
  hdfs dfs -ls /data/charging/raw
  jps || true
else
  log "[5/8] 跳过 Hadoop（SKIP_HADOOP=1）"
fi

log "[6/8] 写入环境脚本 ~/.charge_phase2_env.sh"
cat > "$HOME/charge_phase2_env.sh" <<EOF
# 充电桩二期：打开新终端后 source ~/charge_phase2_env.sh
export JAVA_HOME=$JAVA_HOME
export CHARGE_PILE_PORT="\${CHARGE_PILE_PORT:-9000}"
export CHARGING_SCREEN_HOME="$RUNTIME"
export CHARGING_SCREEN_VENV="$RUNTIME/.venv"
export CHARGING_ML_VENV="\$HOME/charging-ml-venv"
export CHARGE_PILE_ML_URL="\${CHARGE_PILE_ML_URL:-http://127.0.0.1:5010}"
if [[ -f "$RUNTIME/deploy/hadoop_env.sh" ]]; then
  # shellcheck disable=SC1090
  source "$RUNTIME/deploy/hadoop_env.sh"
fi
EOF
MARKER="# >>> charge-pile-phase2"
if [[ -f "$HOME/.bashrc" ]] && ! grep -q "$MARKER" "$HOME/.bashrc"; then
  {
    echo "$MARKER"
    echo "[[ -f \$HOME/charge_phase2_env.sh ]] && source \$HOME/charge_phase2_env.sh"
    echo "# <<< charge-pile-phase2"
  } >> "$HOME/.bashrc"
  log "已追加到 ~/.bashrc，新开终端会自动带上 Hadoop/Java"
fi

if command -v ufw >/dev/null 2>&1 && sudo ufw status 2>/dev/null | grep -qi active; then
  log "[7/8] 防火墙已开启，放行大屏与 Hadoop Web"
  sudo ufw allow 5000/tcp || true
  sudo ufw allow 5010/tcp || true
  sudo ufw allow 9870/tcp || true
  sudo ufw allow 8088/tcp || true
else
  log "[7/8] 防火墙未启用，跳过 ufw"
fi

log "[8/8] 机器学习查询环境（仅 Flask，不下载模型）"
if [[ ! -x "$HOME/charging-ml-venv/bin/python" ]]; then
  python3 -m venv "$HOME/charging-ml-venv"
fi
if ! "$HOME/charging-ml-venv/bin/python" -c "import flask" 2>/dev/null; then
  "$HOME/charging-ml-venv/bin/python" -m pip install -U pip -i "$PIP_INDEX" >/dev/null
  "$HOME/charging-ml-venv/bin/pip" install "Flask>=3.0" -i "$PIP_INDEX"
fi

log "启动 Flask 大屏"
if [[ "$SKIP_FLASK" != "1" ]]; then
  SERVER_PORT="$PORT" bash "$RUNTIME/deploy/phase2_services.sh" start
else
  warn "SKIP_FLASK=1，未启动大屏。之后执行 bash ~/start_charge_pile.sh"
fi

IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
echo
echo "================ 二期环境安装完成 ================"
echo "  大屏:     http://127.0.0.1:${PORT}/"
echo "            http://${IP:-虚机IP}:${PORT}/"
echo "  健康检查: curl -s http://127.0.0.1:${PORT}/api/health"
echo "  HDFS UI:  http://127.0.0.1:9870"
echo "  YARN UI:  http://127.0.0.1:8088"
echo "  HDFS:     hdfs dfs -ls /data/charging"
echo
bash "$REPO_ROOT/scripts/install_start_shortcut.sh"

echo "  以后每次登录一键启动（大屏 + ML + 一期后端 + 已编译的客户端）："
echo "    bash ~/start_charge_pile.sh"
echo "  只起后台："
echo "    bash ~/start_charge_pile.sh --no-gui"
echo "  需要 HDFS/YARN："
echo "    bash ~/start_charge_pile.sh --hadoop"
echo "  停止 / 状态："
echo "    bash ~/start_charge_pile.sh stop"
echo "    bash ~/start_charge_pile.sh status"
echo
echo "  只启动大屏也可以："
echo "    bash ~/charging-bigscreen/deploy/phase2_services.sh start"
echo
echo "  一期 Qt Creator 不用改：Hadoop 占用 8020，TCP 仍可用 9000。"
echo "  机器学习查询服务只装 Flask；3GB 模型按 ml/README.md 另下。"
echo "=================================================="
