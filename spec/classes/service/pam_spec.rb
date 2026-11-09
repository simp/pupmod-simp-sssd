require 'spec_helper'
require_relative '../../lib/sssd_spec_helpers'

describe 'sssd::service::pam' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        context 'with default params' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd::service') }

          # Every setting is left alone until its parameter is set.
          it { is_expected.to have_ini_setting_resource_count(0) }
          it { is_expected.not_to contain_file('/etc/sssd/conf.d/50_puppet_service_pam.conf') }
        end

        context 'with parameters' do
          let(:params) do
            {
              debug_timestamps: true,
              reconnection_retries: 3,
              offline_failed_login_attempts: 3,
              pam_verbosity: 1,
              pam_cert_auth: true,
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/etc/sssd/conf.d/50_puppet_service_pam.conf').that_requires('Package[sssd]') }
          it { expect(entry_content('puppet_service_pam')).to eq(<<~CONTENT) }
            [pam]
            debug_timestamps = true
            reconnection_retries = 3
            offline_failed_login_attempts = 3
            pam_verbosity = 1
            pam_cert_auth = True
            CONTENT
        end

        context 'with a setting set to absent' do
          let(:params) { { debug_level: 'absent' } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_ini_setting('sssd /etc/sssd/conf.d/50_puppet_service_pam.conf [pam] debug_level').with_ensure('absent') }
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
          it { is_expected.to contain_ini_setting('sssd /etc/sssd/conf.d/50_puppet_service_pam.conf [pam] key1').with_value('value1') }
          it { is_expected.to contain_ini_setting('sssd /etc/sssd/conf.d/50_puppet_service_pam.conf [pam] key2').with_ensure('absent') }
          it { is_expected.not_to contain_ini_setting('sssd /etc/sssd/conf.d/50_puppet_service_pam.conf [pam] debug_level') }
        end

        context 'with pam_cert_auth disabled' do
          let(:params) { { pam_cert_auth: false } }

          it { is_expected.to contain_ini_setting('sssd /etc/sssd/conf.d/50_puppet_service_pam.conf [pam] pam_cert_auth').with_value('False') }
        end
      end
    end
  end
end
