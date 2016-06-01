#== Class: knot
#
define knot::zone (
  $masters          = [],
  $notify_addresses = [],
  $allow_notify     = [],
  $provide_xfr      = [],
  $zones            = [],
  $zonefile         = undef,
  $zone_dir         = undef,
) {

  validate_array($masters)
  validate_array($notify_addresses)
  validate_array($allow_notify)
  validate_array($provide_xfr)
  validate_array($zones)
  validate_array($masters)
  if $zonefile {
    validate_string($zonefile)
  }
  if $zone_dir {
    validate_absolute_path($zone_dir)
    $zone_subdir = $zone_dir
  } else {
    $zone_subdir = $::knot::zone_subdir
  }
  concat::fragment{ "knot_zones_${name}":
    target  => $::knot::conf_file,
    content => template($::knot::zones_template),
    order   => '20';
  }
}
