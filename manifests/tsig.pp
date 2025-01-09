# @summary Define a TSIG key for knot
# @param algo The algorithm to use for the key
# @param data The data for the key
# @param key_name The name of the key
#
define knot::tsig (
  Stdlib::Base64   $data,
  Knot::Algo       $algo     = 'hmac-sha256',
  Optional[String] $key_name = undef,
) {
  include knot
  concat::fragment { "knot_key_${name}":
    target  => $knot::conf_file,
    content => template($knot::key_template),
    order   => '02',
  }
}
