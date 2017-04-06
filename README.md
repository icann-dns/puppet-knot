[![Build Status](https://travis-ci.org/icann-dns/puppet-knot.svg?branch=master)](https://travis-ci.org/icann-dns/puppet-knot)
[![Puppet Forge](https://img.shields.io/puppetforge/v/icann/knot.svg?maxAge=2592000)](https://forge.puppet.com/icann/knot)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/icann/knot.svg?maxAge=2592000)](https://forge.puppet.com/icann/knot)

# knot

# WARNING version 0.2.x is *NOT* backwards compatible with 0.1.x

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with knot](#setup)
    * [What knot affects](#what-knot-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with knot](#beginning-with-knot)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Manage the installation and configuration of KNOT 1.* and zone files.

## Module Description

This module allows for the management of all aspects of the KNOT configuration 
file, keys and zonefiles.  

## Setup

### What knot affects

* Manages configuration the knot configueration file 
* Manages zone data in the zone dir
* dynamicly sets processor count based on installed processes
* can manage knot control

### Setup Requirements **OPTIONAL**

* puppetlabs-stdlib 4.11.0
* icann-tea 0.2.8
* puppetlabs-concat 1.2.0

### Beginning with knot

Install the package an make sure it is enabled and running with default options:

```puppet 
class { '::knot': }
```

With some basic configueration

```puppet
class { '::knot':
  ip_addresses => ['192.0.2.1'],
  rrl_size     => 1000,
}
```

and in hiera

```yaml
knot::ip_addresses:
- 192.0.2.1
rrl_size: 1000
```

## Usage

Add config with primary tsig key

```puppet
class {'::knot':
  default_tsig_name: 'test',
  tsigs => {
    'test',=>  {
      'algo' => 'hmac-sha256',
      'data' => 'adsasdasdasd='
    }
  }
}
```

or with hiera

```yaml
knot::default_tsig_name: test
knot::tsigs:
  test:
    algo: hmac-sha256
    data: adsasdasdasd=
```

add zone files.  zone files are added with sets of common config.

```puppet
class {'::knot':
  remotes => {
    master_v4 => { 'address4' => '192.0.2.1' },
    master_v6 => { 'address6' => '2001:DB8::1' },
    slave     => { 'address4' => '192.0.2.2' },
  }
  zones => {
    'example.com' => {
      'masters' => ['master_v4', 'master_v6']
      'provide_xfrs'  => ['slave'],
    },
    'example.net' => {
      'masters' => ['master_v4', 'master_v6']
      'provide_xfrs'  => ['slave'],
    }
    'example.org' => {
      'masters' => ['master_v4', 'master_v6']
      'provide_xfrs'  => ['slave'],
    }
  }
}
```

in hiera

```yaml
knot::remotes:
  master_v4:
	address4: 192.0.2.1
  master_v6:
	address4: 2001:DB8::1
  slave:
	address4: 192.0.2.2
knot::zones:
  example.com:
	masters: &id001
	- master_v4
	- master_v6
	provide_xfrs: &id002
	- slave
  example.net:
	masters: *id001
	slave: *id002
  example.org:
	masters: *id001
	slave: *id002
```

create and as112, please look at the as112 class to see how this works under the hood

```puppet
  class {'::nsd::as112': }
```

## Reference


- [**Public Classes**](#public-classes)
    - [`knot`](#class-knot)
- [**Private Classes**](#private-classes)
    - [`knot::params`](#class-knotparams)
- [**Private defined types**](#private-defined-types)
    - [`knot::file`](#defined-knotfile)
    - [`knot::tsig`](#defined-knottsig)
    - [`knot::zone`](#defined-knotzone)
    - [`knot::zone`](#defined-knotremotes)
- [**Facts**](#facts)
    - ['knot_version'](#fact-knotversion)

### Classes

### Public Classes

#### Class: `knot`
  Guides the basic setup and installation of KNOT on your system
  
##### Parameters (all optional)

* `default_tsig_name` (Optional[String], Default: undef): the default tsig to use when fetching zone data. Knot::Tsig[$default_tsig_name] must exist
* `default_masters` (Array[String], Default: []): Array of Knot::Remote names to use as the default master servers if none are specified in the zone hash
* `default_provide_xfrs` (Array[String], Default: []): Array of Knot::Remote names to use as the provide_xfr servers if none are specified in the zone hash
* `enable` (Bool, Default: true): enable or disable the knot service, config files are still configuered.
* `zones`: a hash which is passed to create_resoure(knot::zone, $zones). Default: Empty.
* `files` (Hash, Default: {}):  a hash which is passed to create_resoure(knot::file, $files).
* `tsigs` (Hash, Default: {}): a hash which is passed to create_resoure(knot::tsig, $tsigs)
* `remotes` (Hash, Default: {}): a hash which is passed to create_resoure(knot::remote, $remotes)
* `ip_addresses` (Array, Default: [$::ipaddress]): Array of IP addresses to listen on.
* `identity` (String, Default: $::fqdn): A string to specify the identity when asked for CH TXT ID.SERVER
* `nsid` (String, Default: $::fqdn): A string representing the nsid to add to the EDNS section of the answer when queried with an NSID EDNS enabled packet.
* `log_target` (Knot::Log_target, Default: syslog): where to send logs.
* `log_zone_level` (Knot::Log_level, Default: notice): Log level for zone messages
* `log_server_level` (Knot::Log_level, Default: info): Log level for server messages
* `log_any_level` (Knot::Log_level, Default: error): Log level for any messages
* `server_count (Integer. Default: $::processorcount)`:  Start this many KNOT workers.
* `max_tcp_clients` (Integer, Default: 250):  The maximum number of concurrent, active TCP connections by each server. valid options: Integer.
* `max_udp_payload` (Integer < 4097, Default: 4096): Preferred EDNS buffer size.
* `pidfile` (Tea::Absolutepath, Default: OS Specific): Use the pid file.
* `port` (Tea::Port, Default: 53): Port to listen on.
* `username` (String, Default: knot): After binding the socket, drop user privileges and assume the username.
* `zonesdir` (Tea::Absolutepath, Default: OS Specific): The data directory
* `hide_version`: (Boolean, Default: false): Prevent KNOT from replying with the version string on CHAOS class queries.
* `rrl_size`: (Integet, Default: 1000000): This option gives the size of the  hashtable.
* `rrl_limit` (Integer, Default: 200):  The max qps allowed.
* `rrl_slip` (Integer, Default: 2): This option controls the number of packets discarded before we send back a SLIP response
* `control_enable` (Bool, Default: false): Enable remote control
* `control_interface` (Array, Default: undef): the interfaces for remote control service 
* `control_port` (Tea::Port, Default: 8952): the port number for remote control service 
* `package_name` (String, Default: OS Specific): The package to install
* `service_name` (String, Default: OS Specific): The service to manage
* `zone_subdir` (Tea::Absolutepath, Default: OS Specific): The zone directory
* `conf_file` (File Path, Default: OS Specific): The config file
* `puppetdb_server` (Tea::Ip_address, Default: '127.0.0.1'): the ip address of the puppet database server.  This is only used for exported resources and the script that uses it runs from the puppet master server.  So in a monalithic install localhost should be fine.  None monolithic installs will need some way of allowing this connection from the master
* `puppetdb_port` (Tea::Port, Default: 8080): the port of the puppet database server unencrypted API interface.  This is only used for exported resources and the script that uses it runs from the puppet master server.  So in a monalithic install localhost should be fine.  None monolithic installs will need some way of allowing this connection from the master
* `network_status` (File Path, Default: undef): if present the upstart script will halt untill this script exits with 0.  used to ensure the network is up before starting knot.  [ upstarts network started trigger fires when the first interface is configuered so knot might not start at boot if you have multible addresses on the same interface] 
* `server_template` (File Path, Default: 'knot/etc/knot/knot.server.conf.'): template file to use for server config.  only change if you know what you are doing.
* `zones_template` (File Path, Default: 'knot/etc/knot/knot.zones.conf.erb'): template file to use for zone config.  only change if you know what you are doing.
* `remotes_template` (File Path, Default: 'knot/etc/knot/knot.remotes.conf.erb'): template file to use for zone config.  only change if you know what you are doing.
* `groups_template` (File Path, Default: 'knot/etc/knot/knot.groups.conf.erb'): template file to use for zone config.  only change if you know what you are doing.
* `groups_slave_temp` (File Path, Default: 'knot/etc/knot/knot.groups_slave.conf.erb'): template file to use for zone config.  only change if you know what you are doing.

### Private Classes

#### Class `knot::params`

Set os specific parameters

### Private Defined Types

#### Defined `knot::file`

Manage files used by knot

##### Parameters 

* `ensure` (File Path: Default 'present'): how to ensure the file
* `owner` (String: Default root): the owner of the file
* `group` (String: Default knot): the group of the file
* `mode` (String /^\d+$/: Default '0640'): the mode of the file
* `source` (File Path: Default undef): the source location of the file
* `content` (string: Default undef): the content to liad to the file
* `content_template` (File Path: Default undef): the template location 

#### Defined `knot::tsig`

Manage tsig keys used by knot

##### Parameters 

* `algo` (String '^hmac-sha(1|224|256|384|512)$' or '^hmac-md5$', Default: 'hmac-sha256' ): The tsig algorithem of the key
* `data` (String, Required: true): The tsig key information
* `template` (Path, Default: 'knot/etc/knot/knot.key.conf.erb'): template to use for tsig config

#### Defined `knot::zone`

Manage a zone set conifg for knot

##### Parameters 

* `masters` (Array, Default: []): List of master server to configure
* `notify_addresses` (Array, Default: []): List of serveres to notify
* `allow_notify` (Array, Default: []): List of servers allowed to notify
* `provide_xfr` (Array, Default: []): List of servers allowed to preform xfr
* `zones` (Array, Default: []): List of zones with this configueration
* `zonefile` (String, Default: undef): zonefile name, (will be used for all zones)
* `zone_dir` (File Path, Default: undef): override default zone path

#### Defined `knot::remote`

used to define remote serveres these are used later to configure the system

##### Parameters

* `address4` (Optional[Variant[Tea::Ipv4, Tea::Ipv4_cidr]]): ipv4 address or prefix for this remote
* `address6` (Optional[Variant[Tea::Ipv6, Tea::Ipv6_cidr]]): ipv6 address or prefix for this remote
* `tsig_name`: (Optional[String]): nsd::tsig to use
* `port`: (Tea::Port, Default: 53): port use to talk to remote.

### Facts

#### Fact `knot_version`

Determins the version of knot by parsing the output of `knot -v`

## Limitations

This module has been tested on:

* Ubuntu 14.04
* FreeBSD 10

## Development

Pull requests welcome but please also update documentation and tests.
