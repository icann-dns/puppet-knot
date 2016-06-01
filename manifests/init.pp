#== Class: knot
#
class knot (
  $enable            = true,
  $tsig              = {},
  $slave_addresses   = {},
  $zones             = {},
  $tsigs             = {},
  $files             = {},
  $server_template   = 'knot/etc/knot/knot.server.conf.erb',
  $zones_template    = 'knot/etc/knot/knot.zones.conf.erb',
  $ip_addresses      = $::knot::params::ip_addresses,
  $identity          = $::knot::params::identity,
  $nsid              = $::knot::params::nsid,
  $log_target        = 'syslog',
  $log_zone_level    = 'notice',
  $log_server_level  = 'info',
  $log_any_level     = 'error',
  $server_count      = $::knot::params::server_count,
  $max_tcp_clients   = 250,
  $max_udp_payload   = 4096,
  $pidfile           = $::knot::params::pidfile,
  $port              = 53,
  $username          = 'knot',
  $zonesdir          = $::knot::params::zonesdir,
  $hide_version      = false,
  $rrl_size          = 1000000,
  $rrl_limit         = 200,
  $rrl_slip          = 2,
  $control_enable    = true,
  $control_interface = '127.0.0.1',
  $control_port      = 5533,
  $control_allow     = { 'localhost' => '127.0.0.1' },
  $package_name      = $::knot::params::package_name,
  $service_name      = 'knot',
  $conf_dir          = $::knot::params::conf_dir,
  $zone_subdir       = $::knot::params::zone_subdir,
  $conf_file         = $::knot::params::conf_file,
  $run_dir           = $::knot::params::run_dir,
  $network_status    = undef
) inherits knot::params  {

  validate_bool($enable)
  validate_hash($tsig)
  validate_hash($slave_addresses)
  validate_hash($zones)
  validate_hash($tsigs)
  validate_hash($files)
  validate_absolute_path("/${server_template}")
  validate_absolute_path("/${zones_template}")
  validate_array($ip_addresses)
  validate_string($identity)
  validate_string($nsid)
  if ! is_absolute_path($log_target) {
    validate_re($log_target, '^(stdout|stderr|syslog)$',
        'log target must be a file path, stdout, stderr or syslog' )
  }
  validate_re($log_zone_level, '^(debug|info|notice|warning|error|critical)$')
  validate_re($log_server_level, '^(debug|info|notice|warning|error|critical)$')
  validate_re($log_any_level, '^(debug|info|notice|warning|error|critical)$')
  validate_integer($server_count)
  validate_integer($max_tcp_clients)
  validate_integer($max_udp_payload, 65535)
  validate_integer($port, 65535)
  validate_string($username)
  validate_absolute_path($zonesdir)
  validate_bool($hide_version)
  validate_integer($rrl_limit)
  validate_integer($rrl_size)
  validate_integer($rrl_slip)
  validate_bool($control_enable)
  validate_ip_address($control_interface)
  validate_integer($control_port, 65535)
  validate_hash($control_allow)
  validate_string($package_name)
  validate_string($service_name)
  validate_absolute_path($conf_dir)
  validate_absolute_path($zone_subdir)
  validate_absolute_path($conf_file)
  validate_absolute_path($run_dir)
  validate_absolute_path($pidfile)
  if $network_status {
    validate_absolute_path($network_status)
  }

  if $::kernel == 'linux' and $::lsbdistcodename == 'precise' {
    fail('knot is not currently supported on ubuntu precise')
  }
  ensure_packages($package_name)
  concat{$conf_file:
    require => Package[$package_name],
    notify  => Service[$service_name];
  }
  concat::fragment{'knot_server':
    target  => $conf_file,
    content => template($server_template),
    order   => '01',
  }
  concat::fragment{'key_head':
    target  => $conf_file,
    content => "keys {\n",
    order   => '09',
  }
  concat::fragment{'key_foot':
    target  => $conf_file,
    content => "}\n",
    order   => '11',
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
  #add backwords compatible
  if ! empty($tsig) {
    knot::tsig {$tsig['name']:
      algo => $tsig['algo'],
      data => $tsig['data'],
    }
  }
  create_resources(nsd::file, $files)
  create_resources(nsd::tsig, $tsigs)
  create_resources(knot::zone, $zones)
}
