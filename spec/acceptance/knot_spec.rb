require 'spec_helper_acceptance'

describe 'knot class' do
  ipaddress = fact('ipaddress')
  context 'defaults' do
    it 'should work with no errors' do
      pp = 'class {\'::knot\': }'
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
  end
end
