#== Define: knot::remote
#
define knot::remote (
  Optional[Variant[Tea::Ipv4, Tea::Ipv4_cidr]] $address4  = undef,
  Optional[Variant[Tea::Ipv6, Tea::Ipv6_cidr]] $address6  = undef,
  Optional[String]                             $tsig      = undef,
  Optional[String]                             $tsig_name = undef,
  Tea::Port                                    $port      = 53,
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
    $_tsig_name = $::knot::default_tsig_name
  }
  concat::fragment{ "knot_remotes_${name}":
    target  => $::knot::conf_file,
    content => template($::knot::remotes_template),
    order   => '12';
  }
  concat::fragment{ "knot_acl_${name}":
    target  => $::knot::conf_file,
    content => template($::knot::acl_template),
    order   => '15';
  }
}
