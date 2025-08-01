# @summary Define a zone in Knot DNS
# @param masters An array of master servers for the zone
# @param provide_xfrs An array of servers to provide zone transfers to
# @param allow_notify_additions An array of servers to allow zone transfers from
# @param send_notify_additions An array of servers to send notifications to
# @param zonefile The path to the zone file
# @param zone_dir The directory to store the zone file in
# @param zonemd_verify Whether to verify the zonemd record
# @param zonemd_generate Whether to generate the zonemd record
# @param allow_axfr_fallback Whether to allow AXFR fallback
# @param create_ixfr Whether to create IXFR files
# @param ixfr_size The size of IXFR files
# @param refresh_min_interval Minimum refresh interval
# @param refresh_max_interval Maximum refresh interval
# @param retry_min_interval Minimum retry interval
# @param retry_max_interval Maximum retry interval
# @param expire_min_interval Minimum expire interval
# @param expire_max_interval Maximum expire interval
#
define knot::zone (
  Array[String]                   $masters                = [],
  Array[String]                   $provide_xfrs           = [],
  Array[String]                   $allow_notify_additions = [],
  Array[String]                   $send_notify_additions  = [],
  Optional[String]                $zonefile               = undef,
  Optional[Stdlib::Unixpath]      $zone_dir               = undef,
  Optional[Knot::On_off]          $zonemd_verify          = undef,
  Optional[Knot::Zonemd_generate] $zonemd_generate        = undef,
  Optional[Knot::On_off]          $allow_axfr_fallback    = undef,
  Optional[Knot::On_off]          $create_ixfr            = undef,
  Optional[Integer]               $ixfr_size              = undef,
  Optional[Integer]               $refresh_min_interval   = undef,
  Optional[Integer]               $refresh_max_interval   = undef,
  Optional[Integer]               $retry_min_interval     = undef,
  Optional[Integer]               $retry_max_interval     = undef,
  Optional[Integer]               $expire_min_interval    = undef,
  Optional[Integer]               $expire_max_interval    = undef,
) {
  include knot
  $default_masters      = $knot::default_masters
  $default_provide_xfrs = $knot::default_provide_xfrs
  $exported_remotes     = $knot::exported_remotes
  $_refresh_max_interval = pick_default($refresh_max_interval, $knot::default_refresh_max_interval)
  $_retry_max_interval   = pick_default($retry_max_interval, $knot::default_retry_max_interval)
  $_expire_max_interval  = pick_default($expire_max_interval, $knot::default_expire_max_interval)
  $_refresh_min_interval = pick_default($refresh_min_interval, $knot::default_refresh_min_interval)
  $_retry_min_interval   = pick_default($retry_min_interval, $knot::default_retry_min_interval)
  $_expire_min_interval  = pick_default($expire_min_interval, $knot::default_expire_min_interval)
  if $zone_dir {
    $zone_subdir = $zone_dir
  } else {
    $zone_subdir = $knot::zone_subdir
  }
  $masters.each |String $server| {
    if ! defined(Knot::Remote[$server]) {
      fail("${name} defines master ${server}. however Knot::Remote[${server}] is not defined")
    }
  }
  $provide_xfrs.each |String $server| {
    if ! defined(Knot::Remote[$server]) {
      fail("${name} defines provide_xfr ${server}. however Knot::Remote[${server}] is not defined")
    }
  }
  $allow_notify_additions.each |String $server| {
    if ! defined(Knot::Remote[$server]) {
      fail("${name} defines allow_notify_addition ${server}. however Knot::Remote[${server}] is not defined")
    }
  }
  $send_notify_additions.each |String $server| {
    if ! defined(Knot::Remote[$server]) {
      fail("${name} defines send_notify_addition ${server}. however Knot::Remote[${server}] is not defined")
    }
  }
  concat::fragment { "knot_zones_${name}":
    target  => $knot::conf_file,
    content => template($knot::zones_template),
    order   => '22';
  }
}
