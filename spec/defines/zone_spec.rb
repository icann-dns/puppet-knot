# frozen_string_literal: true

require 'spec_helper'

describe 'knot::zone' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera

  let(:title) { 'example.com' }
  let(:node) { 'foo.example.com' }
  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      # master: [],
      # notify_addresses: [],
      # allow_notify: [],
      # provide_xfr: [],
      # zones: [],
      # zonefile: undef,
      # zone_dir: undef,
    }
  end
  let(:pre_condition) do
    'class { \'::knot\':
      remotes => {
        \'master\' => { \'address4\' => \'192.0.2.1\' },
        \'provide_xfr\' => { \'address4\' => \'192.0.2.2\' },
        \'allow_notify_addition\' => { \'address4\' => \'192.0.2.3\' },
        \'send_notify_addition\' => { \'address4\' => \'192.0.2.4\' },
        \'default_master\' => { \'address4\' => \'192.0.2.5\' },
        \'default_provide_xfr\' => { \'address4\' => \'192.0.2.6\' },
      },
      default_masters => [\'default_master\'],
      default_provide_xfrs => [\'default_provide_xfr\']
    }'
  end

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:conf_file)   { "#{conf_dir}/knot.conf" }
      let(:zonesdir)    { "#{conf_dir}/zone" }
      let(:zone_subdir) { "#{zonesdir}/zone" }
      let(:pidfile)     { "#{run_dir}/knot.pid" }
      let(:package_name) { 'knot' }
      let(:conf_dir)     { '/etc/knot' }
      let(:run_dir)      { '/run/knot' }

      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_knot__zone('example.com') }

        it do
          is_expected.to contain_concat__fragment(
            'knot_zones_example.com'
          ).with_content(
            %r{
            \s+-\sdomain:\sexample.com\n
            \s+file:\s#{zone_subdir}/example.com\n
            \s+notify:\s\[default_provide_xfr-notify\]\n
            \s+acl:\s\[default_provide_xfr-transfer,\sdefault_master-notify\]\n
            \s+master:\s\[default_master\]
            }x
          )
        end
      end

      describe 'Check complete zoneset' do
        before do
          params.merge!(
            masters: ['master'],
            provide_xfrs: ['provide_xfr'],
            allow_notify_additions: ['allow_notify_addition'],
            send_notify_additions: ['send_notify_addition']
          )
        end

        it { is_expected.to compile }

        it do
          is_expected.to contain_concat__fragment(
            'knot_zones_example.com'
          ).with_content(
            %r{
            \s+-\sdomain:\sexample.com\n
            \s+file:\s#{zone_subdir}/example.com\n
            \s+notify:\s\[provide_xfr-notify,\ssend_notify_addition-notify\]\n
            \s+acl:\s\[provide_xfr-transfer,\smaster-notify,\sallow_notify_addition-notify\]\n
            \s+master:\s\[master\]
            }x
          )
        end
      end

      describe 'Change Defaults' do
        context 'zonefile' do
          before { params.merge!(zonefile: 'foobar') }

          it { is_expected.to compile }

          it do
            is_expected.to contain_concat__fragment(
              'knot_zones_example.com'
            ).with_content(
              %r{
              \s+-\sdomain:\sexample.com\n
              \s+file:\s#{zone_subdir}/foobar\n
              \s+notify:\s\[default_provide_xfr-notify\]\n
              \s+acl:\s\[default_provide_xfr-transfer,\sdefault_master-notify\]\n
              \s+master:\s\[default_master\]
              }x
            )
          end
        end

        context 'zone_dir' do
          before { params.merge!(zone_dir: '/zones') }

          it { is_expected.to compile }

          it do
            is_expected.to contain_concat__fragment(
              'knot_zones_example.com'
            ).with_content(
              %r{
              \s+-\sdomain:\sexample.com\n
              \s+file:\s/zones/example.com\n
              \s+notify:\s\[default_provide_xfr-notify\]\n
              \s+acl:\s\[default_provide_xfr-transfer,\sdefault_master-notify\]\n
              \s+master:\s\[default_master\]
              }x
            )
          end
        end
      end
    end
  end
end
