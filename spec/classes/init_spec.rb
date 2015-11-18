require 'spec_helper'

describe 'sssd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('sssd') }
        it { is_expected.to create_class('sssd::install').that_notifies('Class[sssd::service]') }
        it { is_expected.to create_class('sssd::service') }
        it { is_expected.to contain_class('pki') }

        it { is_expected.to contain_concat_build('sssd').with({
            :target => '/etc/sssd/sssd.conf',
            :notify => 'File[/etc/sssd/sssd.conf]'
          })
        }

        it { is_expected.to contain_file('/etc/init.d/sssd').with({
            :ensure  => 'file',
            :source  => 'puppet:///modules/sssd/sssd.sysinit',
            :notify  => 'Service[sssd]'
          })
        }

        it { is_expected.to contain_file('/etc/sssd').with({
            :ensure  => 'directory'
          })
        }

        it { is_expected.to contain_file('/etc/sssd/sssd.conf').with({
            :ensure  => 'file'
          })
        }

        it { is_expected.to contain_package('sssd').with_ensure('latest') }
        it { is_expected.to contain_service('nscd').with({
            :ensure => 'stopped',
            :enable => false,
            :notify => 'Service[sssd]'
          })
        }

        it { is_expected.to contain_service('sssd').with({
            :ensure    => 'running'
          })
        }
      end
    end
  end
end
