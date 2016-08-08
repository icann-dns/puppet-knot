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
  $tsig_name        = undef,
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
  if $tsig_name {
    validate_string($tsig_name)
    if defined(Knot::Tsig[$tsig_name]) {
      $_tsig_name = $tsig_name
    } else {
      fail("Nsd::Tsig['${tsig_name}'] does not exist")
    }
  } elsif has_key($::knot::tsig, 'name') {
    $_tsig_name = $::knot::tsig['name']
  }
  concat::fragment{ "knot_zones_${name}":
    target  => $::knot::conf_file,
    content => template($::knot::zones_template),
    order   => '20';
  }
  if $::knot::manage_nagios and $::knot::enable {
    knot::zone::nagios {$zones:
      masters => $masters,
      slaves  => $provide_xfr,
    }
  }
}
