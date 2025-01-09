# @summary Define a remote server for knot
# @param address4 The IPv4 address of the remote server
# @param address6 The IPv6 address of the remote server
# @param tsig The name of the TSIG key to use
# @param tsig_name The name of the TSIG key to use
# @param port The port to use for the remote server
#
define knot::remote (
  Optional[Stdlib::IP::Address::V4] $address4  = undef,
  Optional[Stdlib::IP::Address::V6] $address6  = undef,
  Optional[String]                  $tsig      = undef,
  Optional[String]                  $tsig_name = undef,
  Stdlib::Port                      $port      = 53,
) {
  include knot
  if ! $address4 and ! $address6 {
    fail("${name} must specify eiather address4 or address6")
  }
  if $tsig {
    if ! defined(Knot::Tsig[$tsig]) {
      fail("Knot::Tsig['${tsig}'] does not exist")
    }
    if ! $tsig_name {
      fail(' you must define tsig_name when you deinfe tsig')
    } else {
      $_tsig_name = $tsig_name
    }
  } elsif $tsig_name and $tsig_name != '' {
    if defined(Knot::Tsig[$tsig_name]) or $tsig_name == 'NOKEY' {
      $_tsig_name = $tsig_name
    } else {
      fail("Knot::Tsig['${tsig_name}'] does not exist")
    }
  } else {
    $_tsig_name = $knot::default_tsig_name
  }
  concat::fragment { "knot_remotes_${name}":
    target  => $knot::conf_file,
    content => template($knot::remotes_template),
    order   => '12';
  }
  concat::fragment { "knot_acl_${name}":
    target  => $knot::conf_file,
    content => template($knot::acl_template),
    order   => '15';
  }
}
