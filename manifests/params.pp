#== Class: knot
#
class knot::params (
  Boolean $force_knot1 = false
) {
  # This is specific to ICANN migration and will
  # likley get removed in future versions
  if $force_knot1 {
    case $::kernel {
      'FreeBSD': {
        $package_name   = 'knot1'
        $conf_dir       = '/usr/local/etc/knot'
        $run_dir        = '/var/run/knot'
        $knotc_bin      = '/usr/local/sbin/knotc'
      }
      default: {
        $package_name   = 'knot'
        $conf_dir       = '/etc/knot'
        $run_dir        = '/run/knot'
        $knotc_bin      = '/usr/sbin/knotc'
      }
    }
    $knotc_arg        = 'checkconf'
    $concat_head      = "s {\n"
    $concat_foot      = "}\n"
    $acl_head         = "groups {\n"
    $acl_foot         = 'knot/etc/knot1/knot.acl_slave.conf.erb'
    $server_template  = 'knot/etc/knot1/knot.server.conf.erb'
    $key_template     = 'knot/etc/knot1/knot.key.conf.erb'
    $zones_template   = 'knot/etc/knot1/knot.zones.conf.erb'
    $remotes_template = 'knot/etc/knot1/knot.remotes.conf.erb'
    $acl_template     = 'knot/etc/knot1/knot.acl.conf.erb'
  } else {
    case $::kernel {
      'FreeBSD': {
        $package_name     = 'knot2'
        $conf_dir         = '/usr/local/etc/knot'
        $run_dir          = '/var/run/knot'
        $concat_head      = ":\n"
        $acl_head         = "acl:\n"
        $concat_foot      = "\n"
        $acl_foot         = $concat_foot
        $server_template  = 'knot/etc/knot2/knot.server.conf.erb'
        $key_template     = 'knot/etc/knot2/knot.key.conf.erb'
        $zones_template   = 'knot/etc/knot2/knot.zones.conf.erb'
        $remotes_template = 'knot/etc/knot2/knot.remotes.conf.erb'
        $acl_template     = 'knot/etc/knot2/knot.acl.conf.erb'
        $knotc_arg        = 'conf-check'
        $knotc_bin        = '/usr/local/sbin/knotc'
      }
      default: {
        $package_name = 'knot'
        $conf_dir     = '/etc/knot'
        $run_dir      = '/run/knot'
        $knotc_bin    = '/usr/sbin/knotc'
        case $::lsbdistcodename {
          'trusty': {
            $concat_head      = "s {\n"
            $acl_head         = "groups {\n"
            $concat_foot      = "}\n"
            $acl_foot         = 'knot/etc/knot1/knot.acl_slave.conf.erb'
            $server_template  = 'knot/etc/knot1/knot.server.conf.erb'
            $key_template     = 'knot/etc/knot1/knot.key.conf.erb'
            $zones_template   = 'knot/etc/knot1/knot.zones.conf.erb'
            $remotes_template = 'knot/etc/knot1/knot.remotes.conf.erb'
            $acl_template     = 'knot/etc/knot1/knot.acl.conf.erb'
            $knotc_arg        = 'checkconf'
          }
          default: {
            $concat_head      = ":\n"
            $acl_head         = "acl:\n"
            $concat_foot      = "\n"
            $acl_foot         = $concat_foot
            $server_template  = 'knot/etc/knot2/knot.server.conf.erb'
            $key_template     = 'knot/etc/knot2/knot.key.conf.erb'
            $zones_template   = 'knot/etc/knot2/knot.zones.conf.erb'
            $remotes_template = 'knot/etc/knot2/knot.remotes.conf.erb'
            $acl_template     = 'knot/etc/knot2/knot.acl.conf.erb'
            $knotc_arg        = 'conf-check'
          }
        }
      }
    }
  }
  $ip_addresses = [$::ipaddress]
  $conf_file    = "${conf_dir}/knot.conf"
  $zonesdir     = "${conf_dir}/zone"
  $zone_subdir  = "${zonesdir}/zone"
  $pidfile      = "${run_dir}/knot.pid"
  $nsid         = $::fqdn
  $identity     = $::fqdn
  $server_count = $facts['processors']['count']
  $restart_cmd  = "${knotc_bin} reload || ${knotc_bin} ${knotc_arg} && service knot restart"
  $validate_cmd = "${knotc_bin} ${knotc_arg}"
}
