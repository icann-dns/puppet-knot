# @summary Define a file resource for a Knot zone file
# @param ensure Whether the file should be present or absent
# @param owner The owner of the file
# @param group The group of the file
# @param mode The mode of the file
# @param origin The origin of the zone file
# @param source The source of the file
# @param content The content of the file
# @param content_template The template to use for the content of the file
#
define knot::file (
  String                       $ensure           = 'present',
  String                       $owner            = 'knot',
  String                       $group            = 'knot',
  Pattern[/^\d+$/]             $mode             = '0640',
  Optional[String]             $origin           = undef,
  Optional[Stdlib::Filesource] $source           = undef,
  Optional[String[1]]          $content          = undef,
  Optional[String[1]]          $content_template = undef,
) {
  include knot
  if $content and $content_template {
    fail('can\'t set $content and $content_template')
  } elsif $content {
    $_content = $content
  } elsif $content_template {
    $_content = template($content_template)
  } else {
    $_content = undef
  }
  if 'knot_version' in $facts and versioncmp($facts['knot_version'], '2.3.0') >= 0 {
    $validate_cmd = $origin ? {
      undef   => "${knot::kzonecheck_bin} %",
      default => "${knot::kzonecheck_bin} -o ${origin} %",
    }
  } else {
    $validate_cmd = undef
  }
  file { "${knot::zone_subdir}/${title}":
    ensure       => $ensure,
    owner        => $owner,
    group        => $group,
    mode         => $mode,
    source       => $source,
    content      => $_content,
    validate_cmd => $validate_cmd,
    require      => Package[$knot::package_name],
    notify       => Service[$knot::service_name];
  }
}
