require 'spec_helper'
require_relative '../../lib/sssd_spec_helpers'

describe 'sssd::service::autofs' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        context 'with default params' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd::service') }

          # Every setting is left alone until its parameter is set.
          it { is_expected.to have_ini_setting_resource_count(0) }
          it { is_expected.not_to contain_file('/etc/sssd/conf.d/50_puppet_service_autofs.conf') }
        end

        context 'with parameters' do
          let(:params) do
            {
              debug_timestamps: true,
              debug_microseconds: false,
              autofs_negative_timeout: 10,
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/etc/sssd/conf.d/50_puppet_service_autofs.conf').that_requires('Package[sssd]') }
          it { expect(entry_content('puppet_service_autofs')).to eq(<<~CONTENT) }
            [autofs]
            debug_timestamps = true
            debug_microseconds = false
            autofs_negative_timeout = 10
            CONTENT
        end

        context 'with a setting set to absent' do
          let(:params) { { debug_level: 'absent' } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_ini_setting('sssd /etc/sssd/conf.d/50_puppet_service_autofs.conf [autofs] debug_level').with_ensure('absent') }
        end

        context 'with custom_options' do
          let(:params) do
            {
              debug_level: 5,
              custom_options: { 'key1' => 'value1', 'key2' => 'absent' },
            }
          end

          it { is_expected.to compile.with_all_deps }

          # The custom options are managed instead of the typed parameters.
          it { is_expected.to contain_ini_setting('sssd /etc/sssd/conf.d/50_puppet_service_autofs.conf [autofs] key1').with_value('value1') }
          it { is_expected.to contain_ini_setting('sssd /etc/sssd/conf.d/50_puppet_service_autofs.conf [autofs] key2').with_ensure('absent') }
          it { is_expected.not_to contain_ini_setting('sssd /etc/sssd/conf.d/50_puppet_service_autofs.conf [autofs] debug_level') }
        end
      end
    end
  end
end
