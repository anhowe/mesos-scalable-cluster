This Azure template creates an Apache Mesos cluster with Marathon, and Swarm on a configurable number of machines

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fanhowe%2Fmesos-scalable-cluster%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Once your cluster has been created you will have a resource group containing 3 parts:
1. a set of 1,3,5 masters in a master specific availability set.  Each master's SSH can be accessed via the public dns address at ports 2211..2215
2. a set of agents behind in an agent specific availability set.  The agent VMs must be accessed through the master, or jumpbox
3. if chosen, a jumpbox.  The jumpbox is based on https://github.com/anhowe/ubuntu-devbox and will take 1 hour to configure.  Visit https://github.com/anhowe/ubuntu-devbox to learn how to know when setup is completed, and then how to access the desktop.

![Image of mesos cluster on azure](https://raw.githubusercontent.com/anhowe/mesos-scalable-cluster/master/images/mesos.png)

You can see Mesos on port 5050, Marathon on port 8080, and Swarm on port 2375.

Below are the parameters that the template expects:

| Name   | Description    |
|:--- |:---|
| newStorageAccountNamePrefix  | Name for the Storage Account(s) where the Virtual Machine's disks will be placed.  If the storage account does not aleady exist in this Resource Group it will be created. |
| adminPassword  | Password for the Virtual Machines  |
| dnsNameForContainerServicePublicIP  | Unique DNS Name for the Public IP used to access the master Virtual Machines. |
| dnsNameForJumpboxPublicIP  | Unique DNS Name for the Public IP used to access the jumpbox. |
| agentCount | the number of agent VMs |
| masterCount | the number of master VMs |
| jumpboxCount | the number of jumpbox VMs |
| masterConfiguration | specify "masters-are-agents" to have the master nodes act as agents and specify "masters-are-not-agents" to ensure the master nodes are not running as agents |
| agentVMSize | the size of the agent VMs |
| masterVMSize | the size of the master VMs |
| jumpboxVMSize | the size of the jumpbox VMs |
| clusterPrefix | a two character prefix to identify the cluster |
