require 'spec_helper'

describe 'sssd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }

        context 'with_defaults' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd') }
          it { is_expected.to create_class('sssd::install').that_notifies('Class[sssd::service]') }
          it { is_expected.to create_class('sssd::service') }
          it { is_expected.to_not create_class('sssd::pki') }
          it { is_expected.to_not contain_class('pki') }
          it { is_expected.to_not create_pki__copy('/etc/pki/sssd') }
          it { is_expected.to_not create_file('/etc/pki/simp_apps/sssd/x509')}
          it { is_expected.to_not create_class('auditd') }

          it { is_expected.to contain_simpcat_build('sssd').with({
            :target => '/etc/sssd/sssd.conf',
            :notify => '[File[/etc/sssd/sssd.conf]{:path=>"/etc/sssd/sssd.conf"}, Class[Sssd::Service]{:name=>"Sssd::Service"}]'
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

        context 'with_auditd_true' do
          let(:params) {{ :auditd => true }}

          it { is_expected.to create_class('auditd')}
          it { is_expected.to create_auditd__add_rules('sssd').with({
            :content => '-w /etc/sssd/ -p wa -k CFG_sssd' }) }
        end

        context 'with pki = true' do
          let(:params) {{ :pki      => true}}

          it { is_expected.to create_class('sssd::pki') }
          it { is_expected.to create_pki__copy('sssd').with({
            :source => '/etc/pki/simp/x509' }) }
          it { is_expected.to_not create_class('pki')}
          it { is_expected.to create_file('/etc/pki/simp_apps/sssd/x509')}
        end

        context 'with pki = simp' do
          let(:params) {{ :pki     => 'simp'}}

          it { is_expected.to create_class('sssd::pki') }
          it { is_expected.to create_pki__copy('sssd').with({
            :source => '/etc/pki/simp/x509' }) }
          it { is_expected.to create_class('pki') }
          it { is_expected.to create_file('/etc/pki/simp_apps/sssd/x509')}
        end
      end
    end
  end
end
