# frozen_string_literal: true

if ENV['BEAKER_TESTMODE'] == 'apply'
  require 'spec_helper_acceptance'

  describe 'knot class' do
    ipaddress = fact('ipaddress')
    context 'root' do
      it 'is_expected.to work with no errors' do
        pp = <<-EOS
    class {'::knot':
      remotes => {
        'lax.xfr.dns.icann.org' => {
          'address4' => '192.0.32.132'
        },
        'iad.xfr.dns.icann.org' => {
          'address4' => '192.0.47.132'
        },
      }
    }
    knot::zone {
      '.':
        masters  => ['lax.xfr.dns.icann.org', 'iad.xfr.dns.icann.org'],
        zonefile => 'root';
      'arpa.':
        masters  => ['lax.xfr.dns.icann.org', 'iad.xfr.dns.icann.org'];
      'root-servers.net.':
        masters  => ['lax.xfr.dns.icann.org', 'iad.xfr.dns.icann.org'];
    }
        EOS
        execute_manifest(pp, catch_failures: true)
        execute_manifest(pp, catch_failures: true)
        expect(execute_manifest(pp, catch_failures: true).exit_code).to eq 0
      end
      describe service('knot') do
        it { is_expected.to be_running }
      end
      describe port(53) do
        it { is_expected.to be_listening }
      end
      describe command('knotc -c /etc/knot/knot.conf checkconf || cat /etc/knot/knot.conf'), if: os[:family] == 'ubuntu' do
        its(:stdout) { is_expected.to match %r{} }
      end
      describe command('knotc -c /usr/local/etc/knot/knot.conf checkconf || cat /usr/local/etc/knot/knot.conf'), if: os[:family] == 'freebsd' do
        its(:stdout) { is_expected.to match %r{} }
      end
      describe command("dig +short soa . @#{ipaddress}") do
        let(:pre_command) { 'sleep 10' }

        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) { is_expected.to match %r{a.root-servers.net. nstld.verisign-grs.com.} }
      end
      describe command("dig +short soa arpa. @#{ipaddress}") do
        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) { is_expected.to match %r{a.root-servers.net. nstld.verisign-grs.com.} }
      end
      describe command("dig +short soa root-servers.net. @#{ipaddress}") do
        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) { is_expected.to match %r{a.root-servers.net. nstld.verisign-grs.com.} }
      end
    end
  end
end
