# frozen_string_literal: true

require 'spec_helper'

describe 'knot::remote' do
  let(:title) { 'xfr.example.com' }
  let(:params) do
    {
      address4: '192.0.2.1',
      # :address6 => :undef,
      # :tsig_name => :undef,
      # :port => '53',

    }
  end
  let(:pre_condition) do
    'class {\'::knot\':
      tsigs => { \'example_tsig\' => { \'data\' => \'AAAA\' } }
    }'
  end

  # add these two lines in a single test block to enable puppet &&hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      case facts[:operatingsystem]
      when 'Ubuntu'
        let(:conf_dir) { '/etc/knot' }
      else
        let(:conf_dir) { '/usr/local/etc/knot' }
      end
      let(:conf_file) { "#{conf_dir}/knot.conf" }

      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_knot__tsig('example_tsig') }
        it { is_expected.to contain_concat__fragment('knot_key_example_tsig') }
        if facts[:operatingsystem] == 'Ubuntu' &&
           facts[:lsbdistcodename] == 'trusty'
          it do
            is_expected.to contain_concat__fragment(
              'knot_remotes_xfr.example.com'
            ).with_target(conf_file).with_order('12').with_content(
              %r{xfr.example.com-ipv4 \{\s+address 192.0.2.1;\s+port 53;\s+\}}
            )
          end
          it do
            is_expected.to contain_concat__fragment(
              'knot_acl_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{xfr.example.com \{ xfr.example.com-ipv4 \}}
            )
          end
        else
          it do
            is_expected.to contain_concat__fragment(
              'knot_remotes_xfr.example.com'
            ).with_target(conf_file).with_order('12').with_content(
              %r{
              \s+-\sid:\sxfr.example.com\n
              \s+address:\s\[192.0.2.1\]
              }x
            )
          end
          it do
            is_expected.to contain_concat__fragment(
              'knot_acl_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{
              \s+-\sid:\sxfr.example.com-notify\n
              \s+address:\s\[192.0.2.1\]\n
              \s+action:\snotify\n
              }x
            ).with_content(
              %r{
              \s+-\sid:\sxfr.example.com-transfer\n
              \s+address:\s\[192.0.2.1\]\n
              \s+action:\stransfer\n
              }x
            )
          end
        end
      end
      describe 'Change Defaults' do
        context 'ipv4 cidr only' do
          before { params.merge!(address4: '192.0.2.0/24') }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{xfr.example.com-ipv4 \{\s+address 192.0.2.0/24;\s+port 53;\s+\}}
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{xfr.example.com \{ xfr.example.com-ipv4 \}}
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{
                \s+-\sid:\sxfr.example.com\n
                \s+address:\s\[192.0.2.0\]
                }x
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{
                \s+-\sid:\sxfr.example.com-notify\n
                \s+address:\s\[192.0.2.0/24\]\n
                \s+action:\snotify\n
                }x
              ).with_content(
                %r{
                \s+-\sid:\sxfr.example.com-transfer\n
                \s+address:\s\[192.0.2.0/24\]\n
                \s+action:\stransfer\n
                }x
              )
            end
          end
        end
        context 'ipv6 only' do
          before { params.merge!(address4: :undef, address6: '2001:DB8::1') }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{xfr.example.com-ipv6 \{\s+address 2001:DB8::1;\s+port 53;\s+\}}
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{xfr.example.com \{ xfr.example.com-ipv6 \}}
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{
                \s+-\sid:\sxfr.example.com\n
                \s+address:\s\[2001:DB8::1\]
                }x
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{
                \s+-\sid:\sxfr.example.com-notify\n
                \s+address:\s\[2001:DB8::1\]\n
                \s+action:\snotify
                }x
              ).with_content(
                %r{
                \s+-\sid:\sxfr.example.com-transfer\n
                \s+address:\s\[2001:DB8::1\]\n
                \s+action:\stransfer
                }x
              )
            end
          end
        end
        context 'ipv6 cidr only' do
          before { params.merge!(address4: :undef, address6: '2001:DB8::/48') }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{xfr.example.com-ipv6 \{\s+address 2001:DB8::/48;\s+port 53;\s+\}}
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{xfr.example.com \{ xfr.example.com-ipv6 \}}
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{
                \s+-\sid:\sxfr.example.com\n
                \s+address:\s\[2001:DB8::\]
                }x
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{
                \s+-\sid:\sxfr.example.com-notify\n
                \s+address:\s\[2001:DB8::/48\]\n
                \s+action:\snotify
                }x
              ).with_content(
                %r{
                \s+-\sid:\sxfr.example.com-transfer\n
                \s+address:\s\[2001:DB8::/48\]\n
                \s+action:\stransfer
                }x
              )
            end
          end
        end
        context 'ipv4 &&ipv6' do
          before { params.merge!(address6: '2001:DB8::1') }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{xfr.example.com-ipv4 \{\s+address 192.0.2.1;\s+port 53;\s+\}}
              ).with_content(
                %r{xfr.example.com-ipv6 \{\s+address 2001:DB8::1;\s+port 53;\s+\}}
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{xfr.example.com \{ xfr.example.com-ipv4, xfr.example.com-ipv6 \}}
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{
                \s+-\sid:\sxfr.example.com\n
                \s+address:\s\[192.0.2.1,\s2001:DB8::1\]
                }x
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{
                \s+-\sid:\sxfr.example.com-notify\n
                \s+address:\s\[192.0.2.1,\s2001:DB8::1\]\n
                \s+action:\snotify
                }x
              ).with_content(
                %r{
                \s+-\sid:\sxfr.example.com-transfer\n
                \s+address:\s\[192.0.2.1,\s2001:DB8::1\]\n
                \s+action:\stransfer
                }x
              )
            end
          end
        end
        context 'ipv4 &&ipv6 cidr' do
          before do
            params.merge!(address4: '192.0.2.0/24', address6: '2001:DB8::/48')
          end
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{xfr.example.com-ipv4 \{\s+address 192.0.2.0/24;\s+port 53;\s+\}}
              ).with_content(
                %r{xfr.example.com-ipv6 \{\s+address 2001:DB8::/48;\s+port 53;\s+\}}
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{xfr.example.com \{ xfr.example.com-ipv4, xfr.example.com-ipv6 \}}
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{
                \s+-\sid:\sxfr.example.com\n
                \s+address:\s\[192.0.2.0,\s2001:DB8::\]
                }x
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{
                \s+-\sid:\sxfr.example.com-notify\n
                \s+address:\s\[192.0.2.0/24,\s2001:DB8::/48\]\n
                \s+action:\snotify\n
                }x
              ).with_content(
                %r{
                \s+-\sid:\sxfr.example.com-transfer\n
                \s+address:\s\[192.0.2.0/24,\s2001:DB8::/48\]\n
                \s+action:\stransfer\n
                }x
              )
            end
          end
        end
        context 'tsig_name' do
          before { params.merge!(tsig_name: 'example_tsig') }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{xfr.example.com-ipv4 \{\s+address 192.0.2.1;\s+port 53;\s+key example_tsig;\s+\}}
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{xfr.example.com \{ xfr.example.com-ipv4 \}}
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{
                \s+-\sid:\sxfr.example.com\n
                \s+address:\s\[192.0.2.1\]\n
                \s+key:\sexample_tsig
                }x
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{
                \s+-\sid:\sxfr.example.com-notify\n
                \s+address:\s\[192.0.2.1\]\n
                \s+action:\snotify\n
                }x
              ).with_content(
                %r{
                \s+-\sid:\sxfr.example.com-transfer\n
                \s+address:\s\[192.0.2.1\]\n
                \s+key:\sexample_tsig
                \s+action:\stransfer\n
                }x
              )
            end
          end
        end
        context 'port' do
          before { params.merge!(port: 5353) }
          it { is_expected.to compile }
          if facts[:operatingsystem] == 'Ubuntu' &&
             facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{xfr.example.com-ipv4 \{\s+address 192.0.2.1;\s+port 5353;\s+\}}
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{xfr.example.com \{ xfr.example.com-ipv4 \}}
              )
            end
          else
            it do
              is_expected.to contain_concat__fragment(
                'knot_remotes_xfr.example.com'
              ).with_target(conf_file).with_order('12').with_content(
                %r{
                \s+-\sid:\sxfr.example.com\n
                \s+address:\s\[192.0.2.1@5353\]
                }x
              )
            end
            it do
              is_expected.to contain_concat__fragment(
                'knot_acl_xfr.example.com'
              ).with_target(conf_file).with_order('15').with_content(
                %r{
                \s+-\sid:\sxfr.example.com-notify\n
                \s+address:\s\[192.0.2.1@5353\]\n
                \s+action:\snotify\n
                }x
              ).with_content(
                %r{
                \s+-\sid:\sxfr.example.com-transfer\n
                \s+address:\s\[192.0.2.1@5353\]\n
                \s+action:\stransfer\n
                }x
              )
            end
          end
        end
      end
      describe 'check bad type' do
        context 'address4' do
          before { params.merge!(address4: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'address4' do
          before { params.merge!(address4: '333.333.333.333') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'address6' do
          before { params.merge!(address6: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'tsig_name' do
          before { params.merge!(tsig_name: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'port' do
          before { params.merge!(port: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
