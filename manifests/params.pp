#== Class: knot
#
class knot::params {
  case $::kernel {
    'FreeBSD': {
      $package_name    = 'knot1'
      $conf_dir        = '/usr/local/etc/knot'
      $run_dir         = '/var/run/knot'
      $restart_command = '/usr/local/sbin/knotc reload'
    }
    default: {
      $package_name    = 'knot'
      $conf_dir        = '/etc/knot'
      $run_dir         = '/run/knot'
      $restart_command = '/usr/sbin/knotc reload'
    }
  }
  $ip_addresses = [$::ipaddress]
  $conf_file    = "${conf_dir}/knot.conf"
  $zonesdir     = "${conf_dir}/zone"
  $zone_subdir  = "${zonesdir}/zone"
  $pidfile      = "${run_dir}/knot.pid"
  $key_template = 'knot/etc/knot/knot.key.conf.erb'
  $nsid         = $::fqdn
  $identity     = $::fqdn
  $server_count = $facts['processors']['count']
}
