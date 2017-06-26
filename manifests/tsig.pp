# define knot::tsig
#
define knot::tsig (
  Knot::Algo       $algo     = 'hmac-sha256',
  Tea::Base64      $data     = undef,
  Optional[String] $key_name = undef,
) {
  include ::knot

  $key_template = $::knot::key_template

  concat::fragment{ "knot_key_${name}":
    target  => $::knot::conf_file,
    content => template($key_template),
    order   => '02',
  }
}
