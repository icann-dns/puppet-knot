#== Class: knot
#
class knot (
  Optional[String]               $fetch_tsig_name = undef,
  Optional[String]               $provide_tsig_name = undef,
  Boolean                        $enable            = true,
  Hash                           $tsig              = {},
  Hash                           $slave_addresses   = {},
  Hash                           $zones             = {},
  Hash                           $tsigs             = {},
  Hash                           $files             = {},
  Hash[String, Knot::Server]     $servers           = {},
  Array[Tea::Ip_addresses]       $ip_addresses      = $::knot::params::ip_addresses,
  String                         $identity          = $::knot::params::identity,
  String                         $nsid              = $::knot::params::nsid,
  Knot::Log_target               $log_target        = 'syslog',
  Knot::Log_level                $log_zone_level    = 'notice',
  Knot::Log_level                $log_server_level  = 'info',
  Knot::Log_level                $log_any_level     = 'error',
  Integer[1,255]                 $server_count      = $::knot::params::server_count,
  Integer                        $max_tcp_clients   = 250,
  Integer[512,4096]              $max_udp_payload   = 4096,
  Tea::Absolutepath              $pidfile           = $::knot::params::pidfile,
  Tea::Port                      $port              = 53,
  String                         $username          = 'knot',
  Tea::Absolutepath              $zonesdir          = $::knot::params::zonesdir,
  Boolean                        $hide_version      = false,
  Integer                        $rrl_size          = 1000000,
  Integer                        $rrl_limit         = 200,
  Integer                        $rrl_slip          = 2,
  Boolean                        $control_enable    = true,
  Tea::Ip_addresses              $control_interface = '127.0.0.1',
  Tea::Port                      $control_port      = 5533,
  Hash[String,Tea::Ip_addresses] $control_allow     = {'localhost' => '127.0.0.1'},
  String                         $package_name      = $::knot::params::package_name,
  String                         $service_name      = 'knot',
  Tea::Absolutepath              $conf_dir          = $::knot::params::conf_dir,
  Tea::Absolutepath              $zone_subdir       = $::knot::params::zone_subdir,
  Tea::Absolutepath              $conf_file         = $::knot::params::conf_file,
  Tea::Absolutepath              $run_dir           = $::knot::params::run_dir,
  Boolean                        $manage_nagios     = false,
  Optional[Tea::Absolutepath]    $network_status    = undef,
  String                  $server_template   = 'knot/etc/knot/knot.server.conf.erb',
  String                  $zones_template    = 'knot/etc/knot/knot.zones.conf.erb',
) inherits knot::params  {

  if $::kernel == 'linux' and $::lsbdistcodename == 'precise' {
    fail('knot is not currently supported on ubuntu precise')
  }
  ensure_packages($package_name)
  concat{$conf_file:
    require => Package[$package_name],
    notify  => Service[$service_name];
  }
  concat::fragment{'key_head':
    target  => $conf_file,
    content => "keys {\n",
    order   => '01',
  }
  concat::fragment{'key_foot':
    target  => $conf_file,
    content => "}\n",
    order   => '03',
  }
  concat::fragment{'knot_server':
    target  => $conf_file,
    content => template($server_template),
    order   => '10',
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
    require => Package[$package_name],
  }
  create_resources(knot::file, $files)
  create_resources(knot::tsig, $tsigs)
  if $fetch_tsig_name and ! defined(Knot::Tsig($fetch_tsig_name)) {
    fail("Knot::Tsig['${fetch_tsig_name}'] does not exist")
  }
  if $provide_tsig_name and ! defined(Knot::Tsig($provide_tsig_name)) {
    fail("Knot::Tsig['${provide_tsig_name}'] does not exist")
  }
  $servers.each |String $server, Knot::Server $config| {
    if has_key($config, 'fetch_tsig_name') {
      $key = $config['fetch_tsig_name']
      if ! defined(Knot::Tsig[$key]) {
          fail("Knot::Tsig['${key}'], defined in knot::server['${server}'] does not exist")
      }
    }
    if has_key($config, 'provide_tsig_name') {
      $key = $config['provide_tsig_name']
      if ! defined(Knot::Tsig[$key]) {
          fail("Knot::Tsig['${key}'], defined in knot::server['${server}'] does not exist")
      }
    }
  }
  create_resources(knot::zone, $zones)
}
