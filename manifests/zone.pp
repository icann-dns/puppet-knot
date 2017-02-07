#== Class: knot
#
define knot::zone (
  Optional[Array[String]]       $masters                = [],
  Optional[Array[String]]       $provide_xfrs           = [],
  Optional[Array[String]]       $allow_notify_additions = [],
  Optional[Array[String]]       $send_notify_additions  = [],
  Optional[String]              $zonefile               = undef,
  Optional[Tea::Absolutepath]   $zone_dir               = undef,
  Optional[Array[Nsd::Rrltype]] $rrl_whitelist          = [],
  Optional[String]              $fetch_tsig_name        = undef,
  Optional[String]              $provide_tsig_name      = undef,
) {
  include ::knot
  $servers = $::knot::servers
  if $zone_dir {
    validate_absolute_path($zone_dir)
    $zone_subdir = $zone_dir
  } else {
    $zone_subdir = $::knot::zone_subdir
  }
  if $fetch_tsig_name {
    validate_string($fetch_tsig_name)
    if defined(Knot::Tsig[$fetch_tsig_name]) {
      $_fetch_tsig_name = $fetch_tsig_name
    } else {
      fail("Nsd::Tsig['${fetch_tsig_name}'] does not exist")
    }
  } else {
    $_fetch_tsig_name = $::knot::fetch_tsig_name
  }
  if $provide_tsig_name {
    validate_string($provide_tsig_name)
    if defined(Knot::Tsig[$provide_tsig_name]) {
      $_provide_tsig_name = $provide_tsig_name
    } else {
      fail("Nsd::Tsig['${provide_tsig_name}'] does not exist")
    }
  } else {
    $_provide_tsig_name = $::knot::provide_tsig_name
  }
  $masters.each |String $server| {
    if ! has_key($servers, $server) {
      fail("${name} defines master ${server}.  however this has not been defined as an knot::server")
    }
  }
  $provide_xfrs.each |String $server| {
    if ! has_key($servers, $server) {
      fail("${name} defines provide_xfr ${server}.  however this has not been defined as an knot::server")
    }
  }
  $allow_notify_additions.each |String $server| {
    if ! has_key($servers, $server) {
      fail("${name} defines allow_notify_addition ${server}.  however this has not been defined as an knot::server")
    }
  }
  $send_notify_additions.each |String $server| {
    if ! has_key($servers, $server) {
      fail("${name} defines send_notify_addition ${server}.  however this has not been defined as an knot::server")
    }
  }
  concat::fragment{ "knot_zones_${name}":
    target  => $::knot::conf_file,
    content => template($::knot::zones_template),
    order   => '20';
  }
  #if $::knot::manage_nagios and $::knot::enable {
  #  knot::zone::nagios {$zones:
  #    masters => $masters,
  #    slaves  => $provide_xfr,
  #  }
  #}
}
