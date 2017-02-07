# Define: knot::file
#
define knot::file (
    String                       $ensure           = 'present',
    String                       $owner            = 'knot',
    String                       $group            = 'knot',
    Pattern[/^\d+$/]             $mode             = '0640',
    Optional[Tea::Puppetsource]  $source           = undef,
    Optional[String]             $content          = undef,
    Optional[Tea::Puppetcontent] $content_template = undef,
) {
  if $content and $content_template {
    fail('can\'t set $content and $content_template')
  } elsif $content {
    $_content = $content
  } elsif $content_template {
    $_content = template($content_template)
  } else {
    $_content = undef
  }
  file { "${::knot::zone_subdir}/${title}":
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    source  => $source,
    content => $_content,
    require => Package[$::knot::package_name],
    notify  => Service[$::knot::service_name];
  }
}

