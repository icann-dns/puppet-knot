# frozen_string_literal: true

require 'spec_helper_acceptance'

if ENV['BEAKER_TESTMODE'] == 'agent'
  describe 'master slave config using exported resources' do
    context 'defaults' do
      dnsmaster    = find_host_with_role('dnsmaster')
      dnsmaster_ip = fact_on(dnsmaster, 'ipaddress')
      dnsslave     = find_host_with_role('dnsslave')
      dnsslave_ip  = fact_on(dnsslave, 'ipaddress')

      master_pp = <<EOS
  class { '::knot':
    remotes  => {
      'lax.xfr.dns.icann.org' => {
        'address4' => '192.0.32.132',
        'address6' => '2620:0:2d0:202::132',
      },
      'iad.xfr.dns.icann.org' => {
        'address4' => '192.0.47.132',
        'address6' => '2620:0:2830:202::132',
      },
    },
    zones    => {
      '.' => {
        'masters' => [ 'lax.xfr.dns.icann.org', 'iad.xfr.dns.icann.org'],
        'zonefile' => 'root',
      },
      'root-servers.net.' => {
        'masters' => [ 'lax.xfr.dns.icann.org', 'iad.xfr.dns.icann.org'],
      },
      'arpa.' => {
        'masters' => [ 'lax.xfr.dns.icann.org', 'iad.xfr.dns.icann.org'],
      },
    },
  }
  Knot::Tsig <<| tag == 'dns__slave_tsig' |>>
  Knot::Remote <<| tag == 'dns__slave_remote' |>>
EOS
      # the key below is only to be used in here to not use it in production
      dnsslave_pp = <<EOS
  class { '::knot':
    default_tsig_name => '#{dnsslave}-test',
    tsigs    => {
      '#{dnsslave}-test' => {
        'data' => 'qneKJvaiXqVrfrS4v+Oi/9GpLqrkhSGLTCZkf0dyKZ0='
      },
    },
    remotes  => {
      '#{dnsmaster}' => {
        'address4' => '#{dnsmaster_ip}',
      },
    },
    zones    => {
      '.' => {
        'masters' => [ #{dnsmaster} ],
        'zonefile' => 'root',
      },
      'root-servers.net.' => {
        'masters' => [ #{dnsmaster} ],
      },
      'arpa.' => {
        'masters' => [ #{dnsmaster} ],
      },
    },
  }
  @@knot::tsig {'dns__export_#{dnsslave}-test':
    algo => 'hmac-sha256',
    data => 'qneKJvaiXqVrfrS4v+Oi/9GpLqrkhSGLTCZkf0dyKZ0=',
    key_name => '#{dnsslave}-test',
    tag => dns__slave_tsig,
  }
  @@knot::remote {'dns__export_#{dnsslave}':
    address4 => '#{dnsslave_ip}',
    tsig => 'dns__export_#{dnsslave}-test',
    tsig_name => '#{dnsslave}-test',
    tag => 'dns__slave_remote',
  }
EOS

      it 'run puppet a bunch of times' do
        execute_manifest_on(dnsmaster, master_pp, catch_failures: true)
        execute_manifest_on(dnsslave, dnsslave_pp, catch_failures: true)
        execute_manifest_on(dnsslave, dnsslave_pp, catch_failures: true)
        execute_manifest_on(dnsmaster, master_pp, catch_failures: true)
        execute_manifest_on(dnsmaster, master_pp, catch_failures: true)
      end
      it 'clean puppet run on dns master' do
        expect(execute_manifest_on(dnsmaster, master_pp, catch_failures: true).exit_code).to eq 0
      end
      it 'clean puppet run on dns dnsslave' do
        expect(execute_manifest_on(dnsslave, dnsslave_pp, catch_failures: true).exit_code).to eq 0
      end
      it 'sleep for 1 minute to allow tranfers to occur' do
        sleep(60)
      end
      describe service('knot'), node: dnsmaster do
        it { is_expected.to be_running }
      end
      describe port(53), node: dnsmaster do
        it { is_expected.to be_listening }
      end
      describe service('knot'), node: dnsslave do
        it { is_expected.to be_running }
      end
      describe port(53), node: dnsslave do
        it { is_expected.to be_listening }
      end
      describe command('knotc -c /etc/knot/knot.conf checkconf || cat /etc/knot/knot.conf'), if: os[:family] == 'ubuntu', node: dnsmaster do
        its(:stdout) { is_expected.to match %r{} }
      end
      describe command('knotc -c /usr/local/etc/knot/knot.conf checkconf || cat /usr/local/etc/knot/knot.conf'), if: os[:family] == 'freebsd', node: dnsmaster do
        its(:stdout) { is_expected.to match %r{} }
      end
      describe command('knotc -c /etc/knot/knot.conf checkconf || cat /etc/knot/knot.conf'), if: os[:family] == 'ubuntu', node: dnsslave do
        its(:stdout) { is_expected.to match %r{} }
      end
      describe command('knotc -c /usr/local/etc/knot/knot.conf checkconf || cat /usr/local/etc/knot/knot.conf'), if: os[:family] == 'freebsd', node: dnsslave do
        its(:stdout) { is_expected.to match %r{} }
      end
      describe command("dig +short soa . @#{dnsslave_ip}"), node: dnsslave do
        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) { is_expected.to match %r{a.root-servers.net. nstld.verisign-grs.com.} }
      end
      describe command("dig +short soa root-servers.net. @#{dnsslave_ip}"), node: dnsslave do
        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) { is_expected.to match %r{a.root-servers.net. nstld.verisign-grs.com.} }
      end
      describe command("dig +short soa arpa. @#{dnsslave_ip}"), node: dnsslave do
        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) { is_expected.to match %r{a.root-servers.net. nstld.verisign-grs.com.} }
      end
    end
  end
end
