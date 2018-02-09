# frozen_string_literal: true

require 'spec_helper'

describe 'knot::file' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block

  let(:node) { 'foo.example.com' }
  let(:title) { 'example.com' }
  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      ensure: 'present',
      owner: 'root',
      group: 'knot',
      mode: '0640',
      # source: undef,
      # content: undef,
      # content_template: undef,
    }
  end
  let(:pre_condition) { 'class { \'::knot\': zone_subdir => \'/zone\' }' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      case facts[:operatingsystem]
      when 'Ubuntu'
        let(:package_name) { 'knot' }
        let(:conf_dir)     { '/etc/knot' }
        let(:run_dir)      { '/run/knot' }
      else
        let(:package_name) { 'knot2' }
        let(:conf_dir)     { '/usr/local/etc/knot' }
        let(:run_dir)      { '/var/run/knot' }
      end
      let(:conf_file)   { "#{conf_dir}/knot.conf" }
      let(:zonesdir)    { "#{conf_dir}/zone" }
      let(:zone_subdir) { '/zone' }
      let(:pidfile)     { "#{run_dir}/knot.pid" }

      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_knot__file('example.com') }
        it do
          is_expected.to contain_file("#{zone_subdir}/example.com").with(
            ensure: 'present',
            group: 'knot',
            mode: '0640',
            notify: 'Service[knot]',
            owner: 'root',
            require: "Package[#{package_name}]"
          )
        end
      end

      describe 'Change Defaults' do
        context 'owner' do
          before { params.merge!(owner: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file("#{zone_subdir}/example.com").with(
              ensure: 'present',
              group: 'knot',
              mode: '0640',
              notify: 'Service[knot]',
              owner: 'foobar',
              require: "Package[#{package_name}]"
            )
          end
        end
        context 'group' do
          before { params.merge!(group: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file("#{zone_subdir}/example.com").with(
              ensure: 'present',
              group: 'foobar',
              mode: '0640',
              notify: 'Service[knot]',
              owner: 'root',
              require: "Package[#{package_name}]"
            )
          end
        end
        context 'mode' do
          before { params.merge!(mode: '0660') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file("#{zone_subdir}/example.com").with(
              ensure: 'present',
              group: 'knot',
              mode: '0660',
              notify: 'Service[knot]',
              owner: 'root',
              require: "Package[#{package_name}]"
            )
          end
        end
        context 'source' do
          before { params.merge!(source: 'puppet:///modules/test/example.com') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file("#{zone_subdir}/example.com").with(
              ensure: 'present',
              group: 'knot',
              mode: '0640',
              notify: 'Service[knot]',
              owner: 'root',
              require: "Package[#{package_name}]",
              source: 'puppet:///modules/test/example.com'
            )
          end
        end
        context 'content' do
          before { params.merge!(content: 'zone content') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file("#{zone_subdir}/example.com").with(
              content: 'zone content',
              ensure: 'present',
              group: 'knot',
              mode: '0640',
              notify: 'Service[knot]',
              owner: 'root',
              require: "Package[#{package_name}]"
            )
          end
        end
        context 'content_template' do
          before do
            params.merge!(
              content_template: 'knot/etc/knot/hostname.as112.net.zone.erb'
            )
          end
          it { is_expected.to compile }
          it do
            is_expected.to contain_file("#{zone_subdir}/example.com").with(
              ensure: 'present',
              group: 'knot',
              mode: '0640',
              notify: 'Service[knot]',
              owner: 'root',
              require: "Package[#{package_name}]"
            ).with_content(
              %r{@ IN SOA foo.example.com}
            )
          end
        end
        context 'ensure' do
          before { params.merge!(ensure: 'absent') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file("#{zone_subdir}/example.com").with(
              ensure: 'absent'
            )
          end
        end
      end

      # You will have to correct any values that should be bool
      describe 'check bad type' do
        context 'owner' do
          before { params.merge!(owner: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'group' do
          before { params.merge!(group: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'mode' do
          before { params.merge!(mode: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'source' do
          before { params.merge!(source: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'content' do
          before { params.merge!(content: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'content_template' do
          before { params.merge!(content_template: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'ensure' do
          before { params.merge!(ensure: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
