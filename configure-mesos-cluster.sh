#!/bin/bash

###########################################################
# Configure Mesos One Box
#
# This installs the following components
# - zookeepr
# - mesos master
# - marathon
# - mesos agent
###########################################################

#############
# Parameters
#############

MASTERCOUNT=$1
MASTERMODE=$2
VMNAME=`hostname`
VMNUMBER=`echo $VMNAME | sed 's/.*[^0-9]\([0-9]\+\)*$/\1/'`
VMPREFIX=`echo $VMNAME | sed 's/\(.*[^0-9]\)*[0-9]\+$/\1/'`

echo "Master Count: $MASTERCOUNT"
echo "Master Mode: $MASTERMODE"
echo "vmname: $VMNAME"
echo "VMNUMBER: $VMNUMBER, VMPREFIX: $VMPREFIX"

###################
# Common Functions
###################

ismaster ()
{
  if [ "$VMNUMBER" -le "$MASTERCOUNT" ]
  then
    return 0
  else
    return 1
  fi
}
if ismaster ; then
  echo "this node is a master"
fi

isagent()
{
  if ismaster ; then
    if [ "$MASTERMODE" == "masters-are-agents" ]
    then
      return 0
    else
      return 1
    fi
  else
    return 0
  fi
}
if isagent ; then
  echo "this node is an agent"
fi

zkconfig()
{
  postfix="$1"
  zkconfig="zk://"
  for i in `seq 1 $MASTERCOUNT` ;
  do
    if [ "$i" -gt "1" ]
    then
      zkconfig = "${zkconfig},"
    fi
    zkconfig = "${zkconfig}${VMPREFIX}${i}:2181"
  done
  zkconfig = "${zkconfig}/${postfix}"
  echo $zkconfig
}

##################
# Install Mesos
##################

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
sudo apt-get -y update
if ismaster ; then
  sudo apt-get -y --force-yes install mesosphere
else
  sudo apt-get -y --force-yes install mesos
fi

#########################
# Configure ZooKeeper
#########################

zkmesosconfig=$(zkconfig "mesos")
echo $zkmesosconfig | sudo tee /etc/mesos/zk

if ismaster ; then
  echo $VMNUMBER | sudo tee /etc/zookeeper/conf/myid
  for i in `seq 1 $MASTERCOUNT` ;
  do
    echo "server.${i}=${VMPREFIX}${i}:2888:3888" | sudo tee -a /etc/zookeeper/conf/zoo.cfg
  done
fi

#########################
# Configure Mesos Master
#########################
if ismaster ; then
  quorum=`expr $MASTERCOUNT / 2 + 1`
  echo $quorum | sudo tee /etc/mesos-master/quorum
  hostname -i | sudo tee /etc/mesos-master/ip
  hostname | sudo tee /etc/mesos-master/hostname
  sudo mkdir -p /etc/marathon/conf
  sudo cp /etc/mesos-master/hostname /etc/marathon/conf
  sudo cp /etc/mesos/zk /etc/marathon/conf/master
  zkmarathonconfig=$(zkconfig "marathon")
  echo $zkmarathonconfig | sudo tee /etc/marathon/conf/zk
  echo 'Mesos Cluster' | sudo tee /etc/mesos-master/cluster
fi

#########################
# Configure Mesos Agent
#########################
if isagent ; then
  hostname -i | sudo tee /etc/mesos-slave/ip
  hostname | sudo tee /etc/mesos-slave/hostname
fi

##############################################
# configure init rules restart all processes
##############################################
if ismaster ; then
  sudo restart zookeeper
  sudo start mesos-master
  sudo start marathon
else
  echo manual | sudo tee /etc/init/zookeeper.override
  sudo stop zookeeper
  echo manual | sudo tee /etc/init/mesos-master.override
  sudo-stop mesos-master
fi

if isagent ; then
  sudo start mesos-slave
else
  echo manual | sudo tee /etc/init/mesos-slave.override
  sudo stop mesos-slave
fi
