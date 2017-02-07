# Class knot::as112
#
class knot::as112 {
  include ::knot
  knot::file {
    'db.dd-empty':
      source  => 'puppet:///modules/knot/etc/knot/db.dd-empty';
    'db.dr-empty':
      source  => 'puppet:///modules/knot/etc/knot/db.dr-empty';
    'hostname.as112.net.zone':
      content_template => 'knot/etc/knot/hostname.as112.net.zone.erb';
    'hostname.as112.arpa.zone':
      content_template=> 'knot/etc/knot/hostname.as112.arpa.zone.erb';
  }
  knot::zone {
    '10.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '16.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '17.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '18.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '19.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '20.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '21.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '22.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '23.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '24.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '25.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '26.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '27.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '28.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '29.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '30.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '31.172.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '168.192.in-addr.arpa':
      zonefile => 'db.dd-empty';
    '254.169.in-addr.arpa':
      zonefile => 'db.dd-empty';
    'empty.as112.arpa':
      zonefile => 'db.dr-empty';
    'hostname.as112.net':
      zonefile => 'hostname.as112.net.zone';
    'hostname.as112.arpa':
      zonefile => 'hostname.as112.arpa.zone';
  }
}
