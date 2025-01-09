# @summary  Knot DNS server module
# @param knotc_bin Path to knotc binary
# @param default_tsig_name Default TSIG key name
# @param default_masters Default masters
# @param default_provide_xfrs Default provide-xfrs
# @param enable Enable the service
# @param tsig TSIG keys
# @param zones Zones
# @param tsigs TSIG keys
# @param files Files
# @param remotes Remotes
# @param ip_addresses IP addresses
# @param identity Identity
# @param nsid NSID
# @param log_target Log target
# @param log_target_path Log target path
# @param log_target_file Log target file
# @param log_zone_level Log zone level
# @param log_server_level Log server level
# @param log_any_level Log any level
# @param server_count Server count
# @param tcp_workers TCP workers
# @param udp_workers UDP workers
# @param background_workers Background workers
# @param async_start Async start
# @param tcp_idle_timeout TCP idle timeout
# @param tcp_io_timeout TCP IO timeout
# @param tcp_remote_io_timeout TCP remote IO timeout
# @param tcp_reuseport TCP reuseport
# @param tcp_fastopen TCP fastopen
# @param tcp_max_clients TCP max clients
# @param udp_max_payload UDP max payload
# @param udp_max_payload_ipv4 UDP max payload IPv4
# @param udp_max_payload_ipv6 UDP max payload IPv6
# @param socket_affinity Socket affinity
# @param edns_client_subnet EDNS client subnet
# @param answer_rotation Answer rotation
# @param pidfile PID file
# @param port Port
# @param username Username
# @param zonesdir Zones directory
# @param kzonecheck_bin Path to kzonecheck binary
# @param hide_version Hide version
# @param version Version
# @param rrl_enable RRL enable
# @param rrl_size RRL size
# @param rrl_limit RRL limit
# @param rrl_slip RRL slip
# @param control_enable Control enable
# @param control_interface Control interface
# @param control_port Control port
# @param control_allow Control allow
# @param package_name Package name
# @param service_name Service name
# @param restart_cmd Restart command
# @param conf_dir Configuration directory
# @param zone_subdir Zone subdirectory
# @param conf_file Configuration file
# @param run_dir Run directory
# @param validate_cmd Validate command
# @param network_status Network status
# @param puppetdb_server PuppetDB server
# @param puppetdb_port PuppetDB port
# @param exports Exports
# @param imports Imports
# @param logrotate_enable Logrotate enable
# @param logrotate_rotate Logrotate rotate
# @param logrotate_size Logrotate size
# @param database_path Database path
class knot (
  Stdlib::Unixpath                 $knotc_bin            = '/usr/sbin/knotc',
  String                           $default_tsig_name     = 'NOKEY',
  Array[String]                    $default_masters       = [],
  Array[String]                    $default_provide_xfrs  = [],
  Boolean                          $enable                = true,
  Hash                             $tsig                  = {},
  Hash                             $zones                 = {},
  Hash                             $tsigs                 = {},
  Hash                             $files                 = {},
  Hash                             $remotes               = {},
  Array[Stdlib::IP::Address]       $ip_addresses          = [$facts['networking']['ip']],
  String                           $identity              = $facts['networking']['fqdn'],
  String                           $nsid                  = $facts['networking']['fqdn'],
  Knot::Log_target                 $log_target            = 'syslog',
  Optional[Stdlib::Unixpath]       $log_target_path       = undef,
  String                           $log_target_file       = 'knot.log',
  Knot::Log_level                  $log_zone_level        = 'notice',
  Knot::Log_level                  $log_server_level      = 'info',
  Knot::Log_level                  $log_any_level         = 'error',
  Integer[1,255]                   $server_count          = $facts['processors']['count'],
  Optional[Integer[1,255]]         $tcp_workers           = undef,
  Optional[Integer[1,255]]         $udp_workers           = undef,
  Integer[1,255]                   $background_workers    = 1,
  Knot::On_off                     $async_start           = 'off',
  Integer                          $tcp_idle_timeout      = 10,
  Integer                          $tcp_io_timeout        = 500,
  Integer                          $tcp_remote_io_timeout = 5000,
  Knot::On_off                     $tcp_reuseport         = 'off',
  Knot::On_off                     $tcp_fastopen          = 'off',
  Integer                          $tcp_max_clients       = 250,
  Integer[512,4096]                $udp_max_payload       = 4096,
  Integer[512,4096]                $udp_max_payload_ipv4  = 4096,
  Integer[512,4096]                $udp_max_payload_ipv6  = 4096,
  Knot::On_off                     $socket_affinity       = 'off',
  Knot::On_off                     $edns_client_subnet    = 'off',
  Knot::On_off                     $answer_rotation       = 'off',
  Stdlib::Port                     $port                  = 53,
  String                           $username              = 'knot',
  Stdlib::Unixpath                 $kzonecheck_bin        = '/usr/bin/kzonecheck',
  Boolean                          $hide_version          = false,
  Optional[String]                 $version               = undef,
  Boolean                          $rrl_enable            = true,
  Integer                          $rrl_size              = 1000000,
  Integer                          $rrl_limit             = 200,
  Integer                          $rrl_slip              = 2,
  Boolean                          $control_enable        = true,
  Stdlib::IP::Address              $control_interface     = '127.0.0.1',
  Stdlib::Port                     $control_port          = 5533,
  Hash[String,Stdlib::IP::Address] $control_allow         = { 'localhost_remote' => '127.0.0.1' },
  String                           $package_name          = 'knot',
  String                           $service_name          = 'knot',
  String                           $restart_cmd           = "${knotc_bin} reload || ${knotc_bin} conf-check && service knot restart",
  Stdlib::Unixpath                 $conf_dir              = '/etc/knot',
  Stdlib::Unixpath                 $run_dir               = '/run/knot',
  Stdlib::Unixpath                 $pidfile               = "${run_dir}/knot.pid",
  Stdlib::Unixpath                 $zonesdir              = "${conf_dir}/zone",
  Stdlib::Unixpath                 $zone_subdir           = "${zonesdir}/zone",
  Stdlib::Unixpath                 $conf_file             = "${conf_dir}/knot.conf",
  String                           $validate_cmd          = "${knotc_bin} -c % conf-check",
  Optional[Stdlib::Unixpath]       $network_status        = undef,
  Stdlib::IP::Address              $puppetdb_server       = '127.0.0.1',
  Stdlib::Port                     $puppetdb_port         = 8080,
  Array[String]                    $exports               = [],
  Array[String]                    $imports               = [],
  Boolean                          $logrotate_enable      = true,
  Integer                          $logrotate_rotate      = 5,
  String                           $logrotate_size        = '100M',
  Stdlib::Unixpath                 $database_path         = '/var/lib/knot',
) {
  $server_template  = 'knot/etc/knot/knot.server.conf.erb'
  $key_template     = 'knot/etc/knot/knot.key.conf.erb'
  $zones_template   = 'knot/etc/knot/knot.zones.conf.erb'
  $remotes_template = 'knot/etc/knot/knot.remotes.conf.erb'
  $acl_template     = 'knot/etc/knot/knot.acl.conf.erb'
  $concat_head      = ":\n"
  $concat_foot      = "\n"
  $acl_head         = "acl:\n"
  $acl_foot         = $concat_foot

  $use_mod_rrl = !(defined('$knot_version') and versioncmp('$knot_version', '2.4') < 0)

  $exported_remotes = empty($imports) ? {
    true    => [],
    default => knot::get_exported_titles($imports),
  }
  ensure_packages($package_name)

  concat { $conf_file:
    require      => Package[$package_name],
    notify       => Service[$service_name],
    validate_cmd => $validate_cmd,
  }

  concat::fragment { 'key_head':
    target  => $conf_file,
    content => "key${concat_head}",
    order   => '01',
  }
  concat::fragment { 'key_foot':
    target  => $conf_file,
    content => $concat_foot,
    order   => '03',
  }
  concat::fragment { 'knot_server':
    target  => $conf_file,
    content => template($server_template),
    order   => '10',
  }
  concat::fragment { 'remote_head':
    target  => $conf_file,
    content => "remote${concat_head}",
    order   => '11',
  }
  concat::fragment { 'remote_foot':
    target  => $conf_file,
    content => $concat_foot,
    order   => '13',
  }
  concat::fragment { 'acl_head':
    target  => $conf_file,
    content => $acl_head,
    order   => '14',
  }
  concat::fragment { 'acl_foot':
    target  => $conf_file,
    content => $acl_foot,
    order   => '16',
  }
  concat::fragment { 'zones_head':
    target  => $conf_file,
    content => "zone${concat_head}",
    order   => '21',
  }
  concat::fragment { 'zones_foot':
    target  => $conf_file,
    content => $concat_foot,
    order   => '23',
  }
  file {
    default:
      ensure  => directory,
      owner   => $username,
      group   => $username,
      require => Package[$package_name];
    [$database_path, "${database_path}/timers"]:
      ;
    [$zonesdir, $zone_subdir, $conf_dir].unique():
      mode    => '0750';
    $run_dir:
      mode    => '0775';
  }
  if $log_target_path {
    file { $log_target_path:
      ensure => directory,
      mode   => '0775',
      owner  => $username,
      group  => $username,
    }
    if $logrotate_enable {
      logrotate::rule { 'knot':
        path       => "${log_target_path}/${log_target_file}",
        rotate     => $logrotate_rotate,
        size       => $logrotate_size,
        compress   => true,
        postrotate => "/usr/sbin/service ${service_name} restart",
      }
    }
  }
  service { $service_name:
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
