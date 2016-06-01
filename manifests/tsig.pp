# define knot::tsig
#
define knot::tsig (
  $algo     = 'hmac-sha256',
  $data     = false,
  $template = 'knot/etc/knot/knot.key.conf.erb',
) {
  validate_re($algo, ['^hmac-sha(1|224|256|384|512)$', '^hmac-md5$'])
  validate_re($data, '^[a-zA-Z0-9+\/=]+$')
  validate_absolute_path("/${template}")

  concat::fragment{ "knot_key_${name}":
    target  => $::knot::conf_file,
    content => template($template),
    order   => '10',
  }
}
