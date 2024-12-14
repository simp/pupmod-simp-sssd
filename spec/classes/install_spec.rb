require 'spec_helper'

describe 'sssd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:precondition) { "include 'sssd'" }

        context 'with_defaults' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd::install') }
          it { is_expected.to create_class('sssd::install::client') }
          it { is_expected.to contain_package('sssd').with_ensure('installed') }
          it { is_expected.to contain_package('sssd-tools').with_ensure('installed') }
          it { is_expected.to contain_package('sssd-dbus').with_ensure('installed') }
          it { is_expected.to contain_package('sssd-client').with_ensure('installed') }
        end

        context 'when install* params set to other then default' do
          let(:hieradata) { 'sssd_install' }
          let(:params) { { services: ['nss', 'pam', 'ifp'] } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_package('sssd').with_ensure('installed') }
          it { is_expected.not_to contain_package('sssd-tools').with_ensure('installed') }
          it { is_expected.to contain_package('sssd-client').with_ensure('installed') }
          it { is_expected.to contain_package('sssd-dbus').with_ensure('installed') }
        end
      end
    end
  end
end
