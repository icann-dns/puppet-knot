require 'spec_helper'

describe 'knot' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:node) { 'foo.example.com' }
  let(:params) do
    {
      # enable: true,
      # slave_addresses: {},
      remotes: {
        'master' => { 'address4' => '192.0.2.1' },
        'provide_xfr' => { 'address4' => '192.0.2.2' },
        'allow_notify_addition' => { 'address4' => '192.0.2.3' },
        'send_notify_addition' => { 'address4' => '192.0.2.4' }
      },
      zones: { 'example.com' => { 'masters' => ['master'] } },
      tsigs: { 'test.example.com' => { 'data' => 'AAAAA' } },
      files: { 'example.com' => { 'content' => 'bla' } }
      # server_template: "knot/etc/knot/knot.server.conf.erb",
      # zones_template: "knot/etc/knot/knot.zones.conf.erb",
      # ip_addresses: [],
      # identity: $fqdn,
      # nsid: $fqdn,
      # log_target: "syslog",
      # log_zone_level: "error",
      # log_server_level: "error",
      # log_any_level: "error",
      # server_count: $processorcount,
      # max_tcp_clients: 250,
      # max_udp_payload: 4096,
      # pidfile: $run_dir/knot.pid,
      # port: 53,
      # username: "knot",
      # zonesdir: $conf_dir/zone,
      # hide_version: false,
      # rrl_size: 1000000,
      # rrl_limit: 200,
      # rrl_slip: 2,
      # control_enable: true,
      # control_interface: "127.0.0.1",
      # control_port: 5533,
      # control_allow: {"localhost" => "127.0.0.1"},
      # package_name: $knot::params::package_name,
      # service_name: "knot",
      # conf_dir: $knot::params::conf_dir,
      # zone_subdir: $zonesdir/zone,
      # conf_file: $conf_dir/knot.conf,
      # run_dir: $knot::params::run_dir,
      # network_status: undef
    }
  end
  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(knot_version: '1.6.0')
      end
      case facts[:operatingsystem]
      when 'Ubuntu'
        let(:package_name) { 'knot' }
        let(:conf_dir)     { '/etc/knot' }
        let(:run_dir)      { '/run/knot' }
      else
        let(:package_name) { 'knot1' }
        let(:conf_dir)     { '/usr/local/etc/knot' }
        let(:run_dir)      { '/var/run/knot' }
      end
      let(:conf_file)   { "#{conf_dir}/knot.conf" }
      let(:zonesdir)    { "#{conf_dir}/zone" }
      let(:zone_subdir) { "#{zonesdir}/zone" }
      let(:pidfile)     { "#{run_dir}/knot.pid" }

      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package(package_name) }
        it { is_expected.to contain_class('Knot') }
        it { is_expected.to contain_class('Knot::Params') }
        it { is_expected.to contain_knot__zone('example.com') }
        it { is_expected.to contain_knot__tsig('test.example.com') }
        it { is_expected.to contain_concat__fragment('knot_key_test.example.com') }
        it { is_expected.to contain_knot__file('example.com') }
        it { is_expected.to contain_concat__fragment('knot_zones_example.com') }
        it { is_expected.to contain_knot__remote('master') }
        it { is_expected.to contain_concat__fragment('knot_remotes_master') }
        it { is_expected.to contain_concat__fragment('knot_groups_master') }
        it { is_expected.to contain_knot__remote('provide_xfr') }
        it { is_expected.to contain_concat__fragment('knot_remotes_provide_xfr') }
        it { is_expected.to contain_concat__fragment('knot_groups_provide_xfr') }
        it { is_expected.to contain_knot__remote('allow_notify_addition') }
        it do
          is_expected.to contain_concat__fragment(
            'knot_remotes_allow_notify_addition'
          )
        end
        it do
          is_expected.to contain_concat__fragment(
            'knot_groups_allow_notify_addition'
          )
        end
        it { is_expected.to contain_knot__remote('send_notify_addition') }
        it do
          is_expected.to contain_concat__fragment(
            'knot_remotes_send_notify_addition'
          )
        end
        it do
          is_expected.to contain_concat__fragment(
            'knot_groups_send_notify_addition'
          )
        end
        it do
          is_expected.to contain_concat(conf_file).with(
            notify: 'Service[knot]',
            require: "Package[#{package_name}]"
          )
        end
        it do
          is_expected.to contain_concat__fragment('knot_server').with(
            order: '10',
            target: conf_file
          ).with_content(
            %r{identity foo.example.com;}
          ).with_content(
            %r{version on;}
          ).with_content(
            %r{nsid foo.example.com;}
          ).with_content(
            %r{rundir "#{run_dir}"}
          ).with_content(
            %r{pidfile "#{pidfile}"}
          ).with_content(
            %r{workers 1;}
          ).with_content(
            %r{max-tcp-clients 250;}
          ).with_content(
            %r{max-udp-payload 4096;}
          ).with_content(
            %r{user knot;}
          ).with_content(
            %r{rate-limit 200;}
          ).with_content(
            %r{rate-limit-size 1000000;}
          ).with_content(
            %r{rate-limit-slip 2;}
          ).with_content(
            %r{interfaces\s+\{\s+interface-\d+\s+\{\s+address\s+\d+\.\d+\.\d+\.\d+;\s+port\s+53;}
          ).with_content(
            %r{control\s+\{\s+listen-on\s+\{\s+address\s+127.0.0.1@5533;\s+\}\s+allow\s+localhost;}
          ).with_content(
            %r{remotes\s+\{\s+localhost\s+\{\s+address\s+127.0.0.1;}
          ).with_content(
            %r{log\s+\{\s+syslog\s+\{\s+any\s+error;\s+zone\s+notice;\s+server\s+info;}
          )
        end
        it do
          is_expected.to contain_concat__fragment('key_head').with(
            content: %r{keys \{},
            order: '01',
            target: conf_file
          )
        end
        it do
          is_expected.to contain_concat__fragment('key_foot').with(
            content: %r{\}},
            order: '03',
            target: conf_file
          )
        end
        it do
          is_expected.to contain_concat__fragment('remote_head').with(
            content: %r{remotes \{},
            order: '11',
            target: conf_file
          )
        end
        it do
          is_expected.to contain_concat__fragment('remote_foot').with(
            content: %r{\}},
            order: '13',
            target: conf_file
          )
        end
        it do
          is_expected.to contain_concat__fragment('groups_head').with(
            content: %r{groups \{},
            order: '14',
            target: conf_file
          )
        end
        it do
          is_expected.to contain_concat__fragment('groups_foot').with(
            content: %r{\}},
            order: '16',
            target: conf_file
          )
        end
        it do
          is_expected.to contain_concat__fragment('zones_head').with(
            content: %r{zones \{},
            order: '21',
            target: conf_file
          )
        end
        it do
          is_expected.to contain_concat__fragment('zones_foot').with(
            content: %r{\}},
            order: '23',
            target: conf_file
          )
        end
        it do
          is_expected.to contain_file(zonesdir).with(
            ensure: 'directory',
            group: 'knot',
            mode: '0750',
            owner: 'knot',
            require: "Package[#{package_name}]"
          )
        end
        it do
          is_expected.to contain_file(zone_subdir).with(
            ensure: 'directory',
            group: 'knot',
            mode: '0750',
            owner: 'knot',
            require: "Package[#{package_name}]"
          )
        end
        it do
          is_expected.to contain_file(conf_dir).with(
            ensure: 'directory',
            group: 'knot',
            mode: '0750',
            owner: 'knot',
            require: "Package[#{package_name}]"
          )
        end
        it do
          is_expected.to contain_file(run_dir).with(
            ensure: 'directory',
            group: 'knot',
            mode: '0775',
            owner: 'knot',
            require: "Package[#{package_name}]"
          )
        end
        it do
          is_expected.to contain_service('knot').with(
            enable: 'true',
            ensure: 'true',
            require: "Package[#{package_name}]"
          )
        end
        if facts[:operatingsystem] == 'Ubuntu'
          it do
            is_expected.to contain_file('/etc/init/knot.conf').with(
              ensure: 'present',
              notify: 'Service[knot]'
            ).without_content(
              %r{while}
            )
          end
        end
        if facts[:operatingsystem] == 'FreeBSD'
          it do
            is_expected.to contain_file('/etc/rc.conf.d/knot').with_ensure('present')
          end
          it do
            is_expected.to contain_file_line('add knot conf file').with(
              path: '/etc/rc.conf.d/knot',
              line: "config=\"#{conf_file}\""
            )
          end
        end
      end

      describe 'Change Defaults' do
        context 'enable' do
          before { params.merge!(enable: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_service('knot').with(
              enable: 'false',
              ensure: 'false',
              require: "Package[#{package_name}]"
            )
          end
        end
        context 'slave_addresses' do
          before do
            params.merge!(slave_addresses: { '192.0.2.2' => 'foobar.example.com' })
          end
          it { is_expected.to compile }
          # Add Check to validate change was successful
        end
        context 'ip_addresses' do
          before { params.merge!(ip_addresses: ['192.0.2.2']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{interfaces\s+\{\s+interface-192022\s+\{\s+address\s+192.0.2.2;\s+port\s+53;}
            )
          end
        end
        context 'identity' do
          before { params.merge!(identity: 'bar.example.com') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{identity bar.example.com}
            )
          end
        end
        context 'nsid' do
          before { params.merge!(nsid: 'bar.example.com') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{nsid bar.example.com}
            )
          end
        end
        context 'log_target' do
          before { params.merge!(log_target: 'stdout') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{log\s+\{\s+stdout\s+\{\s+any\s+error;\s+zone\s+notice;\s+server\s+info;}
            )
          end
        end
        context 'log_zone_level' do
          before { params.merge!(log_zone_level: 'debug') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{log\s+\{\s+syslog\s+\{\s+any\s+error;\s+zone\s+debug;\s+server\s+info;}
            )
          end
        end
        context 'log_server_level' do
          before { params.merge!(log_server_level: 'debug') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{log\s+\{\s+syslog\s+\{\s+any\s+error;\s+zone\s+notice;\s+server\s+debug;}
            )
          end
        end
        context 'log_any_level' do
          before { params.merge!(log_any_level: 'debug') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{log\s+\{\s+syslog\s+\{\s+any\s+debug;\s+zone\s+notice;\s+server\s+info;}
            )
          end
        end
        context 'server_count' do
          before { params.merge!(server_count: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{workers 42;}
            )
          end
        end
        context 'max_tcp_clients' do
          before { params.merge!(max_tcp_clients: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{max-tcp-clients 42;}
            )
          end
        end
        context 'max_udp_payload' do
          before { params.merge!(max_udp_payload: 513) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{max-udp-payload 513}
            )
          end
        end
        context 'pidfile' do
          before { params.merge!(pidfile: '/knot.pid') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{pidfile "/knot.pid"}
            )
          end
        end
        context 'port' do
          before do
            params.merge!(
              port: 5353,
              ip_addresses: ['192.0.2.2']
            )
          end
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{interfaces\s+\{\s+interface-192022\s+\{\s+address\s+192.0.2.2;\s+port\s+5353;}
            )
          end
        end
        context 'username' do
          before { params.merge!(username: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{user foobar;}
            )
          end
        end
        context 'zonesdir' do
          before { params.merge!(zonesdir: '/zones') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/zones').with(
              ensure: 'directory',
              group: 'knot',
              mode: '0750',
              owner: 'knot',
              require: "Package[#{package_name}]"
            )
          end
        end
        context 'hide_version' do
          before { params.merge!(hide_version: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{version off;}
            )
          end
        end
        context 'rrl_size' do
          before { params.merge!(rrl_size: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{rate-limit-size 42;}
            )
          end
        end
        context 'rrl_limit' do
          before { params.merge!(rrl_limit: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{rate-limit 42;}
            )
          end
        end
        context 'rrl_slip' do
          before { params.merge!(rrl_slip: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{rate-limit-slip 42;}
            )
          end
        end
        context 'control_enable' do
          before { params.merge!(control_enable: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').without_content(
              %r{control\{.+\}}
            )
          end
        end
        context 'control_interface' do
          before { params.merge!(control_interface: '192.0.2.2') }
          it { is_expected.to compile }
          # Add Check to validate change was successful
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{control\s+\{\s+listen-on\s+\{\s+address\s+192.0.2.2@5533;\s+\}\s+allow\s+localhost;}
            )
          end
        end
        context 'control_port' do
          before { params.merge!(control_port: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{control\s+\{\s+listen-on\s+\{\s+address\s+127.0.0.1@42;\s+\}\s+allow\s+localhost;}
            )
          end
        end
        context 'control_allow' do
          before { params.merge!(control_allow: { 'bob' => '192.0.2.2' }) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{remotes\s+\{\s+bob\s+\{\s+address\s+192.0.2.2;}
            ).with_content(
              %r{control\s+\{\s+listen-on\s+\{\s+address\s+127.0.0.1@5533;\s+\}\s+allow\s+bob;}
            )
          end
        end
        context 'package_name' do
          before { params.merge!(package_name: 'foobar') }
          it { is_expected.to compile }
          it { is_expected.to contain_package('foobar') }
        end
        context 'service_name' do
          before { params.merge!(service_name: 'foobar') }
          it { is_expected.to compile }
          it { is_expected.to contain_service('foobar') }
        end
        context 'conf_dir' do
          before { params.merge!(conf_dir: '/conf') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/conf').with(
              ensure: 'directory',
              group: 'knot',
              mode: '0750',
              owner: 'knot',
              require: "Package[#{package_name}]"
            )
          end
        end
        context 'zone_subdir' do
          before { params.merge!(zone_subdir: '/zone') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/zone').with(
              ensure: 'directory',
              group: 'knot',
              mode: '0750',
              owner: 'knot',
              require: "Package[#{package_name}]"
            )
          end
        end
        context 'conf_file' do
          before { params.merge!(conf_file: '/knot.conf') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat('/knot.conf').with(
              notify: 'Service[knot]',
              require: "Package[#{package_name}]"
            )
          end
        end
        context 'run_dir' do
          before { params.merge!(run_dir: '/knot_run') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/knot_run').with(
              ensure: 'directory',
              group: 'knot',
              mode: '0775',
              owner: 'knot',
              require: "Package[#{package_name}]"
            )
          end
        end
      end

      # You will have to correct any values that should be bool
      describe 'check bad type' do
        context 'enable' do
          before { params.merge!(enable: []) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'tsig' do
          before { params.merge!(tsig: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'slave_addresses' do
          before { params.merge!(slave_addresses: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'zones' do
          before { params.merge!(zones: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'tsigs' do
          before { params.merge!(tsigs: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'files' do
          before { params.merge!(files: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ip_addresses' do
          before { params.merge!(ip_addresses: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'identity' do
          before { params.merge!(identity: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'nsid' do
          before { params.merge!(nsid: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'log_target' do
          before { params.merge!(log_target: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'log_target bas string' do
          before { params.merge!(log_target: 'fail') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'log_zone_level' do
          before { params.merge!(log_zone_level: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'log_server_level' do
          before { params.merge!(log_server_level: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'log_any_level' do
          before { params.merge!(log_any_level: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'server_count' do
          before { params.merge!(server_count: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'max_tcp_clients' do
          before { params.merge!(max_tcp_clients: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'max_udp_payload' do
          before { params.merge!(max_udp_payload: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'pidfile' do
          before { params.merge!(pidfile: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'port' do
          before { params.merge!(port: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'username' do
          before { params.merge!(username: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'zonesdir' do
          before { params.merge!(zonesdir: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'hide_version' do
          before { params.merge!(hide_version: 'yes') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'rrl_size' do
          before { params.merge!(rrl_size: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'rrl_limit' do
          before { params.merge!(rrl_limit: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'rrl_slip' do
          before { params.merge!(rrl_slip: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'control_enable' do
          before { params.merge!(control_enable: 'fail') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'control_interface' do
          before { params.merge!(control_interface: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'control_port' do
          before { params.merge!(control_port: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'control_allow' do
          before { params.merge!(control_allow: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'package_name' do
          before { params.merge!(package_name: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'service_name' do
          before { params.merge!(service_name: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'conf_dir' do
          before { params.merge!(conf_dir: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'zone_subdir' do
          before { params.merge!(zone_subdir: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'conf_file' do
          before { params.merge!(conf_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'run_dir' do
          before { params.merge!(run_dir: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
