#== Class: knot
#
define knot::zone (
  Optional[Array[String]]       $masters                = [],
  Optional[Array[String]]       $provide_xfrs           = [],
  Optional[Array[String]]       $allow_notify_additions = [],
  Optional[Array[String]]       $send_notify_additions  = [],
  Optional[String]              $zonefile               = undef,
  Optional[Tea::Absolutepath]   $zone_dir               = undef,
) {
  include knot
  $default_masters      = $::knot::default_masters
  $default_provide_xfrs = $::knot::default_provide_xfrs
  $exported_remotes     = $::knot::exported_remotes
  if $zone_dir {
    $zone_subdir = $zone_dir
  } else {
    $zone_subdir = $::knot::zone_subdir
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
  concat::fragment{ "knot_zones_${name}":
    target  => $::knot::conf_file,
    content => template($::knot::zones_template),
    order   => '22';
  }
}
