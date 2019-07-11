# Civo Command-Line Client

## Introduction
Civo CLI is a tool to manage your [Civo.com](https://www.civo.com) account from the terminal. The [Civo web control panel](https://www.civo.com/account/) has a user-friendly interface for managing your account, but in case you want to automate or run scripts on your account, or have multiple complex services, the command-line interface outlined here will be useful. This guide will cover the set-up and usage of the Civo CLI tool with examples.

**STATUS:** This project is currently under active development and maintenance.

## Table of contents
- [Introduction](#introduction)
- [Set-Up](#set-up) 
- [API Keys](#api-keys)
- [Instances](#instances)
- [Kubernetes clusters](#kubernetes-clusters)
- [Domains and Domain Records](#domains-and-domain-records)
- [Firewalls](#firewalls)
- [Networks](#networks)
- [Quota](#quota)
- [Sizes](#sizes)
- [Snapshots](#snapshots)
- [SSH Keys](#ssh-keys)
- [Templates](#templates)
- [Volumes](#volumes)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Set-up
Civo CLI is built with Ruby and distributed as a Gem. If you have Ruby (2.0.0 or later) installed, you can simply run `gem install civo_cli` in your terminal to get the gem and its dependencies.

You may need to use `sudo` if you get an error about `You don't have write permissions` when installing the gem. The syntax is `sudo gem install civo_cli`.

If you need to install Ruby, follow the installation instructions appropriate for your operating system, and return to this guide after you have successfully installed the gem.

 - [Microsoft Windows](https://rubyinstaller.org/)
 - [Mac OS](https://www.ruby-lang.org/en/documentation/installation/#homebrew)
 - [UNIX/Linux](https://www.ruby-lang.org/en/documentation/installation/#package-management-systems)


You will also, of course, need a Civo account, for which you can [register here](https://www.civo.com/signup).

To run the tool, simply run `civo` with your chosen options. You can find context-sensitive help for commands and their options by invoking the `help` command:
`civo help`,
`civo instance help`,
`civo instance help create`
and so on. The main components of Civo CLI are outlined in the following sections.

## API Keys
#### Introduction
In order to use the command-line tool, you will need to authenticate yourself to the Civo API using a special key. You can find an automatically-generated API key or regenerate a new key at [https://www.civo.com/api](https://www.civo.com/api). 

#### Adding a current API Key to your account
You can add the API Key to the CLI tool through the API Keys command.
`civo apikey add apikey_name apikey` such as: 

```
$ civo apikey add Demo_Test_Key DAb75oyqVeaE7BI6Aa74FaRSP0E2tMZXkDWLC9wNQdcpGfH51r
       Saved the API Key DAb75oyqVeaE7BI6Aa74FaRSP0E2tMZXkDWLC9wNQdcpGfH51r as Demo_Test_Key
```
As you can have multiple API keys stored to handle multiple accounts, you will need to tell which key the tool is to authenticate with `civo apikey current [apikey_name]`. This sets your chosen API key as the default key to use for any subsequent commands:
```
$ civo apikey current Demo_Test_Key
  The current API Key is now Demo_Test_Key
```
#### Managing and listing API keys 
You can list all stored API keys in your configuration by invoking `civo apikey list` or remove one by name by using `civo apikey remove apikey_name`.

## Instances
#### Introduction
An instance is a virtual server running on the Civo cloud platform. They can be of variable size and you can run any number of them up to your quota on your account.

#### Creating an instance
You can create an instance by running `civo instance create` with a hostname parameter, as well as any options you provide:

* `hostname` is a fully qualified domain name that should be set as the instance's hostname. The client will generate a random name if not provided.
* `size` -  The size of instance to create, from the current list of sizes (e.g. g2.small) available at [`civo sizes`](#sizes). Defaults to `g2.small`.
* `template` -  The OS template UUID to use, from the available list at [`civo templates`](#templates) Defaults to Ubuntu 18.04 if no `template` value or `snapshot` provided.
* `snapshot` - The snapshot UUID to use, from snapshots you have saved on your account. Only required if `template` ID not provided.
* `region` - The region code identifier to have your instance built in. Optional; will be assigned randomly if not provided.
* `public_ip` - this should be either `none`, `create` or `from`. If `from` is specified then the `move_ip_from`parameter should also be specified (and contain the ID of the instance that will be releasing its IP). As aliases, `true` will be treated the same as `create` and `false` will be treated the same as `none`. If `create` or `true` is specified it will automatically allocate an initial public IP address, rather than having to add the first one later. Optional; default is `create`.
* `initial_user` - The name of the initial user created on the server. If not provided, will default to the template's `default_username` and fallback to `civo`.
* `ssh_key_id` - The ID of an already  [uploaded SSH public key](#ssh-keys)  to use for login to the default user. Optional; if one isn't provided a random password will be set and returned in the  `initial_password`  field.
* `tags` - A space-separated list of tags in `'quotation marks'` to be used freely as required. Optional.
* `wait` - a simple flag (e.g. `--wait`) that will cause the CLI to spin and wait for the instance to be `ACTIVE`.

Example usage:
```
$ civo instance create api-demo.test --size g2.small --template=811a8dfb-8202-49ad-b1ef-1e6320b20497 --initial_user=demo-user
 Created instance api-demo.test

$ civo instance show api-demo.test
                ID : 715f95d1-3cee-4a3c-8759-f9b49eec34c4
          Hostname : api-demo.test
              Tags :
              Size : Small - 2GB RAM, 1 CPU Core, 25GB SSD Disk
            Status : ACTIVE
        Private IP : 10.250.199.4
         Public IP : 172.31.2.164 => 91.211.152.100
           Network : Default (10.250.199.0/24)
          Firewall :  (rules: )
            Region : lon1
      Initial User : api-demouser
      OpenStack ID : 7c89f7de-2b29-4178-a2e5-55bdaa5c4c21
       Template ID : 811a8dfb-8202-49ad-b1ef-1e6320b20497
       Snapshot ID :

----------------------------- NOTES -----------------------------

 
```

You will be able to see the instance's details by running `civo instance show api-demo.test` as above.

#### Viewing the Default User Password For an Instance
You can view the default user's password for an instance by running `civo instance password ID/hostname`
```
$ civo instance password api-demo.test
The password for user civo on api-demo.test is 5OaGxNhaN11pLeWB
```
You can also run this command with the option `-q` to get only the password output, useful for scripting situations:
```
$ civo instance password -q api-demo.test
5OaGxNhaN11pLeWB
```

#### Viewing Instance Public IP Address
If an instance has a public IP address configured, you can display it using `civo instance ip_address ID/hostname`:
```
$ civo instance ip_address -q api-demo.test
91.211.152.100
```
The above example uses `-q` to display only the IP address in the output.

#### Setting Firewalls
Instances can make use of separately-configured firewalls. By default, an instance is created with no firewall rules set, so you will need to configure some rules (see [Firewalls](#firewalls) for more information).

To associate a firewall with an instance, use the command `civo instance firewall ID/hostname firewall_id`. For example:
```
$ civo instance firewall api-demo.test firewall_1
Set api-demo.test to use firewall firewall_1
```

#### Listing Instances
You can list all instances associated with a particular API key by running `civo instance list`.

#### Moving a Public IP Between Instances
Given two instances, one with a public IP and one without, you can move the public IP by `civo instance move_ip instance ip_address`:
```
$ civo instance move_ip cli-private-ip-demo.test 123.234.123.255`
 Moved public IP 123.234.123.255 to instance cli-private-ip-demo.test
```
#### Rebooting/Restarting Instances
A user can reboot an instance at any time, for example to fix a crashed piece of software. Simply run `civo instance reboot instanceID/hostname`. You will see a confirmation message:
```
$ civo instance reboot api-demo.test
 Rebooting api-demo.test. Use 'civo instance show api-demo.test' to see the current status.
```

If you prefer a soft reboot, you can run `civo instance soft_reboot instanceID/hostname` instead.

#### Removing Instances
You can use a command to remove an instance from your account. This is immediate, so use with caution! Any snapshots taken of the instance, as well as any mapped storage, will remain.
Usage: `civo instance remove instanceID/hostname`. For example:
```
$ civo instance remove api-demo.test
 Removing instance api-demo.test
```
#### Stopping (Shutting Down) and Starting Instances
You can shut down an instance at any time by running `civo instance stop instanceID/hostname`:

```
$ civo instance stop api-demo.test
 Stopping api-demo.test. Use 'civo instance show api-demo.test' to see the current status.
```
Any shut-down instance on your account can be powered back up with `civo instance start instanceID/hostname`:
```
$ civo instance start api-demo.test
 Starting api-demo.test. Use 'civo instance show api-demo.test' to see the current status.
```
#### (Re)Tagging an Instance
Tags can be useful in distinguishing and managing your instances. You can retag an instance using `civo instance tags instanceID/hostname 'tag1 tag2 tag3...'` as follows:
```
$ civo instance tags api-demo.test 'ubuntu demo web'
 Updated tags on api-demo.test. Use 'civo instance show api-demo.test' to see the current tags.'
$ civo instance show api-demo.test
                ID : 715f95d1-3cee-4a3c-8759-f9b49eec34c4
          Hostname : api-demo.test
              Tags : ubuntu, demo, web
              Size : Small - 2GB RAM, 1 CPU Core, 25GB SSD Disk
            Status : ACTIVE
        Private IP : 10.250.199.4
         Public IP : 172.31.2.164 => 91.211.152.100
           Network : Default (10.250.199.0/24)
          Firewall :  (rules: )
            Region : lon1
      Initial User : api-demouser
      OpenStack ID : 7c89f7de-2b29-4178-a2e5-55bdaa5c4c21
       Template ID : 811a8dfb-8202-49ad-b1ef-1e6320b20497
       Snapshot ID :

----------------------------- NOTES -----------------------------
```
#### Updating Instance Information
In case you need to rename an instance or add notes, you can do so with the `instance update` command as follows:
```
$ civo instance update api-demo.test --name api-demo-renamed.test --notes 'Hello, world!'
 Instance 715f95d1-3cee-4a3c-8759-f9b49eec34c4 now named api-demo-renamed.test
 Instance 715f95d1-3cee-4a3c-8759-f9b49eec34c4 notes are now: Hello, world!
$ civo instance show api-demo-renamed.test
                ID : 715f95d1-3cee-4a3c-8759-f9b49eec34c4
          Hostname : api-demo-renamed.test
              Tags : ubuntu, demo, web
              Size : Small - 2GB RAM, 1 CPU Core, 25GB SSD Disk
            Status : ACTIVE
        Private IP : 10.250.199.4
         Public IP : 172.31.2.164 => 91.211.152.100
           Network : Default (10.250.199.0/24)
          Firewall :  (rules: )
            Region : lon1
      Initial User : api-demouser
      OpenStack ID : 7c89f7de-2b29-4178-a2e5-55bdaa5c4c21
       Template ID : 811a8dfb-8202-49ad-b1ef-1e6320b20497
       Snapshot ID :

----------------------------- NOTES -----------------------------

Hello, world!
```
You can leave out either the ``--name`` or `--notes` switch if you only want to update one of the fields.

#### Upgrading (Resizing) an Instance
Provided you have room in your Civo quota, you can upgrade any instance up in size. You can upgrade an instance by using `civo instance upgrade instanceID/hostname new_size` where `new_size` is from the list of sizes at `civo sizes`:
```
$ civo instance upgrade api-demo-renamed.test g2.medium
 Resizing api-demo-renamed.test to g2.medium. Use 'civo instance show api-demo-renamed.test' to see the current status.
        
$ civo instance show api-demo-renamed.test
                ID : 715f95d1-3cee-4a3c-8759-f9b49eec34c4
          Hostname : api-demo-renamed.test
              Tags : ubuntu, demo, web
              Size : Medium - 4GB RAM, 2 CPU Cores, 50GB SSD Disk
            Status : ACTIVE
        Private IP : 10.250.199.4
         Public IP : 172.31.2.164 => 91.211.152.100
           Network : Default (10.250.199.0/24)
          Firewall :  (rules: )
            Region : lon1
      Initial User : api-demouser
  Initial Password : [randomly-assigned-password-here]
      OpenStack ID : 7c89f7de-2b29-4178-a2e5-55bdaa5c4c21
       Template ID : 811a8dfb-8202-49ad-b1ef-1e6320b20497
       Snapshot ID :

----------------------------- NOTES -----------------------------

Hello, world!
```
Please note that resizing can take a few minutes.

## Kubernetes clusters
#### Introduction
*IMPORTANT:* Kubernetes is in closed-access only at the moment, during testing. The endpoints here will be rejected unless you are one of the closed set of users that can launch them.

#### List clusters
To see your created domains, simply call `civo kubernetes list`:

```
$ civo kubernetes list
+--------------------------------------+------+---------+-----------+--------+
| ID                                   | Name | # Nodes | Size      | Status |
+--------------------------------------+------+---------+-----------+--------+
| f13e3f64-d657-40dd-8449-c42c6e341208 | test | 3       | g2.medium | ACTIVE |
+--------------------------------------+------+---------+-----------+--------+
```

#### Create a cluster
You can create an instance by running `civo kubernetes create` with a cluster name parameter, as well as any options you provide:

* `size` -  The size of nodes to create, from the current list of sizes  available at [`civo sizes`](#sizes). Defaults to `g2.medium`.
* `nodes` -  The number of nodes to create (the master also acts as a node).
* `wait` - a simple flag (e.g. `--wait`) that will cause the CLI to spin and wait for the cluster to be `ACTIVE`.

```
$ civo kubernetes create my-first-cluster
Created Kubernetes cluster my-first-cluster
```

#### Scaling the cluster
You can change the total number of nodes in the cluster (obviously 1 is the minimum) live while the cluster is running. It takes the name of the cluster (or the ID) and a parameter of `--nodes` which is the new number of nodes to run

```
civo kubernetes scale my-first-cluster --nodes=4
Kubernetes cluster my-first-cluster will now have 4 nodes
```

#### Renaming the cluster
Although the name isn't used anywhere except for in the list of clusters (e.g. it's not in any way written in to the cluster), if you wish to rename a cluster you can do so with:

```
civo kubernetes rename my-first-cluster --name="Production"
Kubernetes cluster my-first-cluster is now named Production
```

#### Removing the cluster
If you're completely finished with a cluster you can delete it with:

```
civo kubernetes remove my-first-cluster
Removing Kubernetes cluster my-first-cluster
```


## Domains and Domain Records
#### Introduction
We host reverse DNS for all instances automatically. If you'd like to manage forward (normal) DNS for your domains, you can do that for free within your account.

This section is effectively split in to two parts: 1) Managing domain names themselves, and 2) Managing records within those domain names.

We don't offer registration of domains names, this is purely for hosting the DNS. If you're looking to buy a domain name, we recommend  [LCN.com](https://www.lcn.com/)  for their excellent friendly support and very competitive prices.
#### Set Up a New Domain
Any user can add a domain name (that has been registered elsewhere) to be managed by Civo.com. You should adjust the nameservers of your domain (through your registrar) to point to  `ns0.civo.com`  and  `ns1.civo.com`.

The command to set up a new domain is `civo domain create domainname`:
```
$ civo domain create civoclidemo.xyz
Created a domain called civoclidemo.xyz with ID 418181b2-fcd2-46a2-ba7f-c843c331e79b
```
You can then proceed to add DNS records to this domain.

#### List Domain Names
To see your created domains, simply call `civo domain list`:
```
$ civo domain list
+--------------------------------------+-----------------+
| ID                                   | Name            |
+--------------------------------------+-----------------+
| 418181b2-fcd2-46a2-ba7f-c843c331e79b | civoclidemo.xyz |
+--------------------------------------+-----------------+
```
#### Deleting a Domain
If you choose to delete a domain, you can call `civo domain remove domain_id` and have the system immediately remove the domain and any associated DNS records. This removal is immediate, so use with caution.

#### Creating a DNS Record
A DNS record creation command takes a number of options in the format `civo domainrecord create record_name type value` with optional `-p` (priority for MX records) and `-t` (time-to-live of record cache, in seconds).

`type` is one of the following:
`a` -> Alias a hostname to an IP address
`cname` or `canonical` -> Point a hostname to another hostname
`mx` -> The hostname of a mail server
`txt` or `text` -> Generic text record

 Usage is as follows:
```
$ civo domainrecord create civoclidemo.xyz mx 10.0.0.1 -p=10 -t=1000

#<Civo::DnsRecord id: "2079e6e1-0633-4cd0-b883-e82a8991a91a", created_at: "2019-06-17 12:38:02", updated_at: "2019-06-17 12:38:02", account_id: nil, domain_id: "418181b2-fcd2-46a2-ba7f-c843c331e79b", name: "@", value: "10.0.0.1", type: "mx", priority: 10, ttl: 1000, ETag: "187cf7e849ce53336a889b2bde7ed061", Status: 200>
Created MX record civoclidemo.xyz for civoclidemo.xyz with a TTL of 1000 seconds and with a priority of 10 with ID 2079e6e1-0633-4cd0-b883-e82a8991a91a
``` 
#### Listing DNS Records
You can get an overview of all records you have created for a particular domain by requesting `civo domainrecord list domain.name`:
```
civo domainrecord list civoclidemo.xyz
+--------------------------------------+------+-------------------+----------+------+----------+
| ID                                   | Type | Name              | Value    | TTL  | Priority |
+--------------------------------------+------+-------------------+----------+------+----------+
| 2079e6e1-0633-4cd0-b883-e82a8991a91a | MX   | @.civoclidemo.xyz | 10.0.0.1 | 1000 | 10       |
+--------------------------------------+------+-------------------+----------+------+----------+
```
#### Deleting a DNS Record
You can remove a particular DNS record from a domain you own by requesting `civo domainrecord remove record_id`. This immediately removes the associated record, so use with caution:
```
$ civo domainrecord remove 2079e6e1-0633-4cd0-b883-e82a8991a91a
Removed the record @ record with ID 2079e6e1-0633-4cd0-b883-e82a8991a91a
```

## Firewalls
#### Introduction
You can configure custom firewall rules for your instances using the Firewall component of Civo CLI. These are freely configurable, however customers should be careful to not lock out their own access to their instances. By default, all ports are closed for custom firewalls.

Firewalls can be configured with rules, and they can be made to apply to your chosen instance(s) with subsequent commands.

#### Configuring a New Firewall
To create a new Firewall, use `civo firewall create new_firewall_name`:
```
$ civo firewall create civocli_demo
 Created firewall civocli_demo
```
You will then be able to **configure rules** that allow connections to and from your instance by adding a new rule using `civo firewall new_rule firewall_id` with the required and your choice of optional parameters, listed here and used in an example below:
* `firewall_id` - The UUID of the firewall you are adding a rule to. Required.
* `start_port` - The starting port that the rule applies to. Required.
* `end_port` - The end of the port range that the rule applies to. Optional; if not specified, the rule will only apply to `start_port` specified.
* `protocol` - The protocol for the rule (`TCP, UDP, ICMP`). If not provided, defaults to `TCP`.
* `cidr` - The IP address of the other end (i.e. not your instance) to affect, or a valid network CIDR. Defaults to being globally applied, i.e. `0.0.0.0/0`. 
* `direction` -  Will this rule affect `inbound` or `outbound` traffic? Defaults to `inbound`.
* `label` - A label for your own reference for this rule. Optional.

Example usage:
```
$ civo firewall new_rule --firewall_id=09f8d85b-0cf1-4dcf-a472-ba247fb4be21 --start_port=22 --direction=inbound --label='SSH access for CLI demo'
 New rule SSH access for CLI demo created

$ civo firewall list_rules 09f8d85b-0cf1-4dcf-a472-ba247fb4be21
+--------------------------------------+----------+------------+----------+-----------+-------------------------+
|                            Firewall rules for 09f8d85b-0cf1-4dcf-a472-ba247fb4be21                            |
+--------------------------------------+----------+------------+----------+-----------+-------------------------+
| ID                                   | Protocol | Start Port | End Port | CIDR      | Label                   |
+--------------------------------------+----------+------------+----------+-----------+-------------------------+
| 4070f87b-e6c6-4208-91c5-fc4bc72c1587 | tcp      | 22         | 22       | 0.0.0.0/0 | SSH access for CLI demo |
+--------------------------------------+----------+------------+----------+-----------+-------------------------+
```
You can see all active rules for a particular firewall by calling `civo firewall list_rules firewall_id`, where `firewall_id` is the UUID of your particular firewall.

#### Managing Firewalls
You can see an overview of your firewalls using `civo firewall list` showing you which firewalls have been configured with rules, and whether any of your instances are using a given firewall, such as in this case where the firewall we have just configured has the one rule, but no instances using it.
```
$ civo firewall list
+--------------------------------------+--------------+--------------+-----------------+
| ID                                   | Name         | No. of Rules | instances using |
+--------------------------------------+--------------+--------------+-----------------+
| 09f8d85b-0cf1-4dcf-a472-ba247fb4be21 | civocli_demo | 1            | 0               |
+--------------------------------------+--------------+--------------+-----------------+
```
To configure an instance to use a particular firewall, see [Instances/Setting firewalls elsewhere in this guide](#setting-firewalls).

To get more detail about the specific rule(s) of a particular firewall, you can use `civo firewall list_rules firewall_id`.

#### Deleting Firewall Rules and Firewalls
You can remove a firewall rule simply by calling `civo firewall delete_rule firewall_id rule_id` - confirming the Firewall ID to delete a particular rule from - as follows:
```
$ civo firewall delete_rule 09f8d85b-0cf1-4dcf-a472-ba247fb4be21 4070f87b-e6c6-4208-91c5-fc4bc72c1587
        Removed Firewall rule 4070f87b-e6c6-4208-91c5-fc4bc72c1587
        
$ civo firewall list_rules 09f8d85b-0cf1-4dcf-a472-ba247fb4be21
+-------+----------+------------+----------+------+-------+
| Firewall rules for 09f8d85b-0cf1-4dcf-a472-ba247fb4be21 |
+-------+----------+------------+----------+------+-------+
| ID    | Protocol | Start Port | End Port | CIDR | Label |
+-------+----------+------------+----------+------+-------+
+-------+----------+------------+----------+------+-------+
```
Similarly, you can delete a firewall itself by calling `civo firewall remove firewall_id`:
```
$ civo firewall remove 09f8d85b-0cf1-4dcf-a472-ba247fb4be21
        Removed firewall 09f8d85b-0cf1-4dcf-a472-ba247fb4be21

$ civo firewall list
+----+------+--------------+-----------------+
| ID | Name | No. of Rules | instances using |
+----+------+--------------+-----------------+
+----+------+--------------+-----------------+
```

## Networks
#### Introduction
Civo allows for true private networking if you want to isolate instances from each other. For example, you could set up three instances, keeping one as a [
](https://en.wikipedia.org/wiki/Bastion_host) and load balancer, with instances acting as e.g. a database server and a separate application server, both with private IPs only.

#### Viewing Networks
You can list your currently-configured networks by calling `civo network list`. This will show the network ID, name label and its CIDR range.

#### Creating Networks
You can create a new private network using `civo network create network_label`:
```
$ civo network create cli-demo
Create a private network called cli-demo with ID 74b69006-ea59-46a0-96c4-63f5bfa290e1
```
#### Removing Networks
Removal of a network, provided you do not need it and your applications do not depend on routing through it, is simple - simply call `civo network remove network_ID`:
```
$ civo network remove 74b69006-ea59-46a0-96c4-63f5bfa290e1
Removed the network cli-demo with ID 74b69006-ea59-46a0-96c4-63f5bfa290e1
```

## Quota
All customers joining Civo will have a default quota applied to their account. The quota has nothing to do with charges or payments, but with the limits on the amount of simultaneous resources you can use. You can view the state of your quota at any time by running `civo quota`. Here is my current quota usage at the time of writing:
```
$ civo quota
+------------------+-------+-------+
| Item             | Usage | Limit |
+------------------+-------+-------+
| Instances        | 4     | 16    |
| CPU cores        | 5     | 16    |
| RAM MB           | 7168  | 32768 |
| Disk GB          | 150   | 400   |
| Volumes          | 4     | 16    |
| Snapshots        | 1     | 48    |
| Public IPs       | 4     | 16    |
| Subnets          | 1     | 10    |
| Private networks | 1     | 10    |
| Firewalls        | 1     | 16    |
| Firewall rules   | 1     | 160   |
+------------------+-------+-------+
Any items in red are at least 80% of your limit
```
If you have a legitimate need for a quota increase, visit the [Quota page](https://www.civo.com/account/quota) to place your request - we won't unreasonably withhold any increase, it's just in place so we can control the rate of growth of our platform and so that erran scripts using our API don't suddenly exhaust our available resources.

## Regions
As Civo grows, more regions for hosting your instances will become available. You can run `civo region` to list the regions available. Block storage (Volumes) is region-specific, so if you configure an instance in one region, any volumes you wish to attach to that instance would have to be in the same region.

## Sizes
Civo instances come in a variety of sizes depending on your need and budget. You can get details of the sizes of instances available by calling `civo sizes` or `civo sizes list`. You will get something along the lines of the following:
```
$ civo sizes
+------------+----------------------------------------------------+-----+----------+-----------+
| Name       | Description                                        | CPU | RAM (MB) | Disk (GB) |
+------------+----------------------------------------------------+-----+----------+-----------+
| g2.xsmall  | Extra Small - 1GB RAM, 1 CPU Core, 25GB SSD Disk   | 1   | 1024     | 25        |
| g2.small   | Small - 2GB RAM, 1 CPU Core, 25GB SSD Disk         | 1   | 2048     | 25        |
| g2.medium  | Medium - 4GB RAM, 2 CPU Cores, 50GB SSD Disk       | 2   | 4096     | 50        |
| g2.large   | Large - 8GB RAM, 4 CPU Cores, 100GB SSD Disk       | 4   | 8192     | 100       |
| g2.xlarge  | Extra Large - 16GB RAM, 6 CPU Core, 150GB SSD Disk | 6   | 16386    | 150       |
| g2.2xlarge | 2X Large - 32GB RAM, 8 CPU Core, 200GB SSD Disk    | 8   | 32768    | 200       |
+------------+----------------------------------------------------+-----+----------+-----------+
```
This command is useful for getting the name of the instance type if you do not remember it - you will need to specify the instance size name when creating an instance using the CLI tool.

## Snapshots
#### Introduction
Snapshots are a clever way to back up your instances. A snapshot is an exact copy of the instance's virtual hard drive at the moment of creation. At any point, you can restore an instance to the state it was at snapshot creation, or use snapshots to build new instances that are configured exactly the same as other servers you host.

As snapshot storage is chargeable (see [
Quota](#quota)), at any time these can be deleted by you. They can also be scheduled rather than immediately created, and if desired repeated at the same schedule each week (although the repeated snapshot will overwrite itself each week, not keep multiple weekly snapshots).

#### Creating Snapshots
You can create a snapshot from an existing instance on the command line by using `civo snapshot create snapshot_name instance_id`
For a one-off snapshot that's all you will need:
```
civo snapshot create CLI-demo-snapshot 715f95d1-3cee-4a3c-8759-f9b49eec34c4
Created snapshot CLI-demo-snapshot with ID d6d7704b-3402-44d0-aeb1-09875f71d168
```
For scheduled snapshots, include the `-c '0 * * * *'` switch, where the `'0 * * * *'` string is in `cron` format.

Creating snapshots is not instant, and will take a while depending on the size of the instance being backed up. You will be able to monitor the status of your snapshot by listing your snapshots as described below.

#### Listing Snapshots
You can view all your currently-stored snapshots and a bit of information about them by running `civo snapshot list`:
```
$ ./exe/civo snapshot list
+--------------------------------------+-------------------+----------------+-----------+---------+
| ID                                   | Name              | State          | Size (GB) | Cron    |
+--------------------------------------+-------------------+----------------+-----------+---------+
| 3506a013-85a5-4628-bf51-3e25a3bb3dbd | hello_world       | complete       | 25        | One-off |
| d6d7704b-3402-44d0-aeb1-09875f71d168 | CLI-demo-snapshot | ready_to_start |           | One-off |
+--------------------------------------+-------------------+----------------+-----------+---------+
```
(The 'ready_to_start' status in the above is indicative of the `CLI-demo-snapshot` being in the process of being created.)

#### Removing Snapshots
Snapshots that are not associated with an instance can be removed using `civo snapshot remove snapshot_id` as follows:
```
$ civo snapshot remove d6d7704b-3402-44d0-aeb1-09875f71d168
Removed snapshot CLI-demo-snapshot with ID d6d7704b-3402-44d0-aeb1-09875f71d168
```
If an instance was created from a snapshot, you will not be able to remove the snapshot itself.

## SSH Keys
#### Introduction
To manage the SSH keys for an account that are used to log in to cloud instances, the Civo CLI tool provides the following commands. You would need to [
generate a new key](https://www.civo.com/learn/ssh-key-basics) according to your particular circumstances, if you do not have a suitable SSH key yet.

#### Uploading a New SSH Key
You will need the path to your public SSH Key to upload a new key to Civo. The usage is as follows: `civo sshkey upload NAME /path/to/FILENAME`

#### Listing Your SSH Keys
You will be able to list the SSH keys known for the current account holder by invoking `civo sshkey list`:
```
$ civo sshkeys
+--------------------------------------+------------------+----------------------------------------------------+
| ID                                   | Name             | Fingerprint                                        |
+--------------------------------------+------------------+----------------------------------------------------+
| 8aa45fea-a395-471c-93a6-27485a8429f3 | civo_cli_demo    | SHA256:[Unique SSH Fingerprint]                    |
+--------------------------------------+------------------+----------------------------------------------------+
```
#### Removing a SSH Key
You can delete a SSH key by calling `remove` for it by ID:
```
$ civo sshkeys remove 531d0998-4152-410a-af20-0cccb1c7c73b
Removed SSH key cli-demo with ID 531d0998-4152-410a-af20-0cccb1c7c73b
```

## Templates
#### Introduction
Civo instances are built from a template that specifies a disk image. Templates can contain the bare-bones OS install such as Ubuntu or Debian, or custom pre-configured operating systems that you can create yourself from a bootable volume. This allows you to speedily deploy pre-configured instances.

#### Listing Available Template Images
A simple list of available templates, both globally-defined ones and user-configured account-specific templates, can be seen by running `civo template list` or `civo template list --verbose` for maximum information:
```
$ civo template list --verbose
+--------------------------------------+----------------------+--------------------------------------+--------------------------------------+------------------+
| ID                                   | Name                 | Image ID                             | Volume ID                            | Default Username |
+--------------------------------------+----------------------+--------------------------------------+--------------------------------------+------------------+
| 62f9c8a5-c3aa-4873-afad-44e1ee01ed43 | Ubuntu 14.04         | 637b163e-ca9c-42a8-bc02-d60e3025e9b2 | 65288478-50d0-4ab7-837e-18ddcf71ea5f | ubuntu           |
| 458ae900-30e0-4ade-bd68-d137d57d4e47 | CentOS 7             | e17ec38a-1e77-4c45-bef3-569567c9b169 | cf3368dd-ccb3-4f6d-adf5-bad9a8ae9177 | centos           |
| 67c4df28-8db8-48e5-84b3-d79b9d59920b | CentOS 6             | 04d66ce1-f20e-4d84-a6d4-cdde5a07ff7e | d69c297b-a18d-4388-b4ce-9f11e04fc45f | centos           |
| c2124658-0f9f-4d40-bb52-6288819fdc39 | Debian Jessie        | 38686161-ba25-4899-ac0a-54eaf35239c0 | 5c37a01d-342e-4732-9a59-79fcbc4c91f4 | admin            |
| 1427e49f-d159-4421-b6cc-34c43775764b | CoreOS               | e5a2be4a-fb83-48e8-875d-5e5ff565c9e5 |                                      | core             |
| 5d61621a-f9c1-4261-b863-2a205792b12f | Ubuntu 17.04         | a478ab7f-1ac0-4d86-9a57-e607b2bbbcf0 |                                      | ubuntu           |
| 033c35a0-a8c3-4518-8114-d156a4d4c512 | Debian Stretch       | 2ffff07e-6953-4864-8ce9-1f754d70de31 | 1b117fe1-a237-43b2-8cab-d47086ce3d30 | admin            |
| 359494e6-2439-471e-a528-f8866dade6ba | FreeBSD 11.1-RELEASE | 8d3886df-c5c1-4efe-aa5a-659217b466a5 |                                      | freebsd          |
| b0d30599-898a-4072-86a1-6ed2965320d9 | Ubuntu 16.04         | 8b4d81e0-6283-4ea3-bbc4-478df568024e | ea411e3f-479a-4767-9273-b8cc758ca619 | ubuntu           |
| 811a8dfb-8202-49ad-b1ef-1e6320b20497 | Ubuntu 18.04         | e4838e89-f086-41a1-86b2-60bc4b0a259e | 7c9f99a5-909a-4d4f-91a2-e0174fe4d2a9 | ubuntu           |
+--------------------------------------+----------------------+--------------------------------------+--------------------------------------+------------------+
```

#### Viewing Details of a Template
Detailed information about a template can be obtained via the CLI using `civo template show template_ID`.


#### Creating a Template
You can convert a **bootable** Volume (virtual disk) of an instance, or alternatively use an existing image ID, to create a template. The options for the `civo template create` command are:
```
Options: 
  -c, [--cloud-init-file=CLOUD_INIT_FILENAME] # The filename of a file to be used as user-data/cloud-init
  -d, [--description=DESCRIPTION] # A full/long multiline description (optional)
  -i, [--image-id=IMAGE_ID] # The glance ID of the base filesystem image
  -v, [--volume-id=VOLUME_ID] # The volume ID of the base filesystem volume
  -n, [--name=NICE_NAME] # A nice name to be used for the template
  -s, [--short-description=SUMMARY] # A one line short summary of the template
```

```
$ civo template create -n="cli-demo" -v=1427e49f-d159-4421-b6cc-34c43775764b --description="This is a demo template made from a CoreOS image" --short-description="CoreOS CLI demo"
	Created template cli-demo
```

#### Updating Template Information
Once you have  created a custom template, you can update information that allows for the easy identification and management of the template. Usage is `civo template update template_id [options]`:

```
Options:
  -c, [--cloud-init-file=CLOUD_INIT_FILENAME]  # The filename of a file to be used as user-data/cloud-init
  -d, [--description=DESCRIPTION]              # A full/long multiline description
  -i, [--image-id=IMAGE_ID]                    # The glance ID of the base filesystem image
  -v, [--volume-id=VOLUME_ID]                  # The volume ID of the base filesystem volume
  -n, [--name=NICE_NAME]                       # A nice name to be used for the template
  -s, [--short-description=SUMMARY]            # A one line short summary of the template
```
#### Removing a Template
Removing an account-specific template is done using the `template remove template_id` command:
```
$ civo template remove 1427e22f-d149-4421-b6ab-34c43754224c
```
Please note that template removal is immediate! Use with caution.

## Volumes
#### Introduction
Volumes are flexible-size additional storage for instances. By creating and associating a Volume with an instance, an additional virtual disk will be made available for backups or database files that can then moved to another instance.

Volumes take disk space on your account's quota, and can only be created up to this quota limit. For more information about the quota system, see [Quota](#quota).

#### Creating a Volume
You can create a new volume by calling `civo volume create NAME SIZE(GB)`:
```
$ civo volume create CLI-demo-volume 25
Created a new 25GB volume called CLI-demo-volume with ID 9b232ffa-7e05-45a4-85d8-d3643e68952e
```
#### Attaching a Volume to an Instance
Mounting (Attaching) a volume onto an instance will allow that instance to use the volume as a drive:
```
$ civo volume attach 9b232ffa-7e05-45a4-85d8-d3643e68952e 715f95d1-3cee-4a3c-8759-f9b49eec34c4
Attached volume CLI-demo-volume with ID 9b232ffa-7e05-45a4-85d8-d3643e68952e to api-demo.test
```
If this is a newly-created volume, you would need to partition, format and mount the volume. For more information, [see the Learn guide here](https://www.civo.com/learn/configuring-block-storage-on-civo).
Note: You can only attach a volume to one instance at a time.

#### Detaching a Volume From an Instance
If you want to detach a volume to move it to another instance, or are just finished with it, you can detach it once it's been [unmounted](https://www.civo.com/learn/configuring-block-storage-on-civo) using `civo volume detach volume_id`:
```
$ civo volume detach 9b232ffa-7e05-45a4-85d8-d3643e68952e
Detached volume CLI-demo-volume with ID 9b232ffa-7e05-45a4-85d8-d3643e68952e
```
#### Listing Volumes
You can get an overall view of your volumes, their sizes and status by using `civo volume list`.

#### Resizing Volumes
An un-attached volume can be resized if you need extra space. This is done by calling `civo volume resize volume_id new_size` where `new-size` is in gigabytes:
```
$ civo volume resize 9b232ffa-7e05-45a4-85d8-d3643e68952e 30
Resized volume CLI-demo-volume with ID 9b232ffa-7e05-45a4-85d8-d3643e68952e to be 30GB
```

#### Deleting Volumes

To free up quota and therefore the amount to be billed to your account, you can delete a volume through `civo volume delete volume_id`. This deletion is immediate:
```
$ civo volume delete 9b232ffa-7e05-45a4-85d8-d3643e68952e
Removed volume CLI-demo-volume with ID 9b232ffa-7e05-45a4-85d8-d3643e68952e (was 30GB)
$ civo volume list
+----+------+---------+-----------+
| ID | Name | Mounted | Size (GB) |
+----+------+---------+-----------+
+----+------+---------+-----------+
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

For more information on some commonly used Gems in this project see:

* [Civo API](https://github.com/absolutedevops/civo-ruby)
* [Thor](http://whatisthor.com/)
* [Terminal Table](https://github.com/tj/terminal-table)
* [Colorize](https://github.com/fazibear/colorize)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/civo/cli.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
