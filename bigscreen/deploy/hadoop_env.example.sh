# Hadoop 环境变量模板：复制为 deploy/hadoop_env.sh 后按实际安装路径修改
# （deploy/spark_submit.sh 与 deploy/fetch_from_hdfs.sh 会自动加载该文件）

# 运行 Spark 3.5 需要 Java 8u371+/11/17；Hadoop 3.x 自身可用 Java 8
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/opt/module/hadoop-3.2.1
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

# Hadoop 3.x 伪分布式下启动脚本需要的用户变量（保持与当前登录用户一致）
export HDFS_NAMENODE_USER=$(id -un)
export HDFS_DATANODE_USER=$(id -un)
export HDFS_SECONDARYNAMENODE_USER=$(id -un)
export YARN_RESOURCEMANAGER_USER=$(id -un)
export YARN_NODEMANAGER_USER=$(id -un)

# 数据在 HDFS 上的存放目录（与 spark_submit.sh 中的变量保持一致）
export LOCAL_RAW=data/raw_expanded
export HDFS_RAW=/data/charging/raw_expanded
export HDFS_WAREHOUSE=/data/charging/warehouse
export HDFS_ADS=/data/charging/ads
