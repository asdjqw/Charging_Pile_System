#!/usr/bin/env bash
# ============================================================================
# 在单机上搭建 Hadoop 3.x 伪分布式环境（HDFS + YARN），并把原始数据存入 HDFS
# NameNode RPC 使用 8020，避免和一期 Qt TCP 默认 9000 冲突。
#
#   用法： bash deploy/setup_hadoop.sh
#   完成后： bash deploy/spark_submit.sh   # 用 Spark on YARN 重新计算
# ============================================================================
set -euo pipefail

HADOOP_VERSION="${HADOOP_VERSION:-3.3.6}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

INSTALL_DIR="${INSTALL_DIR:-$HOME}"
HADOOP_HOME="$INSTALL_DIR/hadoop-$HADOOP_VERSION"
DATA_DIR="${DATA_DIR:-$HOME/hadoop-data}"
JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
export JAVA_HOME

MIRROR="${HADOOP_MIRROR:-https://mirrors.aliyun.com/apache/hadoop/common}"

log() { printf '\033[36m[%s]\033[0m %s\n' "$(date '+%H:%M:%S')" "$*"; }

log "JAVA_HOME=$JAVA_HOME"
[[ -d "$HADOOP_HOME" ]] || {
  log "下载 Hadoop $HADOOP_VERSION（阿里云镜像）"
  wget -q --show-progress -O "$INSTALL_DIR/hadoop-$HADOOP_VERSION.tar.gz" \
    "$MIRROR/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz"
  log "解压"
  tar -xzf "$INSTALL_DIR/hadoop-$HADOOP_VERSION.tar.gz" -C "$INSTALL_DIR"
  rm -f "$INSTALL_DIR/hadoop-$HADOOP_VERSION.tar.gz"
}
ln -sfn "$HADOOP_HOME" "$INSTALL_DIR/hadoop"

CONF="$HADOOP_HOME/etc/hadoop"
mkdir -p "$DATA_DIR"/{name,data,tmp}

log "写入 Hadoop 配置"
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
  <property><name>yarn.nodemanager.resource.memory-mb</name><value>3072</value></property>
  <property><name>yarn.scheduler.maximum-allocation-mb</name><value>1536</value></property>
  <property><name>yarn.nodemanager.resource.cpu-vcores</name><value>2</value></property>
  <property><name>yarn.nodemanager.env-whitelist</name><value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value></property>
</configuration>
EOF

echo localhost > "$CONF/workers"

log "配置免密登录（localhost）与 PATH 环境变量"
[[ -f "$HOME/.ssh/id_rsa" ]] || ssh-keygen -t rsa -N '' -f "$HOME/.ssh/id_rsa" >/dev/null
grep -q "$(cat "$HOME/.ssh/id_rsa.pub")" "$HOME/.ssh/authorized_keys" 2>/dev/null || \
  cat "$HOME/.ssh/id_rsa.pub" >> "$HOME/.ssh/authorized_keys"
chmod 700 "$HOME/.ssh" && chmod 600 "$HOME/.ssh/authorized_keys"

ENV_FILE="$ROOT_DIR/deploy/hadoop_env.sh"
cat > "$ENV_FILE" <<EOF
# 由 deploy/setup_hadoop.sh 生成：Hadoop 环境变量
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
EOF
# shellcheck disable=SC1090
source "$ENV_FILE"

if [[ ! -d "$DATA_DIR/name/current" ]]; then
  log "格式化 NameNode"
  hdfs namenode -format -force -nonInteractive >/dev/null
fi

log "启动 HDFS 与 YARN"
hdfs --daemon start namenode
hdfs --daemon start datanode
yarn --daemon start resourcemanager
yarn --daemon start nodemanager
sleep 8
jps

log "上传原始数据到 HDFS"
hdfs dfs -mkdir -p /data/charging/raw
hdfs dfs -put -f data/raw/*.csv /data/charging/raw/
hdfs dfs -ls /data/charging/raw

log "完成：HDFS http://localhost:9870 ，YARN http://localhost:8088"
