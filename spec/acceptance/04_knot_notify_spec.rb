# frozen_string_literal: true

if ENV['BEAKER_TESTMODE'] == 'agent'
  require 'spec_helper_acceptance'

  describe 'knot class' do
    context 'test notifies' do
      dnsmaster    = find_host_with_role('dnsmaster')
      dnsmaster_ip = fact_on(dnsmaster, 'ipaddress')
      dnsslave     = find_host_with_role('dnsslave')
      dnsslave_ip  = fact_on(dnsslave, 'ipaddress')
      example_zone = <<EOS
example.com. 3600 IN SOA sns.dns.icann.org. noc.dns.icann.org. 1 7200 3600 1209600 3600
example.com. 86400 IN NS a.iana-servers.net.
example.com. 86400 IN NS b.iana-servers.net.
EOS
      dnsmaster_pp = <<-EOS
      class {'::knot':
        imports => ['nofiy_test'],
        zones   => {
          'example.com' => {},
        },
        files => {
          'example.com' => {
            'content' => '#{example_zone}',
          }
        },
      }
      Knot::Tsig <<| tag == 'dns__nofiy_test_slave_tsig' |>>
      Knot::Remote <<| tag == 'dns__nofiy_test_slave_remote' |>>
      EOS
      dnsslave_pp = <<-EOS
      class {'::knot':
        exports => ['nofiy_test'],
        tsigs    => {
          '#{dnsslave}-test' => {
            'data' => 'qneKJvaiXqVrfrS4v+Oi/9GpLqrkhSGLTCZkf0dyKZ0='
          },
        },
        remotes => {
          'master_server' => {
            'address4'  => '#{dnsmaster_ip}',
            'tsig_name' => '#{dnsslave}-test',
          }
        },
        zones   => {
          'example.com' => { 'masters' => ['master_server'] },
        },
      }
      @@knot::tsig {'dns__export_nofiy_test_#{dnsslave}-test':
        algo => 'hmac-sha256',
        data => 'qneKJvaiXqVrfrS4v+Oi/9GpLqrkhSGLTCZkf0dyKZ0=',
        key_name => '#{dnsslave}-test',
        tag => 'dns__nofiy_test_slave_tsig',
      }
      @@knot::remote {'dns__export_nofiy_test_#{dnsslave}':
        address4 => '#{dnsslave_ip}',
        tsig => 'dns__export_nofiy_test_#{dnsslave}-test',
        tsig_name => '#{dnsslave}-test',
        tag => 'dns__nofiy_test_slave_remote',
      }
      EOS
      it 'run puppet a bunch of times' do
        execute_manifest_on(dnsmaster, dnsmaster_pp, catch_failures: true)
        execute_manifest_on(dnsslave, dnsslave_pp, catch_failures: true)
        execute_manifest_on(dnsmaster, dnsmaster_pp, catch_failures: true)
      end
      it 'clean puppet run on dns master' do
        expect(execute_manifest_on(dnsmaster, dnsmaster_pp, catch_failures: true).exit_code).to eq 0
      end
      it 'clean puppet run on dns dnsslave' do
        expect(execute_manifest_on(dnsslave, dnsslave_pp, catch_failures: true).exit_code).to eq 0
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
      describe command('knot-checkconf /etc/knot/knot.conf || cat /etc/knot/knot.conf'), if: os[:family] == 'ubuntu', node: dnsmaster do
        its(:stdout) { is_expected.to match %r{} }
      end
      describe command('knot-checkconf /usr/local/etc/knot/knot.conf || cat /usr/local/etc/knot/knot.conf'), if: os[:family] == 'freebsd', node: dnsmaster do
        its(:stdout) { is_expected.to match %r{} }
      end
      describe command('knot-checkconf /etc/knot/knot.conf || cat /etc/knot/knot.conf'), if: os[:family] == 'ubuntu', node: dnsslave do
        its(:stdout) { is_expected.to match %r{} }
      end
      describe command('knot-checkconf /usr/local/etc/knot/knot.conf || cat /usr/local/etc/knot/knot.conf'), if: os[:family] == 'freebsd', node: dnsslave do
        its(:stdout) { is_expected.to match %r{} }
      end
      describe command("dig +short soa example.com. @#{dnsmaster_ip}"), node: dnsmaster do
        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) do
          is_expected.to match(
            %r{sns.dns.icann.org. noc.dns.icann.org. 1 7200 3600 1209600 3600}
          )
        end
      end
      describe command("dig +short soa example.com. @#{dnsslave_ip}"), node: dnsslave do
        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) do
          is_expected.to match(
            %r{sns.dns.icann.org. noc.dns.icann.org. 1 7200 3600 1209600 3600}
          )
        end
      end
      describe command('sed -i \'s/1/2/\' /etc/knot/zone/zone/example.com'), node: dnsmaster do
        its(:exit_status) { is_expected.to eq 0 }
      end
      describe command('service knot restart'), node: dnsmaster do
        its(:exit_status) { is_expected.to eq 0 }
      end
      describe command("dig +short soa example.com. @#{dnsmaster_ip}"), node: dnsmaster do
        let(:pre_command) { 'sleep 5'  }

        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) do
          is_expected.to match(
            %r{sns.dns.icann.org. noc.dns.icann.org. 2 7200 3600 1209600 3600}
          )
        end
      end
      describe command("dig +short soa example.com. @#{dnsslave_ip}"), node: dnsslave do
        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) do
          is_expected.to match(
            %r{sns.dns.icann.org. noc.dns.icann.org. 2 7200 3600 1209600 3600}
          )
        end
      end
    end
  end
end
