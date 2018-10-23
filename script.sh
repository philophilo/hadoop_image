#/bin/bash

# update
sudo apt-get update

#install java
sudo apt-get install -y default-jdk
which java
jps

sudo apt-get install ssh

#creating ssh for hduser
sudo useradd -m -d /home/hduser -s /bin/bash hduser
#GROUP=$(id -g -n $USER)
#ssh-keygen -t dsa -N "" -f ~/.ssh/id_dsa
#cat .ssh/id_dsa.pub>>.ssh/authorized_keys
#chown -R $USER:$GROUP /home/$USER/.ssh/
#chmod 700 /home/$USER/.ssh/
#chmod 600 /home/$USER/.ssh/authorized_keys

# add user and usergroup
sudo addgroup hadoop
sudo usermod -aG sudo hduser
#sudo gpasswd -a hduser sudo
sudo adduser hduser hadoop


# setup ssh
sudo su - hduser -c "ssh-keygen -t rsa -N \"\" -f ~/.ssh/id_rsa -q"
sudo su - hduser -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
sudo su - hduser -c "chmod 0600 ~/.ssh/authorized_keys"

#test ssh
#ssh localhost -Y
#bash -c exit

# download hadoop
sudo su - hduser -c "wget https://archive.apache.org/dist/hadoop/core/hadoop-3.0.0/hadoop-3.0.0.tar.gz"
# unzip hadoop
sudo su - hduser -c "tar xvzf hadoop-3.0.0.tar.gz"
#
# hadoop configuration
sudo mkdir -p /usr/local/hadoop
sudo chown -R hduser:hadoop /usr/local/hadoop
#sudo su - hduser -c "cd /home/hduser/hadoop-3.0.0/"
sudo su - hduser -c "mv /home/hduser/hadoop-3.0.0/* /usr/local/hadoop"
sudo su - hduser -c "cd && ls -la && pwd"


##setting up confuguration files
main_home=$HOME
sudo su - hduser -c "cat ${main_home}/hadoop_bashrc >> ~/.bashrc"
sudo su - hduser -c ". ~/.bashrc"

## configuring hadoop env
echo "----------hadoop env----------"
sudo su - hduser -c "sed -i -e \"s|# export JAVA_HOME.*$|export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64|g\" /usr/local/hadoop/etc/hadoop/hadoop-env.sh"

# configure core-site file
echo "----------core-site----------"
sudo su - hduser -c "mkdir -p /app/hadoop/tmp"
sudo chown hduser:hadoop /app/hadoop/tmp
sudo su - hduser -c "sed -i \"N;s|<configuration>\n</configuration>||g\" /usr/local/hadoop/etc/hadoop/core-site.xml"
sudo su - hduser -c "cat ${main_home}/core-site >> /usr/local/hadoop/etc/hadoop/core-site.xml"

# configure hdfs-site
# create namenode and datanode directories
echo "----------hdfs-site----------"
sudo mkdir -p /usr/local/hadoop_store/hdfs/namenode
sudo mkdir -p /usr/local/hadoop_store/hdfs/datanode
sudo chown -R hduser:hadoop /usr/local/hadoop_store
sudo su - hduser -c "sed -i -n -e '/<configuration>/,/<\/configuration>/!p' /usr/local/hadoop/etc/hadoop/hdfs-site.xml"
sudo su - hduser -c "cat ${main_home}/hdfs-site >> /usr/local/hadoop/etc/hadoop/hdfs-site.xml"

# configure yarn-site
echo "----------yarn-site----------"
sudo su - hduser -c "sed -i -n -e '/<configuration>/,/<\/configuration>/!p' /usr/local/hadoop/etc/hadoop/yarn-site.xml"
sudo su - hduser -c "cat ${main_home}/yarn-site >> /usr/local/hadoop/etc/hadoop/yarn-site.xml"

# Formart hadoop file system
sudo su - hduser -c "hadoop namenode -format"

# stop hadoop daemons
sudo su - hduser -c "/usr/local/hadoop/sbin/start-all.sh"

# start hadoop daemons
sudo su - hduser -c "/usr/local/hadoop/sbin/stop-all.sh"
