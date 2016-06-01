[![Build Status](https://travis-ci.org/icann-dns/puppet-knot.svg?branch=master)](https://travis-ci.org/icann-dns/puppet-knot)
[![Puppet Forge](https://img.shields.io/puppetforge/v/icann/knot.svg?maxAge=2592000)](https://forge.puppet.com/icann/knot)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/icann/knot.svg?maxAge=2592000)](https://forge.puppet.com/icann/knot)
# knot

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

Manage the installation and configuration of KNOT (name serve daemon) and zone files.

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

* depends on stdlib 4.11.0 (may work with earlier versions)

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
  tsig => {
    'name' => 'test',
    'algo' => 'hmac-sha256',
    'data' => 'adsasdasdasd='
  }
}
```

or with hiera

```yaml
knot::tsig:
  name: test
  algo: hmac-sha256
  data: adsasdasdasd=
```

add zone files.  zone files are added with sets of common config.

```puppet
class {'::knot': 
  zones => {
    'master1_zones' => {
      'allow_notify' => ['192.0.2.1'],
      'masters'      => ['192.0.2.1'],
      'provide_xfr'  => ['127.0.0.1'],
      'zones'        => ['example.com', 'example.net']
    },
    'master2_zones'  => {
      'allow_notify' => ['192.0.2.2'],
      'masters'      => ['192.0.2.2'],
      'provide_xfr'  => ['127.0.0.2'],
      'zones'        => ['example.org']
    }
  }
}
```

in hiera

```yaml
knot::zones:
  master1_zones:
    allow_notify:
    - 192.0.2.1
    masters:
    - 192.0.2.1
    provide_xfr:
    - 192.0.2.1
    zones:
    - example.com
    - example.net
  master2_zones:
    allow_notify:
    - 192.0.2.2
    masters:
    - 192.0.2.2
    provide_xfr:
    - 192.0.2.2
    zones:
    - example.org
```

creat and as112 server also uses the knot::file resource

```puppet
  class {'::knot': }
  knot::zone {
    'rfc1918': 
      'zonefile' => 'db.dd-empty',
      'zones' => [
        '10.in-addr.arpa',
        '16.172.in-addr.arpa',
        '17.172.in-addr.arpa',
        '18.172.in-addr.arpa',
        '19.172.in-addr.arpa',
        '20.172.in-addr.arpa',
        '21.172.in-addr.arpa',
        '22.172.in-addr.arpa',
        '23.172.in-addr.arpa',
        '24.172.in-addr.arpa',
        '25.172.in-addr.arpa',
        '26.172.in-addr.arpa',
        '27.172.in-addr.arpa',
        '28.172.in-addr.arpa',
        '29.172.in-addr.arpa',
        '30.172.in-addr.arpa',
        '31.172.in-addr.arpa',
        '168.192.in-addr.arpa',
        '254.169.in-addr.arpa'
      ];
    'empty.as112.arpa':
      'zonefile' => 'db.dr-empty',
      'zones'    => ['empty.as112.arpa'];
    'hostname.as112.net':
      'zonefile' => 'hostname.as112.net.zone',
      'zones'    =>  ['hostname.as112.net'];
    'hostname.as112.arpa':
      'zonefile' => 'hostname.as112.arpa.zone',
      'zones'    => ['hostname.as112.arpa'];
  }
  knot::file {
    'db.dd-empty':
      source  => 'puppet:///modules/knot/etc/knot/db.dd-empty';
    'db.dr-empty':
      source  => 'puppet:///modules/knot/etc/knot/db.dr-empty';
    'hostname.as112.net.zone':
      content_template => 'knot/etc/knot/hostname.as112.net.zone.erb';
    'hostname.as112.arpa.zone':
      content_template => 'knot/etc/knot/hostname.as112.arpa.zone.erb';
  }
```

```yaml
knot::files:
  db.dd-empty:
    source: 'puppet:///modules/knot/etc/knot/db.dd-empty'
  db.dr-empty:
    source: 'puppet:///modules/knot/etc/knot/db.dr-empty'
  hostname.as112.net.zone:
    content_template: 'knot/etc/knot/hostname.as112.net.zone.erb'
  hostname.as112.arpa.zone:
    content_template: 'knot/etc/knot/hostname.as112.arpa.zone.erb'
knot::zones:
  rfc1918:
    zonefile: db.dd-empty
    zones:
    - 10.in-addr.arpa
    - 16.172.in-addr.arpa
    - 17.172.in-addr.arpa
    - 18.172.in-addr.arpa
    - 19.172.in-addr.arpa
    - 20.172.in-addr.arpa
    - 21.172.in-addr.arpa
    - 22.172.in-addr.arpa
    - 23.172.in-addr.arpa
    - 24.172.in-addr.arpa
    - 25.172.in-addr.arpa
    - 26.172.in-addr.arpa
    - 27.172.in-addr.arpa
    - 28.172.in-addr.arpa
    - 29.172.in-addr.arpa
    - 30.172.in-addr.arpa
    - 31.172.in-addr.arpa
    - 168.192.in-addr.arpa
    - 254.169.in-addr.arpa
  'empty.as112.arpa':
    zonefile: db.dr-empty
    zones:
    - empty.as112.arpa
  'hostname.as112.net':
    zonefile: hostname.as112.net.zone
    zones:
    - hostname.as112.net
  'hostname.as112.arpa':
    zonefile: hostname.as112.arpa.zone
    zones:
    - hostname.as112.arpa
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
- [**Facts**](#facts)
    - ['knot_version'](#fact-knotversion)

### Classes

### Public Classes

#### Class: `knot`
  Guides the basic setup and installation of KNOT on your system
  
##### Parameters (all optional)

* `enable` (Bool, Default: true): enable or disable the knot service, config files are still configuered.
* `tsig` { name => '', algo => '', data => '' }: primary tsig for legecy reasons this doesnt use knot::tsig (i intend to fix that)
* `slave_addresses` (Hash, Default: {}): a hash key value pairs representing ip address tsig key name values.  e.g. { '192.0.2.1' : 'tsig-key' }.
* `zones`: a hash which is passed to create_resoure(knot::zone, $zones). Default: Empty.
* `files` (Hash, Default: {}):  a hash which is passed to create_resoure(knot::file, $files).
* `tsigs` (Hash, Default: {}): a hash which is passed to create_resoure(knot::tsig, $tsigs)
* `server_template` (File Path, Default: 'knot/etc/knot/knot.server.conf.'): template file to use for server config.  only change if you know what you are doing.
* `zones_template` (File Path, Default: 'knot/etc/knot/knot.zones.conf.erb'): template file to use for zone config.  only change if you know what you are doing.
* `ip_addresses` (Array, Default: [$::ipaddress]): Array of IP addresses to listen on.
* `identity` (String, Default: $::fqdn): A string to specify the identity when asked for CH TXT ID.SERVER
* `nsid` (String, Default: $::fqdn): A string representing the nsid to add to the EDNS section of the answer when queried with an NSID EDNS enabled packet.
* `log_target` (File Path or /^(stdout|stderr|syslog)$/, Default: syslog): where to send logs.
* `server_count (Integer. Default: $::processorcount)`:  Start this many KNOT workers.
* `max_tcp_clients` (Integer, Default: 250):  The maximum number of concurrent, active TCP connections by each server. valid options: Integer.
* `max_udp_payload` (Integer < 4097, Default: 4096): Preferred EDNS buffer size.
* `pidfile` (File Path, Default: OS Specific): Use the pid file.
* `port` (Integer < 65536, Default: 53): Port to listen on.
* `username` (String, Default: knot): After binding the socket, drop user privileges and assume the username.
* `zonesdir` (File Path, Default: OS Specific): The data directory
* `hide_version`: Prevent KNOT from replying with the version string on CHAOS class queries. Valid Optional: bool. Default: false
* `rrl_size`: This option gives the size of the  hashtable. Valid Optional Integer. Default: 1000000
* `rrl_limit` (Integer, Default:200):  The max qps allowed.
* `rrl_slip` (Integer=2): This option controls the number of packets discarded before we send back a SLIP response
* `control_enable` (Bool, Default: false): Enable remote control
* `control_interface` (Array, Default: undef): the interfaces for remote control service 
* `control_port` (Integer < 65536, Default: 8952): the port number for remote control service 
* `package_name` (String, Default: OS Specific): The package to install
* `service_name` (String, Default: OS Specific): The service to manage
* `zone_subdir` (File Path, Default: OS Specific): The zone directory
* `conf_file` (File Path, Default: OS Specific): The config file
* `network_status` (File Path, Default: undef): if present the upstart script will halt untill this script exits with 0.  used to ensure the network is up before starting knot.  [ upstarts network started trigger fires when the first interface is configuered so knot might not start at boot if you have multible addresses on the same interface] 
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

### Facts

#### Fact `knot_version`

Determins the version of knot by parsing the output of `knot -v`

## Limitations

This module has been tested on:

* Ubuntu 12.04, 14.04
* FreeBSD 10

## Development

Pull requests welcome but please also update documentation and tests.
