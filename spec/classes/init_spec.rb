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

          it { is_expected.to contain_concat('/etc/sssd/sssd.conf').with({
            :notify => 'Class[Sssd::Service]'
            })
          }

          it { is_expected.to contain_concat__fragment('sssd_main_config').with({
              :target  => '/etc/sssd/sssd.conf',
              :content => /\[sssd\]/
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

        context 'when domains is set to the empty array' do
          let(:params) {{ domains: [] }}

          it { is_expected.to compile.and_raise_error(/parameter 'domains' expects size to be at least 1/) }
        end

        context 'when domains contains the empty string' do
          let(:params) {{ domains: [''] }}

          it { is_expected.to compile.and_raise_error(/parameter 'domains' index 0 expects a String\[1, 255\] value, got String/) }
        end

        context 'try_inotify = ' do
          context 'unset' do
            it {
              is_expected.to contain_concat__fragment('sssd_main_config')

              is_expected.to_not contain_concat__fragment('sssd_main_config').
                with_content(/try_inotify/)
            }
          end
          context 'true' do
            let(:params) {{ :try_inotify => true }}

            it {
              is_expected.to contain_concat__fragment('sssd_main_config').
                with_content(/try_inotify = true/)
            }
          end

          context 'false' do
            let(:params) {{ :try_inotify => false }}

            it {
              is_expected.to contain_concat__fragment('sssd_main_config').
                with_content(/try_inotify = false/)
            }
          end
        end

        context 'with_auditd = true' do
          let(:params) {{ :auditd => true }}

          it { is_expected.to create_class('auditd')}
          it { is_expected.to create_auditd__rule('sssd').with({
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

        context 'with debug_level as an integer' do
          let(:params) {{ :debug_level => 9 }}
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd') }
        end

        context 'with debug_level as a two-byte hexidecimal' do
          let(:params) {{ :debug_level => '0x1234' }}
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd') }
        end

        context 'with debug_level as an invalid hex Sssd::DebugLevel' do
          let(:params) {{ :debug_level => '0x123z' }}
          it { is_expected.to compile.and_raise_error(/parameter 'debug_level' expects a/)}
        end

        context 'with debug_level as an invalid integer Sssd::DebugLevel' do
          let(:params) {{ :debug_level => 99 }}
          it { is_expected.to compile.and_raise_error(/parameter 'debug_level' expects a/)}
        end
      end
    end
  end
end
