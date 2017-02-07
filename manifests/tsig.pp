# define knot::tsig
#
define knot::tsig (
  Knot::Algo $algo = 'hmac-sha256',
  String     $data = undef,
  $template = 'knot/etc/knot/knot.key.conf.erb',
) {
  concat::fragment{ "knot_key_${name}":
    target  => $::knot::conf_file,
    content => template($template),
    order   => '02',
  }
}
