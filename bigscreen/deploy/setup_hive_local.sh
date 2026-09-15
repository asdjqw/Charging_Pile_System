#!/usr/bin/env bash
# 安装并配置单机 Hive 3.1.3 + MySQL Metastore，不覆盖系统 Hadoop。
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

HIVE_VERSION="${HIVE_VERSION:-3.1.3}"
HIVE_MIRROR="${HIVE_MIRROR:-https://repo.huaweicloud.com/apache/hive}"
HADOOP_CLIENT_VERSION="${HADOOP_CLIENT_VERSION:-3.3.6}"
HADOOP_MIRROR="${HADOOP_MIRROR:-https://repo.huaweicloud.com/apache/hadoop/common}"
CONNECTOR_VERSION="${CONNECTOR_VERSION:-8.4.0}"
RUNTIME_DIR="$ROOT_DIR/.runtime"
HIVE_DIST="$RUNTIME_DIR/apache-hive-${HIVE_VERSION}-bin"
HIVE_HOME="$RUNTIME_DIR/hive"
HIVE_CONF_DIR="$RUNTIME_DIR/hive-conf"
HIVE_LOG_DIR="$RUNTIME_DIR/hive-logs"
HIVE_PID_DIR="$RUNTIME_DIR/hive-pids"
HIVE_HADOOP_CONF_DIR="$RUNTIME_DIR/hive-hadoop-conf"
JAVA_HOME="${HIVE_JAVA_HOME:-}"
HIVE_DB_NAME="${HIVE_DB_NAME:-hive_metastore}"
HIVE_DB_USER="${HIVE_DB_USER:-hive}"
HIVE_DB_PASSWORD="${HIVE_DB_PASSWORD:-hive_meta_local}"
HIVE_SERVER2_PORT="${HIVE_SERVER2_PORT:-10000}"

detect_server_hadoop() {
  local p
  for p in \
    "${SERVER_HADOOP_HOME:-}" \
    "${HADOOP_HOME:-}" \
    "$HOME/hadoop" \
    "$HOME/hadoop-3.3.6" \
    /opt/hadoop \
    /opt/module/hadoop-3.2.1
  do
    [[ -n "$p" && -x "$p/bin/hadoop" ]] || continue
    readlink -f "$p"
    return 0
  done
  return 1
}

can_mysql_root() {
  mysql -uroot -e 'SELECT 1' >/dev/null 2>&1 && return 0
  sudo -n mysql -e 'SELECT 1' >/dev/null 2>&1 && return 0
  return 1
}

mysql_as_root() {
  if mysql -uroot -e 'SELECT 1' >/dev/null 2>&1; then
    mysql -uroot "$@"
  elif sudo -n mysql -e 'SELECT 1' >/dev/null 2>&1; then
    sudo mysql "$@"
  else
    echo "[ERROR] 无法以 root 连接 MySQL（需要 mysql -uroot 或免密 sudo mysql）"; return 1
  fi
}

[[ "$HIVE_DB_PASSWORD" =~ ^[A-Za-z0-9_.-]+$ ]] || {
  echo "[ERROR] HIVE_DB_PASSWORD 仅允许字母、数字、点、下划线和连字符"; exit 2;
}

if [[ -z "$JAVA_HOME" || ! -x "$JAVA_HOME/bin/java" ]]; then
  for p in \
    "${HIVE_JAVA_HOME:-}" \
    /usr/lib/jvm/java-8-openjdk-amd64 \
    "$HOME/jvm/jdk8" \
    "$HOME/jvm/jdk-8"
  do
    [[ -n "$p" && -x "$p/bin/java" ]] || continue
    JAVA_HOME="$p"
    break
  done
fi
[[ -x "${JAVA_HOME:-}/bin/java" ]] || {
  echo "[ERROR] 缺少 Java 8u371+。可安装 openjdk-8-jdk-headless，或把 JDK8 放到 \$HOME/jvm/jdk8"; exit 2;
}

SERVER_HADOOP_HOME="$(detect_server_hadoop)" || {
  echo "[ERROR] 缺少 Hadoop 服务端。请先装 Hadoop，或设置 SERVER_HADOOP_HOME"; exit 2;
}
if [[ -n "${SERVER_HADOOP_CONF_DIR:-}" && -f "$SERVER_HADOOP_CONF_DIR/core-site.xml" ]]; then
  :
elif [[ -f "$RUNTIME_DIR/hadoop-conf/core-site.xml" ]]; then
  SERVER_HADOOP_CONF_DIR="$RUNTIME_DIR/hadoop-conf"
elif [[ -f "$SERVER_HADOOP_HOME/etc/hadoop/core-site.xml" ]]; then
  SERVER_HADOOP_CONF_DIR="$SERVER_HADOOP_HOME/etc/hadoop"
else
  echo "[ERROR] 找不到 Hadoop core-site.xml"; exit 2
fi
HADOOP_DIST="$RUNTIME_DIR/hadoop-${HADOOP_CLIENT_VERSION}"
HADOOP_HOME="$RUNTIME_DIR/hadoop-client"
HADOOP_CONF_DIR="$SERVER_HADOOP_CONF_DIR"
echo "[INFO] Hadoop 服务端：$SERVER_HADOOP_HOME"
echo "[INFO] Hadoop 配置：$HADOOP_CONF_DIR"

mkdir -p "$RUNTIME_DIR" "$HIVE_CONF_DIR" "$HIVE_LOG_DIR" "$HIVE_PID_DIR" "$HIVE_HADOOP_CONF_DIR"

server_hadoop_ver="$("$SERVER_HADOOP_HOME/bin/hadoop" version 2>/dev/null | awk 'NR==1{print $2}')"
if [[ ! -d "$HADOOP_DIST" && "$server_hadoop_ver" == "$HADOOP_CLIENT_VERSION" ]]; then
  echo "[0/6] 复用本机 Hadoop $HADOOP_CLIENT_VERSION 作为 Hive 客户端"
  ln -sfn "$SERVER_HADOOP_HOME" "$HADOOP_DIST"
fi

if [[ ! -d "$HADOOP_DIST" ]]; then
  hadoop_archive="$RUNTIME_DIR/hadoop-${HADOOP_CLIENT_VERSION}.tar.gz"
  echo "[0/6] 下载 Hive 兼容的 Hadoop $HADOOP_CLIENT_VERSION 客户端"
  curl -fL -C - --retry 3 -o "$hadoop_archive" \
    "$HADOOP_MIRROR/hadoop-${HADOOP_CLIENT_VERSION}/hadoop-${HADOOP_CLIENT_VERSION}.tar.gz"
  curl -fsSL -o "$hadoop_archive.sha512" \
    "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_CLIENT_VERSION}/hadoop-${HADOOP_CLIENT_VERSION}.tar.gz.sha512"
  expected_sha512="$(awk '{print $NF}' "$hadoop_archive.sha512")"
  actual_sha512="$(sha512sum "$hadoop_archive" | awk '{print $1}')"
  [[ "$actual_sha512" == "$expected_sha512" ]] || { echo "[ERROR] Hadoop SHA-512 校验失败"; exit 1; }
  echo "$(basename "$hadoop_archive"): OK"
  tar -xzf "$hadoop_archive" -C "$RUNTIME_DIR"
fi
ln -sfn "$HADOOP_DIST" "$HADOOP_HOME"

if [[ ! -d "$HIVE_DIST" ]]; then
  archive="$RUNTIME_DIR/apache-hive-${HIVE_VERSION}-bin.tar.gz"
  echo "[1/6] 下载 Apache Hive $HIVE_VERSION"
  curl -fL -C - --retry 3 -o "$archive" \
    "$HIVE_MIRROR/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz"
  curl -fsSL -o "$archive.sha256" \
    "https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz.sha256"
  (cd "$RUNTIME_DIR" && sha256sum -c "$(basename "$archive.sha256")")
  tar -xzf "$archive" -C "$RUNTIME_DIR"
fi
ln -sfn "$HIVE_DIST" "$HIVE_HOME"

echo "[2/6] 安装 MySQL Connector/J $CONNECTOR_VERSION"
connector="$HIVE_DIST/lib/mysql-connector-j-${CONNECTOR_VERSION}.jar"
if [[ ! -f "$connector" ]]; then
  curl -fL --retry 3 -o "$connector" \
    "https://repo.maven.apache.org/maven2/com/mysql/mysql-connector-j/${CONNECTOR_VERSION}/mysql-connector-j-${CONNECTOR_VERSION}.jar"
fi
# Hive 3.1.3 的 Metastore 仍引用 commons-collections 3.x 包名，而发行包仅带 4.x。
collections="$HIVE_DIST/lib/commons-collections-3.2.2.jar"
if [[ ! -f "$collections" ]]; then
  curl -fL --retry 3 -o "$collections" \
    "https://repo.maven.apache.org/maven2/commons-collections/commons-collections/3.2.2/commons-collections-3.2.2.jar"
fi

echo "[3/6] 处理 Hive/Hadoop Guava 版本冲突"
find "$HIVE_DIST/lib" -maxdepth 1 -name 'guava-*.jar' -delete
cp "$(find "$HADOOP_HOME/share/hadoop/common/lib" -maxdepth 1 -name 'guava-*.jar' | head -1)" "$HIVE_DIST/lib/"

METASTORE_TYPE="${HIVE_METASTORE_DB_TYPE:-}"
if [[ -z "$METASTORE_TYPE" ]]; then
  if can_mysql_root; then METASTORE_TYPE=mysql; else METASTORE_TYPE=derby; fi
fi
if [[ "$METASTORE_TYPE" == "mysql" ]]; then
  JDBC_URL="jdbc:mysql://127.0.0.1:3306/${HIVE_DB_NAME}?createDatabaseIfNotExist=true&amp;useSSL=false&amp;allowPublicKeyRetrieval=true&amp;serverTimezone=Asia/Shanghai"
  JDBC_DRIVER="com.mysql.cj.jdbc.Driver"
  JDBC_USER="$HIVE_DB_USER"
  JDBC_PASSWORD="$HIVE_DB_PASSWORD"
else
  METASTORE_TYPE=derby
  JDBC_URL="jdbc:derby:;databaseName=${RUNTIME_DIR}/metastore_db;create=true"
  JDBC_DRIVER="org.apache.derby.jdbc.EmbeddedDriver"
  JDBC_USER="APP"
  JDBC_PASSWORD="mine"
fi
echo "[INFO] Metastore 存储：$METASTORE_TYPE"

echo "[4/6] 写入 Hive 配置"
cat > "$HIVE_CONF_DIR/hive-site.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property><name>javax.jdo.option.ConnectionURL</name><value>${JDBC_URL}</value></property>
  <property><name>javax.jdo.option.ConnectionDriverName</name><value>${JDBC_DRIVER}</value></property>
  <property><name>javax.jdo.option.ConnectionUserName</name><value>${JDBC_USER}</value></property>
  <property><name>javax.jdo.option.ConnectionPassword</name><value>${JDBC_PASSWORD}</value></property>
  <property><name>hive.metastore.uris</name><value>thrift://127.0.0.1:9083</value></property>
  <property><name>hive.metastore.warehouse.dir</name><value>/warehouse/tablespace/managed/hive</value></property>
  <property><name>hive.metastore.warehouse.external.dir</name><value>/warehouse/tablespace/external/hive</value></property>
  <property><name>hive.exec.scratchdir</name><value>/tmp/hive</value></property>
  <property><name>hive.exec.local.scratchdir</name><value>${RUNTIME_DIR}/hive-tmp</value></property>
  <property><name>hive.execution.engine</name><value>mr</value></property>
  <property><name>hive.server2.thrift.bind.host</name><value>127.0.0.1</value></property>
  <property><name>hive.server2.thrift.port</name><value>${HIVE_SERVER2_PORT}</value></property>
  <property><name>hive.server2.enable.doAs</name><value>false</value></property>
  <!-- 单机非 Kerberos 环境允许 HiveServer2 读取 Metastore 通知事件。 -->
  <property><name>hive.metastore.event.db.notification.api.auth</name><value>false</value></property>
  <property><name>hadoop.proxyuser.root.hosts</name><value>*</value></property>
  <property><name>hadoop.proxyuser.root.groups</name><value>*</value></property>
  <property><name>hive.metastore.schema.verification</name><value>true</value></property>
  <property><name>hive.cli.print.header</name><value>true</value></property>
</configuration>
EOF

cat > "$HIVE_CONF_DIR/hive-env.sh" <<EOF
export JAVA_HOME=$JAVA_HOME
export HADOOP_HOME=$HADOOP_HOME
export HADOOP_CONF_DIR=$HIVE_HADOOP_CONF_DIR
export HIVE_CONF_DIR=$HIVE_CONF_DIR
export HIVE_AUX_JARS_PATH=$connector
export HADOOP_CLIENT_OPTS="\${HADOOP_CLIENT_OPTS:-} -Djava.net.preferIPv4Stack=true -Dhive.log.dir=$HIVE_LOG_DIR"
EOF
# Hive 使用独立的客户端配置，避免 Hadoop 守护进程的 Java 17 配置覆盖 Hive 的 Java 8。
cp "$HADOOP_CONF_DIR/core-site.xml" "$HIVE_HADOOP_CONF_DIR/core-site.xml"
cp "$HADOOP_CONF_DIR/hdfs-site.xml" "$HIVE_HADOOP_CONF_DIR/hdfs-site.xml"
cp "$HADOOP_CONF_DIR/yarn-site.xml" "$HIVE_HADOOP_CONF_DIR/yarn-site.xml"
cp "$HIVE_CONF_DIR/hive-site.xml" "$HIVE_HADOOP_CONF_DIR/hive-site.xml"
[[ ! -f "$HADOOP_CONF_DIR/log4j.properties" ]] || \
  cp "$HADOOP_CONF_DIR/log4j.properties" "$HIVE_HADOOP_CONF_DIR/log4j.properties"
cat > "$HIVE_HADOOP_CONF_DIR/hadoop-env.sh" <<EOF
export JAVA_HOME=$JAVA_HOME
EOF

# Hadoop 3.5 守护进程继续使用 Java 17；Hive 3 MR 容器改用兼容的
# Hadoop 3.3.6 客户端类库和 Java 8，避开 JDK 9+ 的 ArrayListSubList 变更。
MR_ENV="JAVA_HOME=$JAVA_HOME,HADOOP_HOME=$HADOOP_HOME,HADOOP_COMMON_HOME=$HADOOP_HOME,HADOOP_HDFS_HOME=$HADOOP_HOME,HADOOP_MAPRED_HOME=$HADOOP_HOME,HADOOP_YARN_HOME=$HADOOP_HOME"
cat > "$HIVE_HADOOP_CONF_DIR/mapred-site.xml" <<EOF
<?xml version="1.0"?>
<configuration>
  <property><name>mapreduce.framework.name</name><value>yarn</value></property>
  <property><name>mapreduce.application.classpath</name><value>$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*</value></property>
  <property><name>mapreduce.map.env</name><value>$MR_ENV</value></property>
  <property><name>mapreduce.reduce.env</name><value>$MR_ENV</value></property>
  <property><name>yarn.app.mapreduce.am.env</name><value>$MR_ENV</value></property>
  <property><name>mapreduce.map.java.opts</name><value>-Xmx512m</value></property>
  <property><name>mapreduce.reduce.java.opts</name><value>-Xmx512m</value></property>
  <property><name>yarn.app.mapreduce.am.command-opts</name><value>-Xmx512m</value></property>
</configuration>
EOF

cat > "$ROOT_DIR/deploy/hive_env.sh" <<EOF
# 由 deploy/setup_hive_local.sh 生成，仅供当前机器使用。
source "$ROOT_DIR/deploy/hadoop_env.sh"
export JAVA_HOME=$JAVA_HOME
export HIVE_HOME=$HIVE_HOME
export HIVE_CONF_DIR=$HIVE_CONF_DIR
export HIVE_LOG_DIR=$HIVE_LOG_DIR
export HIVE_PID_DIR=$HIVE_PID_DIR
export HIVE_SERVER2_PORT=$HIVE_SERVER2_PORT
export HADOOP_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_CONF_DIR=$HIVE_HADOOP_CONF_DIR
export PATH=\$HIVE_HOME/bin:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH
export PYSPARK_PYTHON=$ROOT_DIR/.venv/bin/python
export PYSPARK_DRIVER_PYTHON=$ROOT_DIR/.venv/bin/python
EOF

export JAVA_HOME HADOOP_HOME HADOOP_CONF_DIR HIVE_HOME HIVE_CONF_DIR
export HIVE_AUX_JARS_PATH="$connector"

if [[ "$METASTORE_TYPE" == "mysql" ]]; then
  echo "[5/6] 创建 MySQL Metastore 库与本地账号"
  mysql_as_root <<EOF
CREATE DATABASE IF NOT EXISTS \`${HIVE_DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${HIVE_DB_USER}'@'127.0.0.1' IDENTIFIED BY '${HIVE_DB_PASSWORD}';
ALTER USER '${HIVE_DB_USER}'@'127.0.0.1' IDENTIFIED BY '${HIVE_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${HIVE_DB_NAME}\`.* TO '${HIVE_DB_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF
  if ! mysql -N -u"$HIVE_DB_USER" -p"$HIVE_DB_PASSWORD" -h127.0.0.1 "$HIVE_DB_NAME" \
    -e "SHOW TABLES LIKE 'VERSION'" | grep -q VERSION; then
    echo "[6/6] 初始化 Hive Metastore schema（MySQL）"
    "$HIVE_HOME/bin/schematool" -dbType mysql -initSchema --verbose
  else
    echo "[6/6] Hive Metastore schema 已存在，跳过初始化"
    "$HIVE_HOME/bin/schematool" -dbType mysql -info
  fi
else
  echo "[5/6] 无 MySQL root 权限，改用本地 Derby Metastore（仅本机；HiveServer2/Spark 走 thrift://9083）"
  echo "[6/6] 初始化 Hive Metastore schema（Derby）"
  if [[ -d "$RUNTIME_DIR/metastore_db" ]]; then
    "$HIVE_HOME/bin/schematool" -dbType derby -info || \
      "$HIVE_HOME/bin/schematool" -dbType derby -initSchema --verbose
  else
    "$HIVE_HOME/bin/schematool" -dbType derby -initSchema --verbose
  fi
fi

echo "[OK] Hive 安装完成：$HIVE_HOME"
echo "     Metastore：$METASTORE_TYPE"
echo "     HiveServer2 端口：$HIVE_SERVER2_PORT"
echo "     下一步：source deploy/hive_env.sh && bash deploy/start_hive_local.sh"
