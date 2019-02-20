# Civo Command-Line Client

This utility is for interacting with the Civo Cloud API provided on Civo.com. In order to use the API you need an API key, which is available when you're logged in to Civo.com at https://www.civo.com/api.

## Installation/overview

The first step should be to download the client. This is simply done using:

```
gem install civo_cli
```

You'll then need to run a command in a Terminal to register your API key with the client. Let's take the example that your company is called "Acme Widgets" and your API key is "123456789012345678901234567890". You need to give the API key a short reference when saving it, such as `acme` (because you can register multiple API keys for different accounts in the same client):

```
civo apikeys save -n acme -k 123456789012345678901234567890
```

You will then need to set this as your default apikey to be used in all future requests with:

```
civo apikeys default -n acme
```

Now you are free to use the remaining commands in the system. We'll work through the most common ones below, the rest are normally used by Civo administrators (and the permission levels associated with your apikey in CIvo won't allow you to make them).

In order to discover the available commands you can use `civo -h` to list the available commands, then use `civo [command] -h` to list sub commands and so on further down the line.  For example:

```
civo -h
civo instances -h
civo instances create -h
```

In this way all the possible things you can do with the client are discoverable.


## SSH keys

One of the first things you'll likely want to do is upload your SSH public key, so that you can SSH in to new instances - you can't create a new instance without this step.

Assuming your public key is in `~/.ssh/id_rsa.pub` (if it isn't, you'll probably know why and where it is) you can upload this with:

```
civo sshkey upload --name default --public-key ~/.ssh/id_rsa.pub
```

If you want to remove a public key (say you are replacing it with a new one), you can do this with:

```
civo sshkey delete --name default
```

**Note:** This won't remove it from your currently running instances, it will only affect new instances created.


## Choosing the specification of an instance
When creating an instance, you'll need to specify items such as the size of instance, which region to create it in (if your provider supports multiple regions) and the template to use (from the available operating systems, versions and layered applications).

The information on all of these are available by running `civo size`, `civo region` and `civo template`.  The output of the command will give you the key to use when creating the instance.  For example (and these are subject to change):

```
$ civo size
+-----------+----------------------------------------------------+
|   Name    |                   Specification                    |
+-----------+----------------------------------------------------+
| g1.xsmall | Extra Small - 512MB RAM, 1 CPU Core, 20GB SSD Disk |
| g1.small  | Small - 1GB RAM, 2 CPU Cores, 50GB SSD Disk        |
| g1.medium | Medium - 2GB RAM, 4 CPU Cores, 100GB SSD Disk      |
| g1.large  | Large - 4GB RAM, 6 CPU Cores, 150GB SSD Disk       |
| g1.xlarge | Extra Large - 8GB RAM, 8 CPU Cores, 200GB SSD Disk |
+-----------+----------------------------------------------------+

$ civo template
+--------------------+------------------------------------------------------------------------+
|         ID         |                              Description                               |
+--------------------+------------------------------------------------------------------------+
| centos-7           | CentOS version 7 (RHEL open source clone)                              |
| ubuntu-14.04-vesta | Canonical's Ubuntu 14.04 with the Vesta Control Panel                  |
| ubuntu-14.04       | Canonical's Ubuntu 14.04 installed in a minimal configuration          |
+--------------------+------------------------------------------------------------------------+
```


## Managing instances

To view the list of your currently running instances you can simply run:

```
civo instance
```

This will output a table listing the instances currently in your account:

```
+----------+-------------------+----------+-------------------------------+--------+------+--------------+
|    ID    |       Name        |   Size   |         IP Addresses          | Status | User |   Password   |
+----------+-------------------+----------+-------------------------------+--------+------+--------------+
| 8043d0e7 | test1.example.com | g1.small | 10.0.0.2=>31.28.88.103        | ACTIVE | civo | jioAQfSDffFS |
+----------+-------------------+----------+-------------------------------+--------+------+--------------+
```

Creating an instance is a simple command away (remember, if you can't remember the parameters `civo instance create -h` is there to help you) using something like:

```
civo instance create --name test2.example.com --size g1.small \
  --region svg1 --ssh-key-id default --template ubuntu-14.04 --public-ip
```

If you don't specify a name, a random one will be created for you.

**Note:** Specifying the name will set the hostname on the machine but won't affect DNS resolution, currently that's up to you to provide separately.

If you decide you don't need an instance any more you can remove it by simply calling `civo instance destroy` passing in either the ID or the name, using the details above as an example:

```
civo instance destroy -i8043d0e7
civo instance destroy --id=test1.example.com
```

**Note:** The machine will be forever destroyed at this point, you can't get the data back from the hard drive afterwards.

If your machine gets stuck you can restart it with (again using either the ID or the name):

```
civo instance reboot --id=8043d0e7
```

If it's *really* stuck (i.e. hard kernel lock) then you can do the cloud equivalent of unplugging it and plugging it back in with the addition of the hard switch:

```
civo instance reboot --hard --id=8043d0e7
```

## Snapshots (backups)

If you want to take a snapshot of an instance, you can do this using a single command line like this:

```
civo snapshot create --name my-backup --instance 8043d0e7 --safe
```

The name can be anything you choose, it won't conflict if you create two snapshots with the same name (but it will make it harder for you to remember which is which).  The instance has to be part of the ID or a unique part of the hostname.  The `--safe` is optional - without this switch it will snapshot your instance while it runs, with the flag it will shut the instance down first, take a snapshot then start it back up.  The reason it's referred to as `safe` is that if you snapshot a running instance, any database server may be the middle of rewriting files for example, leaving them in a half-rewritten and hence corrupted state. If you know your machine is in a good state (say it's an application server), then you can snapshot while it's running.

## Firewalls

By default all ports and protocols are open on your instance.  We would recommend either using something like [iptables](http://netfilter.org/projects/iptables/) or [Ucomplicated Fire Wall](https://help.ubuntu.com/community/UFW) on the instance, or using the Civo firewall functionality which sits outside your instance (and hence can't be turned off if the machine is compromised).

The first step is to create a new firewall with:

```
civo firewall create --name my-firewall
```

For confirmation that this has worked you can run `civo firewall` to list the firewalls. Then you can add rules to it with commands like (to allow incoming SSH and pings):

```
civo firewall rules create my-firewall -p tcp -s 22
civo firewall rules create my-firewall -p icmp
```

You can check that it's configured correctly by running `civo firewall rules my-firewall`. Now that you're sure your firewall is configured, you can assign it to one or more instances with:

```
civo instances firewall --id=8043d0e7 --firewall my-firewall
```

If you make a mistake at any point, you can revert to the default firewall by simply running the same command without `--firewall ...`, for example:

```
civo instances firewall --id=8043d0e7
```

## Quota

All Civo users have a limited quota applied to their account (to stop errant scripts from filling up the cloud with a million instances).  You can view your current quota using a command like this:

```
$ civo quota
+---------------------------------------+------+-------+
|                 Title                 | Used | Limit |
+---------------------------------------+------+-------+
| Number of instances                   |    0 |    10 |
| Total CPU cores                       |    0 |    20 |
| Total RAM (MB)                        |    0 |  5120 |
| Total disk space (GB)                 |    0 |   250 |
| Disk volumes                          |    0 |    10 |
| Disk snapshots                        |    0 |    30 |
| Public IP addresses                   |    0 |    10 |
| Private subnets                       |    0 |     1 |
| Private networks                      |    0 |     1 |
| Security groups                       |    0 |    10 |
| Security group rules                  |    0 |   100 |
| Number of ports (network connections) |    0 |    20 |
+---------------------------------------+------+-------+
```

If you want to increase them, contact us via Civo.com.

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

