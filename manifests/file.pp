# Define: knot::file
#
define knot::file (
    String                       $ensure           = 'present',
    String                       $owner            = 'knot',
    String                       $group            = 'knot',
    Pattern[/^\d+$/]             $mode             = '0640',
    Optional[String]             $origin           = undef,
    Optional[Tea::Puppetsource]  $source           = undef,
    Optional[String]             $content          = undef,
    Optional[Tea::Puppetcontent] $content_template = undef,
) {
  include ::knot
  if $content and $content_template {
    fail('can\'t set $content and $content_template')
  } elsif $content {
    $_content = $content
  } elsif $content_template {
    $_content = template($content_template)
  } else {
    $_content = undef
  }
  if versioncmp($::knot_version, '2.3.0') < 0 {
    $validate_cmd = undef
  } elsif $origin {
    $validate_cmd = "${::knot::kzonecheck_bin} -o ${origin} %"
  } else {
    $validate_cmd = "${::knot::kzonecheck_bin} %"
  }
  file { "${::knot::zone_subdir}/${title}":
    ensure       => $ensure,
    owner        => $owner,
    group        => $group,
    mode         => $mode,
    source       => $source,
    content      => $_content,
    validate_cmd => $validate_cmd,
    require      => Package[$::knot::package_name],
    notify       => Service[$::knot::service_name];
  }
}

