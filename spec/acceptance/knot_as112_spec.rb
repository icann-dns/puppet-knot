require 'spec_helper_acceptance'

describe 'knot class' do
  ipaddress = fact('ipaddress')
  context 'as112' do
    it 'should work with no errors' do
      pp = <<-EOS
  class {'::knot': }
  knot::zone {
    'rfc1918':
      zonefile => 'db.dd-empty',
      zones => [
        '10.in-addr.arpa',
        '16.172.in-addr.arpa',
        '17.172.in-addr.arpa',
        '18.172.in-addr.arpa',
        '19.172.in-addr.arpa',
        '20.172.in-addr.arpa',
        '21.172.in-addr.arpa',
        '22.172.in-addr.arpa',
        '23.172.in-addr.arpa',
        '24.172.in-addr.arpa',
        '25.172.in-addr.arpa',
        '26.172.in-addr.arpa',
        '27.172.in-addr.arpa',
        '28.172.in-addr.arpa',
        '29.172.in-addr.arpa',
        '30.172.in-addr.arpa',
        '31.172.in-addr.arpa',
        '168.192.in-addr.arpa',
        '254.169.in-addr.arpa'
      ];
    'empty.as112.arpa':
      zonefile => 'db.dr-empty',
      zones    => ['empty.as112.arpa'];
    'hostname.as112.net':
      zonefile => 'hostname.as112.net.zone',
      zones    =>  ['hostname.as112.net'];
    'hostname.as112.arpa':
      zonefile => 'hostname.as112.arpa.zone',
      zones    => ['hostname.as112.arpa'];
  }
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
      EOS
      apply_manifest(pp ,  :catch_failures => true)
      expect(apply_manifest(pp,  :catch_failures => true).exit_code).to eq 0
    end
    describe service('knot') do
      it { is_expected.to be_running }
    end
    describe port(53) do 
      it { is_expected.to be_listening }
    end
    describe command("knotc -c /etc/knot/knot.conf checkconf || cat /etc/knot/knot.conf"), :if => os[:family] == 'ubuntu' do
      its(:stdout) { should match // }
    end
    describe command("knotc -c /usr/local/etc/knot/knot.conf checkconf || cat /usr/local/etc/knot/knot.conf"), :if => os[:family] == 'freebsd' do
      its(:stdout) { should match // }
    end
    describe command("dig +short soa empty.as112.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /blackhole.as112.arpa. noc.dns.icann.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 10.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 16.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 17.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 18.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 19.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 20.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 21.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 22.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 23.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 24.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 25.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 26.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 27.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 28.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 29.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 30.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 31.172.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 168.192.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
    describe command("dig +short soa 254.169.in-addr.arpa @#{ipaddress}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800/ }
    end
  end
end
