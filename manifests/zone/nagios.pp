# knot::zone::nagios
#
define knot::zone::nagios (
  $slaves  = [],
  $masters = [],
) {
  validate_array($slaves)
  validate_array($masters)
  $_masters  = delete($masters,['127.0.0.1','0::1'])
  $_slaves   = delete($slaves,['127.0.0.1','0::1'])
  $addresses = join($::knot::ip_addresses, ' ')
  if ! empty($_masters) {
    $master_check_args = join($_masters, ' ')
    @@nagios_service{ "${::fqdn}_DNS_ZONE_MASTERS_${name}":
      ensure              => present,
      use                 => 'generic-service',
      host_name           => $::fqdn,
      service_description => "DNS_ZONE_MASTERS_${name}",
      check_command       => "check_nrpe_args!check_dns!${name}!${master_check_args}!${addresses}",
    }
  }
  if ! empty($_slaves) {
    $slave_check_args = join($_slaves, ' ')
    @@nagios_service{ "${::fqdn}_DNS_ZONE_SLAVES_${name}":
      ensure              => present,
      use                 => 'generic-service',
      host_name           => $::fqdn,
      service_description => "DNS_ZONE_MASTERS_${name}",
      check_command       => "check_nrpe_args!check_dns!${name}!${slave_check_args}!${addresses}",
    }
  }
}
