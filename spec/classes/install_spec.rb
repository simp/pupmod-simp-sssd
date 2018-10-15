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
          it { is_expected.to contain_file('/etc/sssd').with({
            :ensure  => 'directory',
            :group   => 'root',
            :mode    => '0711',
            :require => 'Package[sssd]',
          }) }
          it { is_expected.to contain_package('sssd').with_ensure('installed') }
          it { is_expected.to contain_package('sssd-tools').with_ensure('installed') }
          it { is_expected.to contain_package('sssd-client').with_ensure('installed') }
        end

        context 'when install_user_tools = false' do
          let(:params) {{ :install_user_tools => false }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_package('sssd').with_ensure('installed') }
          it { is_expected.to_not contain_package('sssd-tools').with_ensure('installed') }
          it { is_expected.to contain_package('sssd-client').with_ensure('installed') }
        end
      end
    end
  end
end
