This is a sample Azure template to create an Apache Mesos cluster with Marathon on a configurable number of machines

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fanhowe%2Fmesos-scalable-cluster%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Once your cluster has been created you will have a resource group containing a
single VM acting as a mesos master and a mesos agent.

You can see Mesos on port 5050 and Marathon on port 8080

Below are the parameters that the template expects:

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Name for the Storage Account where the Virtual Machine's disks will be placed.If the storage account does not aleady exist in this Resource Group it will be created. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machines  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the master Virtual Machine. |
| masterConfiguration | specify "masters-are-agents" to have the master nodes act as agents and specify "masters-are-not-agents" to ensure the master nodes are not running as agents |
| nodeCount | specify the node count for the cluster |
| masterCount | specify the master count for the cluster |
