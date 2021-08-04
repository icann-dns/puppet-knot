#== Class: knot
#
class knot::params {
  case $::kernel {
    'FreeBSD': {
      $package_name     = 'knot2'
      $conf_dir         = '/usr/local/etc/knot'
      $run_dir          = '/var/run/knot'
      $knotc_bin        = '/usr/local/sbin/knotc'
      $kzonecheck_bin   = '/usr/local/bin/kzonecheck'
    }
    default: {
      $package_name     = 'knot'
      $conf_dir         = '/etc/knot'
      $run_dir          = '/run/knot'
      $knotc_bin        = '/usr/sbin/knotc'
      $kzonecheck_bin   = '/usr/bin/kzonecheck'
    }
  }
  $ip_addresses     = [$::ipaddress]
  $conf_file        = "${conf_dir}/knot.conf"
  $zonesdir         = "${conf_dir}/zone"
  $zone_subdir      = "${zonesdir}/zone"
  $pidfile          = "${run_dir}/knot.pid"
  $nsid             = $::fqdn
  $identity         = $::fqdn
  $server_count     = $facts['processors']['count']
  $restart_cmd      = "${knotc_bin} reload || ${knotc_bin} ${knotc_arg} && service knot restart"
  $validate_cmd     = "${knotc_bin} -c % ${knotc_arg}"
  $concat_head      = ":\n"
  $acl_head         = "acl:\n"
  $concat_foot      = "\n"
  $acl_foot         = $concat_foot
  $server_template  = 'knot/etc/knot/knot.server.conf.erb'
  $key_template     = 'knot/etc/knot/knot.key.conf.erb'
  $zones_template   = 'knot/etc/knot/knot.zones.conf.erb'
  $remotes_template = 'knot/etc/knot/knot.remotes.conf.erb'
  $acl_template     = 'knot/etc/knot/knot.acl.conf.erb'
  $knotc_arg        = 'conf-check'
}
