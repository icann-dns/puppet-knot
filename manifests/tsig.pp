# define knot::tsig
#
define knot::tsig (
  Knot::Algo       $algo     = 'hmac-sha256',
  String           $data     = undef,
  String           $template = 'knot/etc/knot/knot.key.conf.erb',
  Optional[String] $key_name = undef,
) {
  include ::knot
  concat::fragment{ "knot_key_${name}":
    target  => $::knot::conf_file,
    content => template($template),
    order   => '02',
  }
}
