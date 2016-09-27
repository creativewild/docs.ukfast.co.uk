# BCP

## Introduction

BCP solutions are generally set up with the resources available to the cluster in mind.

Here is an example of how a normal cluster would be set up. There are two external IPs and two internal virtual IPs for the solution we will be discussing.

```console
   IP: ext. 46.37.166.xx | int. 172.27.107.xx - httpd (Apache) - Use this IP for FTP and DNS
   IP: ext. 46.37.166.xx | int. 172.27.107.xx - MySQL - Use this IP for all MySQL connection strings.
```

The BCP cluster in this case is set up to run the web service,httpd, and the database management service, `MySQL`. Essentially the `MySQL` and web disks on both servers are identical but the `httpd` and `MySQL` services are designed to run on only one of the servers at any one time. The web service will handle the web content.

You can check the status of the services by running the command `clustat` on either server which will give you output similar to the following:

```console
Member Name ID Status
MEE-WEBDB-01 1 Online, Local, rgmanager
MEE-WEBDB-02 2 Online, rgmanager

Service Name Owner (Last) State
service:mysql WEBDB-02 started
service:web WEBDB-01 started
```

## What are ricci and luci?

The Conga infrastructure consists of a node agent that handles how the services communicate with the local cluster manager, cluster resource manager and cluster LVM daemon. This is called `ricci`. There is also a web administration console which is used to configure the cluster through a web browser called `luci`. Access to these utilities is specific to the UKFast technical support staff.


## What is the RGmanager?

The RGmanager is the resource group and service manager. This manager controls how the BCP cluster starts, stops, migrates and relocates services on the cluster and is responsible for how the server recovers the services in cases of a particular node failing.


This manager is run when the servers are booted up, and on individual nodes. The service itself is run through the init scripts and during it's initialisation, all of the various services it controls (in this case the web and `MySQL` services) are started. The RGmanager is configured through the `/etc/cluster/cluster.conf` file. This file provides it with the various parameters including how various services should be handled in cases of failovers and other variables which handle the functioning of this manager. The log locations are also handled through this file and so are the filesystem configuration parameters for both services on this cluster.


The RGmanager handles services by waiting for events. These events are handled using the clusvcadm command manually. The example below describes how the RGmanager handles resources on the server during a relocation in the event of a failover. The steps below describe how the web service is moved from one server to another.


1. The /var/www/vhosts filesystem is unmounted

```console
rgmanager[27964]: [fs] unmounting /var/www/vhosts
```


2. The BCP block role is define.

```console
WEBDB-01 kernel: block drbd0: role( Primary -> Secondary )
```


3. The VIP is moved across from one node to the other. A virtual IP is a floating IP that can be associated with a node and a service.

````console
rgmanager[28043]: [ip] Removing IPv4 address 172.27.102.84/25 from eth0
```


4. The service is stopped.

```console
Service service:web is stopped
```


5. RGmanager then starts the service.

```console
rgmanager[3753]: Starting stopped service service:web
```


6. The service status is defined and this can be seen using the clustat command.

```console
WEBDB-01 rgmanager[29499]: [fs] Enabling Quotas on /var/www/vhosts
WEBDB-01 rgmanager[29553]: [script] Executing /etc/init.d/httpd start
WEBDB-01 rgmanager[3753]: Service service:web started`
```


The RGmanager can be modifed to add other resources and services such as applications that clients might want to configure on the cluster to be available on both servers and be available the same way that `MySQL` and `httpd` during failovers.

Here is what the front end administration part of the cluster looks like.

![Cluster Admin Panel](bcp_1.jpg)


## How are configuration files handled?

In cases of failover, both servers need to have the same configuration files available to them. These configuration files are located in `/etc` and `/opt` and include the `MySQL` configuration files `my.cnf` and the various other `httpd` files for the web service.

These files are consistently replicated using Unison. Unison makes sure that the servers perform the same way no matter where the services are located. The replication on UKFast's servers does not extend beyond these configuration files as the filesystems are handled by the RGmanager and not through replication.


## Configuring MySQL.

There is a virtual IP that floats between the two servers which is `46.37.166.xx` and this IP you should use for all `MySQL` connections. When the service comes up on either server, the cluster will bring up this virtual IP, mount the `MySQL` partition, `/var/lib/mysql` and start the `MySQL` service itself. Should you wish to restart either of the services, you should use the following commands (using uppercase `-R`)

**NOTE: NEVER USE THE INIT SCRIPTS ON THE SERVERS FOR THESE SERVICES**


```eval_rst
+----------------------------+--------------------------------------------+
| Command                    | Function                                   |
+============================+============================================+
| clustat                    | Shows status of cluster nodes and services |
+----------------------------+--------------------------------------------+
| clusvcadm -R {servicename} | Restarts a service.                        |
|                            | Name can be obtained from `clustat`        |
+----------------------------+--------------------------------------------+
| clusvcadm -r {servicename} | Relocates a service to the other server    |
+----------------------------+--------------------------------------------+
| clusvcadm -e {servicename} | Enables a service                          |
+----------------------------+--------------------------------------------+
| clusvcadm -d {servicename} | Disables a service                         |
+----------------------------+--------------------------------------------+
```


`MySQL` requires certain clientside changes when configuring databases. The `MySQL` remote users need to be configured using the Virtual IP associated with the `MySQL` service.
