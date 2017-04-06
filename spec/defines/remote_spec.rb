# frozen_string_literal: true

require 'spec_helper'

describe 'knot::remote' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block

  let(:title) { 'xfr.example.com' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      address4: '192.0.2.1',
      # :address6 => :undef,
      # :tsig_name => :undef,
      # :port => '53',

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  let(:pre_condition) do
    'class {\'::knot\':
      tsigs => { \'example_tsig\' => { \'data\' => \'AAAA\' } }
    }'
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
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
        it do
          is_expected.to contain_concat__fragment(
            'knot_remotes_xfr.example.com'
          ).with_target(conf_file).with_order('12').with_content(
            %r{xfr.example.com-ipv4 \{\s+address 192.0.2.1;\s+port 53;\s+\}}
          )
        end
        it do
          is_expected.to contain_concat__fragment(
            'knot_groups_xfr.example.com'
          ).with_target(conf_file).with_order('15').with_content(
            %r{xfr.example.com \{ xfr.example.com-ipv4 \}}
          )
        end
      end
      describe 'Change Defaults' do
        context 'ipv4 cidr only' do
          before { params.merge!(address4: '192.0.2.0/24') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'knot_remotes_xfr.example.com'
            ).with_target(conf_file).with_order('12').with_content(
              %r{xfr.example.com-ipv4 \{\s+address 192.0.2.0/24;\s+port 53;\s+\}}
            )
          end
          it do
            is_expected.to contain_concat__fragment(
              'knot_groups_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{xfr.example.com \{ xfr.example.com-ipv4 \}}
            )
          end
        end
        context 'ipv6 only' do
          before { params.merge!(address4: :undef, address6: '2001:DB8::1') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'knot_remotes_xfr.example.com'
            ).with_target(conf_file).with_order('12').with_content(
              %r{xfr.example.com-ipv6 \{\s+address 2001:DB8::1;\s+port 53;\s+\}}
            )
          end
          it do
            is_expected.to contain_concat__fragment(
              'knot_groups_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{xfr.example.com \{ xfr.example.com-ipv6 \}}
            )
          end
        end
        context 'ipv6 cidr only' do
          before { params.merge!(address4: :undef, address6: '2001:DB8::/48') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'knot_remotes_xfr.example.com'
            ).with_target(conf_file).with_order('12').with_content(
              %r{xfr.example.com-ipv6 \{\s+address 2001:DB8::/48;\s+port 53;\s+\}}
            )
          end
          it do
            is_expected.to contain_concat__fragment(
              'knot_groups_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{xfr.example.com \{ xfr.example.com-ipv6 \}}
            )
          end
        end
        context 'ipv4 and ipv6' do
          before { params.merge!(address6: '2001:DB8::1') }
          it { is_expected.to compile }
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
              'knot_groups_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{xfr.example.com \{ xfr.example.com-ipv4, xfr.example.com-ipv6 \}}
            )
          end
        end
        context 'ipv4 and ipv6 cidr' do
          before do
            params.merge!(address4: '192.0.2.0/24', address6: '2001:DB8::/48')
          end
          it { is_expected.to compile }
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
              'knot_groups_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{xfr.example.com \{ xfr.example.com-ipv4, xfr.example.com-ipv6 \}}
            )
          end
        end
        context 'tsig_name' do
          before { params.merge!(tsig_name: 'example_tsig') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'knot_remotes_xfr.example.com'
            ).with_target(conf_file).with_order('12').with_content(
              %r{xfr.example.com-ipv4 \{\s+address 192.0.2.1;\s+port 53;\s+key example_tsig;\s+\}}
            )
          end
          it do
            is_expected.to contain_concat__fragment(
              'knot_groups_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{xfr.example.com \{ xfr.example.com-ipv4 \}}
            )
          end
        end
        context 'port' do
          before { params.merge!(port: 5353) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'knot_remotes_xfr.example.com'
            ).with_target(conf_file).with_order('12').with_content(
              %r{xfr.example.com-ipv4 \{\s+address 192.0.2.1;\s+port 5353;\s+\}}
            )
          end
          it do
            is_expected.to contain_concat__fragment(
              'knot_groups_xfr.example.com'
            ).with_target(conf_file).with_order('15').with_content(
              %r{xfr.example.com \{ xfr.example.com-ipv4 \}}
            )
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
