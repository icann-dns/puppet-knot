# frozen_string_literal: true

if ENV['BEAKER_TESTMODE'] == 'apply'
  require 'spec_helper_acceptance'

  describe 'knot class' do
    ipaddress = fact('ipaddress')
    context 'as112' do
      it 'is_expected.to work with no errors' do
        pp = 'class {\'::knot::as112\': }'
        execute_manifest(pp, catch_failures: true)
        expect(execute_manifest(pp, catch_failures: true).exit_code).to eq 0
      end

      describe service('knot') do
        it { is_expected.to be_running }
      end

      describe port(53) do
        it { is_expected.to be_listening }
      end

      describe command('knotc -c /etc/knot/knot.conf checkconf || cat /etc/knot/knot.conf') do
        its(:stdout) { is_expected.to match %r{} }
      end

      describe command("dig +short soa empty.as112.arpa @#{ipaddress}") do
        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) { is_expected.to match %r{blackhole.as112.arpa. noc.dns.icann.org. 1 604800 60 604800 604800} }
      end

      %w[
        10.in-addr.arpa
        16.172.in-addr.arpa
        17.172.in-addr.arpa
        18.172.in-addr.arpa
        19.172.in-addr.arpa
        20.172.in-addr.arpa
        21.172.in-addr.arpa
        22.172.in-addr.arpa
        23.172.in-addr.arpa
        24.172.in-addr.arpa
        25.172.in-addr.arpa
        26.172.in-addr.arpa
        27.172.in-addr.arpa
        28.172.in-addr.arpa
        29.172.in-addr.arpa
        30.172.in-addr.arpa
        31.172.in-addr.arpa
        168.192.in-addr.arpa
        254.169.in-addr.arpa
      ].each do |zone|
        describe command("dig +short soa #{zone} @#{ipaddress}") do
          its(:exit_status) { is_expected.to eq 0 }
          its(:stdout) { is_expected.to match %r{prisoner.iana.org. hostmaster.root-servers.org. 1 604800 60 604800 604800} }
        end
      end
    end
  end
end
