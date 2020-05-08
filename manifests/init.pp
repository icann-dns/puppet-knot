#== Class: knot
#
class knot (
  String                       $default_tsig_name    = 'NOKEY',
  Array[String]                $default_masters      = [],
  Array[String]                $default_provide_xfrs = [],
  Boolean                      $enable               = true,
  Hash                         $tsig                 = {},
  Hash                         $zones                = {},
  Hash                         $tsigs                = {},
  Hash                         $files                = {},
  Hash                         $remotes              = {},
  Array[Tea::Ip_address]       $ip_addresses         = $::knot::params::ip_addresses,
  String                       $identity             = $::knot::params::identity,
  String                       $nsid                 = $::knot::params::nsid,
  Knot::Log_target             $log_target           = 'syslog',
  Knot::Log_level              $log_zone_level       = 'notice',
  Knot::Log_level              $log_server_level     = 'info',
  Knot::Log_level              $log_any_level        = 'error',
  Integer[1,255]               $server_count         = $::knot::params::server_count,
  Integer                      $max_tcp_clients      = 250,
  Integer[512,4096]            $max_udp_payload      = 4096,
  Tea::Absolutepath            $pidfile              = $::knot::params::pidfile,
  Tea::Port                    $port                 = 53,
  String                       $username             = 'knot',
  Tea::Absolutepath            $zonesdir             = $::knot::params::zonesdir,
  Tea::Absolutepath            $kzonecheck_bin       = $::knot::params::kzonecheck_bin,
  Boolean                      $hide_version         = false,
  Boolean                      $rrl_enable           = true,
  Integer                      $rrl_size             = 1000000,
  Integer                      $rrl_limit            = 200,
  Integer                      $rrl_slip             = 2,
  Boolean                      $control_enable       = true,
  Tea::Ip_address              $control_interface    = '127.0.0.1',
  Tea::Port                    $control_port         = 5533,
  Hash[String,Tea::Ip_address] $control_allow        = {'localhost_remote' => '127.0.0.1'},
  String                       $package_name         = $::knot::params::package_name,
  String                       $service_name         = 'knot',
  String                       $restart_cmd          = $::knot::params::restart_cmd,
  Tea::Absolutepath            $conf_dir             = $::knot::params::conf_dir,
  Tea::Absolutepath            $zone_subdir          = $::knot::params::zone_subdir,
  Tea::Absolutepath            $conf_file            = $::knot::params::conf_file,
  Tea::Absolutepath            $run_dir              = $::knot::params::run_dir,
  String                       $validate_cmd         = $::knot::params::validate_cmd,
  Optional[Tea::Absolutepath]  $network_status       = undef,
  Tea::Ip_address              $puppetdb_server      = '127.0.0.1',
  Tea::Port                    $puppetdb_port        = 8080,
  Array[String]                $exports              = [],
  Array[String]                $imports              = [],
) inherits knot::params  {

  $server_template   = $::knot::params::server_template
  $key_template      = $::knot::params::key_template
  $zones_template    = $::knot::params::zones_template
  $remotes_template  = $::knot::params::remotes_template
  $acl_template      = $::knot::params::acl_template
  $acl_head          = $::knot::params::acl_head
  $acl_foot          = $::knot::params::acl_foot
  $concat_head       = $::knot::params::concat_head
  $concat_foot       = $::knot::params::concat_foot
  $force_knot1       = $::knot::params::force_knot1
  if defined('$knot_version') and versioncmp('$knot_version', '2.4') < 0 {
    $use_mod_rrl = false
  } else {
    $use_mod_rrl = true
  }

  if $force_knot1 and $::kernel == 'Linux' {
    apt::pin{'00knot1':
      packages => 'knot',
      version  => '1.*',
      priority => 1001,
    }
  }

  $exported_remotes = empty($imports) ? {
    true    => [],
    default => knot::get_exported_titles($imports),
  }
  ensure_packages($package_name)

  concat{$conf_file:
    require      => Package[$package_name],
    notify       => Service[$service_name],
    validate_cmd => $validate_cmd,
  }

  concat::fragment{'key_head':
    target  => $conf_file,
    content => "key${concat_head}",
    order   => '01',
  }
  concat::fragment{'key_foot':
    target  => $conf_file,
    content => $concat_foot,
    order   => '03',
  }
  concat::fragment{'knot_server':
    target  => $conf_file,
    content => template($server_template),
    order   => '10',
  }
  concat::fragment{'remote_head':
    target  => $conf_file,
    content => "remote${concat_head}",
    order   => '11',
  }
  concat::fragment{'remote_foot':
    target  => $conf_file,
    content => $concat_foot,
    order   => '13',
  }
  concat::fragment{'acl_head':
    target  => $conf_file,
    content => $acl_head,
    order   => '14',
  }
  $_acl_foot = $acl_foot ? {
    $concat_foot => $acl_foot,
    default => template($acl_foot)
  }
  concat::fragment{'acl_foot':
    target  => $conf_file,
    content => $_acl_foot,
    order   => '16',
  }
  concat::fragment{'zones_head':
    target  => $conf_file,
    content => "zone${concat_head}",
    order   => '21',
  }
  concat::fragment{'zones_foot':
    target  => $conf_file,
    content => $concat_foot,
    order   => '23',
  }
  file { [$zonesdir, $zone_subdir, $conf_dir]:
    ensure  => directory,
    mode    => '0750',
    owner   => $username,
    group   => $username,
    require => Package[$package_name],
  }
  file { [$run_dir]:
    ensure  => directory,
    mode    => '0775',
    owner   => $username,
    group   => $username,
    require => Package[$package_name],
  }
  if $::kernel == 'Linux' {
    file{'/etc/init/knot.conf':
      ensure  => present,
      content => template('knot/etc/init/knot.conf.erb'),
      require => Package[$package_name],
      notify  => Service[$service_name];
    }
  } elsif $::kernel == 'FreeBSD' {
    file{'/etc/rc.conf.d/knot':
      ensure => present,
    } -> file_line{'add knot conf file':
      path => '/etc/rc.conf.d/knot',
      line => "config=\"${conf_file}\"",
    }
  }
  service {$service_name:
    ensure  => $enable,
    enable  => $enable,
    restart => $restart_cmd,
    require => Package[$package_name],
  }
  create_resources(knot::file, $files)
  create_resources(knot::tsig, $tsigs)
  if ! defined(Knot::Tsig[$default_tsig_name]) and $default_tsig_name != 'NOKEY' {
    fail("Knot::Tsig['${default_tsig_name}'] does not exist")
  }
  create_resources(knot::remote, $remotes)
  $default_masters.each |String $master| {
    if ! defined(Knot::Remote[$master]) {
      fail("Knot::Remote['${master}'] does not exist but defined as default master")
    }
  }
  $default_provide_xfrs.each |String $provider_xfr| {
    if ! defined(Knot::Remote[$provider_xfr]) {
      fail("Knot::Remote['${provider_xfr}'] does not exist but defined as default master")
    }
  }
  create_resources(knot::zone, $zones)
}
