require 'spec_helper'

describe 'sssd::install' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts }

        context 'with_defaults' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd::install') }
          it { is_expected.to create_class('sssd::install::client') }
          it {
            if facts[:operatingsystemmajrelease] > '6'
              is_expected.to contain_file('/etc/sssd').with({
                :ensure  => 'directory',
                :owner   => 'sssd',
                :group   => 'root',
                :mode   => '0640',
                :require   => 'Package[sssd]',
              })
            else
              is_expected.to contain_file('/etc/sssd').with({
                :ensure  => 'directory',
                :owner   => 'root',
                :group   => 'root',
                :mode   => '0640',
                :require   => 'Package[sssd]',
              })
            end
          }

          it { is_expected.to contain_package('sssd').with_ensure('latest') }
          it { is_expected.to contain_package('sssd-tools').with_ensure('latest') }
          it { is_expected.to contain_package('sssd-client').with_ensure('latest') }
        end

        context 'when install_user_tools = false' do
          let(:params) {{ :install_user_tools => false }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_package('sssd').with_ensure('latest') }
          it { is_expected.to_not contain_package('sssd-tools').with_ensure('latest') }
          it { is_expected.to contain_package('sssd-client').with_ensure('latest') }
        end

        context 'when package_ensure = installed' do
          let(:params) {{ :package_ensure =>  'installed' }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_package('sssd').with_ensure('installed') }
          it { is_expected.to contain_package('sssd-tools').with_ensure('installed') }
          it { is_expected.to contain_package('sssd-client').with_ensure('installed') }
        end
      end
    end
  end
end
