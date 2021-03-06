# frozen_string_literal: true

require 'spec_helper'
require 'puppet/util/package'

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
        'send_notify_addition' => { 'address4' => '192.0.2.4' },
        'default_master'      => { 'address4' => '192.0.2.5' },
        'default_provide_xfr' => { 'address4' => '192.0.2.6' }
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
  Puppet::Util::Log.level = :debug
  Puppet::Util::Log.newdestination(:console)
  # it { pp catalogue.resources }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      case facts[:operatingsystem]
      when 'FreeBSD'
        let(:package_name) { 'knot2' }
        let(:conf_dir)     { '/usr/local/etc/knot' }
        let(:run_dir)      { '/var/run/knot' }
        let(:concat_head)  { ":\n" }
        let(:concat_foot)  { "\n" }
        let(:acl_head)     { "acl:\n" }
        let(:knot_version) { '2.6.1' }
      else
        let(:package_name) { 'knot' }
        let(:conf_dir)     { '/etc/knot' }
        let(:run_dir)      { '/run/knot' }

        case facts[:lsbdistcodename]
        when 'trusty'
          let(:concat_head)  { "s {\n" }
          let(:concat_foot)  { "}\n" }
          let(:acl_head)     { "groups {\n" }
          let(:knot_version) { '1.4.2' }
        else
          let(:concat_head)  { ":\n" }
          let(:concat_foot)  { "\n" }
          let(:acl_head)     { "acl:\n" }
          let(:knot_version) { '2.2.1' }
        end
      end
      let(:conf_file)   { "#{conf_dir}/knot.conf" }
      let(:zonesdir)    { "#{conf_dir}/zone" }
      let(:zone_subdir) { "#{zonesdir}/zone" }
      let(:pidfile)     { "#{run_dir}/knot.pid" }
      let(:facts)       { facts.merge(knot_version: knot_version) }

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
        it { is_expected.to contain_concat__fragment('knot_acl_master') }
        it { is_expected.to contain_knot__remote('default_master') }
        it { is_expected.to contain_concat__fragment('knot_remotes_default_master') }
        it { is_expected.to contain_concat__fragment('knot_acl_default_master') }
        it { is_expected.to contain_knot__remote('provide_xfr') }
        it { is_expected.to contain_concat__fragment('knot_remotes_provide_xfr') }
        it { is_expected.to contain_knot__remote('default_provide_xfr') }
        it { is_expected.to contain_concat__fragment('knot_acl_provide_xfr') }
        it { is_expected.to contain_concat__fragment('knot_remotes_default_provide_xfr') }
        it { is_expected.to contain_concat__fragment('knot_acl_default_provide_xfr') }
        it { is_expected.to contain_knot__remote('allow_notify_addition') }
        it do
          is_expected.to contain_concat__fragment(
            'knot_remotes_allow_notify_addition'
          )
        end
        it do
          is_expected.to contain_concat__fragment(
            'knot_acl_allow_notify_addition'
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
            'knot_acl_send_notify_addition'
          )
        end
        it do
          is_expected.to contain_concat(conf_file).with(
            notify: 'Service[knot]',
            require: "Package[#{package_name}]"
          )
        end
        if facts[:operatingsystem] == 'Ubuntu' &&
           facts[:lsbdistcodename] == 'trusty'
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
              %r{workers #{facts[:processors]['count']};}
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
              %r{
              interfaces
              \s+\{
              \s+interface-\d+\s+\{
              \s+address\s+\d+\.\d+\.\d+\.\d+;
              \s+port\s+53;
              }x
            ).with_content(
              %r{
              control\s+\{
              \s+listen-on
              \s+\{
              \s+address\s+127.0.0.1@5533;
              \s+\}
              \s+allow\s+localhost_remote;
              }x
            ).with_content(
              %r{
              remotes\s+\{
              \s+localhost_remote\s+\{
              \s+address\s+127.0.0.1;
              }x
            ).with_content(
              %r{
              log\s+\{
              \s+syslog\s+\{
              \s+any\s+error;
              \s+zone\s+notice;
              \s+server\s+info;
              }x
            )
          end
        else
          it do
            is_expected.to contain_concat__fragment('knot_server').with(
              order: '10',
              target: conf_file
            ).with_content(
              %r{identity: foo.example.com}
            ).without_content(
              %r{version:}
            ).with_content(
              %r{nsid: foo.example.com}
            ).with_content(
              %r{rundir: #{run_dir}}
            ).with_content(
              %r{pidfile: #{pidfile}}
            ).with_content(
              %r{background-workers: 1}
            ).with_content(
              %r{tcp-workers: 1}
            ).with_content(
              %r{udp-workers: 1}
            ).with_content(
              %r{max-udp-payload: 4096}
            ).with_content(
              %r{user: knot}
            ).with_content(
              %r{listen: \[\d+\.\d+\.\d+\.\d+\]}
            ).with_content(
              %r{control:\n\s+listen: #{run_dir}/knot.sock}
            ).with_content(
              %r{
              log:\n
              \s+-\starget:\ssyslog\n
              \s+any:\serror\n
              \s+zone:\snotice\n
              \s+server:\sinfo
              }x
            )
          end
          it do
            if Puppet::Util::Package.versioncmp(knot_version, '2.4') < 0
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{rate-limit: 200}
              ).with_content(
                %r{rate-limit-table-size: 1000000}
              ).with_content(
                %r{rate-limit-slip: 2}
              )
            else
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{
                mod-rrl:
                \s+-\sid:\sdefault
                \s+rate-limit:\s200
                \s+table-size:\s1000000
                \s+slip:\s2
                }x
              ).with_content(
                %r{
                template:
                \s+-\sid:\sdefault
                \s+global-module:\smod-rrl/default
                }x
              )
            end
          end
        end
        it do
          is_expected.to contain_concat__fragment('key_head').with(
            content: "key#{concat_head}",
            order: '01',
            target: conf_file
          )
        end
        it do
          is_expected.to contain_concat__fragment('key_foot').with(
            content: concat_foot,
            order: '03',
            target: conf_file
          )
        end
        it do
          is_expected.to contain_concat__fragment('remote_head').with(
            content: "remote#{concat_head}",
            order: '11',
            target: conf_file
          )
        end
        it do
          is_expected.to contain_concat__fragment('remote_foot').with(
            content: concat_foot,
            order: '13',
            target: conf_file
          )
        end
        it do
          is_expected.to contain_concat__fragment('acl_head').with(
            content: acl_head,
            order: '14',
            target: conf_file
          )
        end
        it do
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            is_expected.to contain_concat__fragment('acl_foot').with(
              content: %r{slave_servers \{\}\s+slave_servers_notify \{\}},
              order: '16',
              target: conf_file
            )
          else
            is_expected.to contain_concat__fragment('acl_foot').with(
              content: concat_foot,
              order: '16',
              target: conf_file
            )
          end
        end
        it do
          is_expected.to contain_concat__fragment('zones_head').with(
            content: "zone#{concat_head}",
            order: '21',
            target: conf_file
          )
        end
        it do
          is_expected.to contain_concat__fragment('zones_foot').with(
            content: concat_foot,
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
        context 'ip_addresses' do
          before { params.merge!(ip_addresses: ['192.0.2.2']) }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{
                interfaces\s+\{
                \s+interface-192022\s+\{
                \s+address\s+192.0.2.2;\s+port\s+53;
                }x
              )
            end
          else
            id do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{listen: \[192\.0\.2\.2\]}
              )
            end
          end
        end
        context 'identity' do
          before { params.merge!(identity: 'bar.example.com') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{identity:? bar.example.com}
            )
          end
        end
        context 'nsid' do
          before { params.merge!(nsid: 'bar.example.com') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{nsid:? bar.example.com}
            )
          end
        end
        context 'log_target' do
          before { params.merge!(log_target: 'stdout') }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{log\s+\{
                \s+stdout\s+\{
                \s+any\s+error;
                \s+zone\s+notice;
                \s+server\s+info;
                }x
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{
                log:\n
                \s+-\starget:\sstdout\n
                \s+any:\serror\n
                \s+zone:\snotice\n
                \s+server:\sinfo
                }x
              )
            end
          end
        end
        context 'log_zone_level' do
          before { params.merge!(log_zone_level: 'debug') }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{log\s+\{
                \s+syslog\s+\{
                \s+any\s+error;
                \s+zone\s+debug;
                \s+server\s+info;
                }x
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{
                log:\n
                \s+-\starget:\ssyslog\n
                \s+any:\serror\n
                \s+zone:\sdebug\n
                \s+server:\sinfo
                }x
              )
            end
          end
        end
        context 'log_server_level' do
          before { params.merge!(log_server_level: 'debug') }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{log\s+\{
                \s+syslog\s+\{
                \s+any\s+error;
                \s+zone\s+notice;
                \s+server\s+debug;
                }x
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{
                log:\n
                \s+-\starget:\ssyslog\n
                \s+any:\serror\n
                \s+zone:\snotice\n
                \s+server:\sdebug
                }x
              )
            end
          end
        end
        context 'log_any_level' do
          before { params.merge!(log_any_level: 'debug') }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{log\s+\{
                \s+syslog\s+\{
                \s+any\s+debug;
                \s+zone\s+notice;
                \s+server\s+info;
                }x
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{
                log:\n
                \s+-\starget:\ssyslog\n
                \s+any:\sdebug\n
                \s+zone:\snotice\n
                \s+server:\sinfo
                }x
              )
            end
          end
        end
        context 'server_count' do
          before { params.merge!(server_count: 42) }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{workers 42;}
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{background-workers: 1}
              ).with_content(
                %r{tcp-workers: 8}
              ).with_content(
                %r{udp-workers: 33}
              )
            end
          end
        end
        context 'max_tcp_clients' do
          before { params.merge!(max_tcp_clients: 42) }
          it { is_expected.to compile }
          it do
            if Puppet::Util::Package.versioncmp(knot_version, '1.6') < 0
              is_expected.to contain_concat__fragment(
                'knot_server'
              ).without_content(
                %r{max-tcp-clients:? 42;?}
              )
            else
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{max-tcp-clients:? 42;?}
              )
            end
          end
        end
        context 'max_udp_payload' do
          before { params.merge!(max_udp_payload: 513) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{max-udp-payload:? 513}
            )
          end
        end
        context 'pidfile' do
          before { params.merge!(pidfile: '/knot.pid') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{pidfile:? "?/knot.pid"?}
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
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{interfaces\s+\{
                \s+interface-192022\s+\{
                \s+address\s+192.0.2.2;\s+port\s+5353;
                }x
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{listen: \[192\.0\.2\.2\@5353\]}
              )
            end
          end
        end
        context 'username' do
          before { params.merge!(username: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment('knot_server').with_content(
              %r{user:? foobar;?}
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
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{version off;}
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{version: hidden}
              )
            end
          end
        end
        context 'rrl_size' do
          before { params.merge!(rrl_size: 42) }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{rate-limit-size 42}
              )
            end
          else
            it do
              if Puppet::Util::Package.versioncmp(knot_version, '2.4') < 0
                is_expected.to contain_concat__fragment(
                  'knot_server'
                ).with_content(
                  %r{rate-limit-table-size: 42}
                )
              else
                is_expected.to contain_concat__fragment(
                  'knot_server'
                ).with_content(
                  %r{
                  mod-rrl:
                  \s+-\sid:\sdefault
                  \s+rate-limit:\s200
                  \s+table-size:\s42
                  \s+slip:\s2
                  }x
                )
              end
            end
          end
        end
        context 'rrl_limit' do
          before { params.merge!(rrl_limit: 42) }
          it { is_expected.to compile }
          it do
            if Puppet::Util::Package.versioncmp(knot_version, '2.4') < 0
              is_expected.to contain_concat__fragment(
                'knot_server'
              ).with_content(
                %r{rate-limit:? 42;?}
              )
            else
              is_expected.to contain_concat__fragment(
                'knot_server'
              ).with_content(
                %r{
                mod-rrl:
                \s+-\sid:\sdefault
                \s+rate-limit:\s42
                \s+table-size:\s1000000
                \s+slip:\s2
                }x
              )
            end
          end
        end
        context 'rrl_slip' do
          before { params.merge!(rrl_slip: 42) }
          it { is_expected.to compile }
          it do
            if Puppet::Util::Package.versioncmp(knot_version, '2.4') < 0
              is_expected.to contain_concat__fragment(
                'knot_server'
              ).with_content(
                %r{rate-limit-slip:? 42;?}
              )
            else
              is_expected.to contain_concat__fragment(
                'knot_server'
              ).with_content(
                %r{
                mod-rrl:
                \s+-\sid:\sdefault
                \s+rate-limit:\s200
                \s+table-size:\s1000000
                \s+slip:\s42
                }x
              )
            end
          end
        end
        context 'control_enable' do
          before { params.merge!(control_enable: false) }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment(
                'knot_server'
              ).without_content(%r{control\{.+\}})
            end
          else
            it do
              is_expected.to contain_concat__fragment(
                'knot_server'
              ).without_content(%r{control:\n\s+listen:})
            end
          end
        end
        context 'control_interface' do
          before { params.merge!(control_interface: '192.0.2.2') }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{
                control\s+\{
                \s+listen-on\s+\{
                \s+address\s+192.0.2.2@5533;
                \s+\}
                \s+allow\s+localhost_remote;
                }x
              )
            end
          end
        end
        context 'control_port' do
          before { params.merge!(control_port: 42) }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{
                control\s+\{
                \s+listen-on\s+\{
                \s+address\s+127.0.0.1@42;
                \s+\}
                \s+allow\s+localhost_remote;
                }x
              )
            end
          end
        end
        context 'control_allow' do
          before { params.merge!(control_allow: { 'bob' => '192.0.2.2' }) }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment('knot_server').with_content(
                %r{remotes\s+\{\s+bob\s+\{\s+address\s+192.0.2.2;}
              ).with_content(
                %r{control\s+\{
                \s+listen-on\s+\{
                \s+address\s+127.0.0.1@5533;
                \s+\}
                \s+allow\s+bob;
                }x
              )
            end
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
