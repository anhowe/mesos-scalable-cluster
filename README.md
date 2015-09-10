# Mesos cluster with Marathon and Swarm

This Azure template creates an Apache Mesos cluster with Marathon, and Swarm on a configurable number of machines

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fanhowe%2Fmesos-scalable-cluster%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Once your cluster has been created you will have a resource group containing 3 parts:

1. a set of 1,3,5 masters in a master specific availability set.  Each master's SSH can be accessed via the public dns address at ports 2211..2215

2. a set of agents behind in an agent specific availability set.  The agent VMs must be accessed through the master, or jumpbox

3. if chosen, a jumpbox.  The jumpbox is based on https://github.com/anhowe/ubuntu-devbox and will take 1 hour to configure.  Visit https://github.com/anhowe/ubuntu-devbox to learn how to know when setup is completed, and then how to access the desktop.

The following image is an example of a cluster with 1 jumpbox, 3 masters, and 3 agents:

![Image of mesos cluster on azure](https://raw.githubusercontent.com/anhowe/mesos-scalable-cluster/master/images/mesos.png)

You can see Mesos on port 5050, Marathon on port 8080, and Swarm on port 2375.  All VMs are on the same private subnet, 10.0.0.0/24, and fully accessible to each other.

# Cluster Walkthrough

This walk through is based the wonderful digital ocean tutorial: https://www.digitalocean.com/community/tutorials/how-to-configure-a-production-ready-mesosphere-cluster-on-ubuntu-14-04

1. Get your endpoints to cluster
 1. browse to https://portal.azure.com

 2. then click browse all, followed by "resource groups", and choose your resource group

 ![Image of mesos cluster on azure](https://raw.githubusercontent.com/anhowe/mesos-scalable-cluster/master/images/portal-resourcegroups.png)

 3. then expand your resources, and copy the dns names of your jumpbox (if chosen), and your NAT public ip addresses.

 ![Image of mesos cluster on azure](https://raw.githubusercontent.com/anhowe/mesos-scalable-cluster/master/images/portal-publicipaddresses.png)

2. Connect to your cluster
 1. linux jumpbox - start a VNC to the jumpbox using instructions https://github.com/anhowe/ubuntu-devbox.  The jumpbox takes an hour to configure.  If the desktop is not ready, you can tail /var/log/azure/firstinstall.log to watach installation.
 2. windows jumpbox - remote desktop to the windows jumpbox
 3. no jumpbox - SSH to port 2211 on your NAT creating a tunnel to port 5050 and port 8080.  Then use the browser of your desktop to browse these ports.

3. browse to the Mesos UI http://c1master1:5050
 1. linux jumpbox - in top right corner choose Applications->Internet->Chrome and browse to http://c1master1:5050
 2. windows jumpbox - open browser and browse to http://c1master1:5050
 3. no jumpbox - browse to http://localhost:5050

4. Browse mesos:
 1. scroll down the page and notice your resources of CPU and memory.  These are your agents

 ![Image of mesos cluster on azure](https://raw.githubusercontent.com/anhowe/mesos-scalable-cluster/master/images/mesos-webui.png)

 2. On top of page, click frameworks and notice your Marathon and Swarm frameworks

 ![Image of mesos cluster on azure](https://raw.githubusercontent.com/anhowe/mesos-scalable-cluster/master/images/mesos-frameworks.png)

 3. On top of page, click agents and you can see your agents.  On windows or linux jumpbox you can also drill down into the slave and see its logs.

 ![Image of mesos cluster on azure](https://raw.githubusercontent.com/anhowe/mesos-scalable-cluster/master/images/mesos-agents.png)

5. browse and explore Marathon UI http://c1master1:8080 (or if using tunnel http://localhost:8080 )

6. start a long running job in Marathon
 1. click "+New App"
 2. type "myfirstapp" for the id
 3. type "/bin/bash "for i in {1..5}; do echo MyFirstApp $i; sleep 1; done" for the command
 4. scroll to bottom and click create

 ![Image of mesos cluster on azure](https://raw.githubusercontent.com/anhowe/mesos-scalable-cluster/master/images/marathon-newapp.png)

7. you will notice the new app change state from not running to running

 ![Image of mesos cluster on azure](https://raw.githubusercontent.com/anhowe/mesos-scalable-cluster/master/images/marathon-newapp-status.png)

8. browse back to mesos http://c1master1:5050.  You will notice the running tasks and the completed tasks.  Click on the host of the completed tasks and also look at the sandbox.

 ![Image of mesos cluster on azure](https://raw.githubusercontent.com/anhowe/mesos-scalable-cluster/master/images/mesos-completed-tasks.png)

# Questions
**Q.** Why is there a jumpbox?

**A.** The jumpbox is used for easy troubleshooting on the private subnet.  The Mesos Web UI requires access to all machines.  Also the web UI.  You could also consider using OpenVPN to access the private subnet.

**Q.** My cluster just completed but mesos is not up.

**A.** After your template finishes, your cluster is still running installation.  You can run "tail -f /var/log/azure/firstinstall.log" to verify the status has completed.

**Q.** I'm having errors with this template, who can I contact.

**A.** please contact anhowe@microsoft.com for errors only with this template.

**Q.** I wish this template can do X.

**A.** please contact anhowe@microsoft.com for new feature requests for this template.
