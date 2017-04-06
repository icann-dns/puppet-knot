# frozen_string_literal: true

require 'spec_helper'

describe 'knot::tsig' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block

  let(:title) { 'foo.example.com' }
  let(:pre_condition) { 'class { \'::knot\': }' }
  let(:node) { 'foo.example.com' }
  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      # algo: "hmac-sha256",
      data: 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
      # template: "knot/etc/knot/knot.key.conf.erb",
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

      describe 'check default config' do
        # add these two lines in a single test block to enable puppet and hiera debug mode
        # Puppet::Util::Log.level = :debug
        # Puppet::Util::Log.newdestination(:console)
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_knot__tsig('foo.example.com') }
        it do
          is_expected.to contain_concat__fragment(
            'knot_key_foo.example.com'
          ).with_content(
            %r{foo.example.com hmac-sha256 "A+="}
          ).with_order('02')
        end
      end

      describe 'Change Defaults' do
        context 'algo' do
          before { params.merge!(algo: 'hmac-md5') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'knot_key_foo.example.com'
            ).with_content(
              %r{foo.example.com hmac-md5 "A+="}
            ).with_order('02')
          end
        end
        context 'data' do
          before { params.merge!(data: 'foobar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_concat__fragment(
              'knot_key_foo.example.com'
            ).with_content(
              %r{foo.example.com hmac-sha256 "foobar"}
            ).with_order('02')
          end
        end
      end

      # You will have to correct any values that should be bool
      describe 'check bad type' do
        context 'algo' do
          before { params.merge!(algo: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'algo unsupported' do
          before { params.merge!(algo: 'mac-sha2') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'data' do
          before { params.merge!(data: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'template' do
          before { params.merge!(template: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
