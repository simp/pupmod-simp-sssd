require 'spec_helper'

describe 'sssd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts }

        context 'with_defaults' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd') }
          it { is_expected.to create_class('sssd::install').that_comes_before('Class[sssd::config]') }
          it { is_expected.to create_class('sssd::config') }
          it { is_expected.to create_class('sssd::service') }
          it { is_expected.to_not create_class('auditd') }
          it { is_expected.to_not create_audit__rule('sssd') }
          it { is_expected.to_not create_class('sssd::pki') }
          it { is_expected.to_not create_pki__copy('sssd') }
        end

        context 'with an unsupported version of sssd' do
          let(:facts) {
            os_facts.merge({:sssd_version => '1.14.0'})
          }

          it { is_expected.to compile.and_raise_error(/does not support/) }
        end

        context 'with auditd = true' do
          let(:params) {{ :auditd => true }}

          it { is_expected.to create_class('auditd')}
          it { is_expected.to create_auditd__rule('sssd').with({
            :content => '-w /etc/sssd/ -p wa -k CFG_sssd' })
          }
        end

        context 'with pki = true' do
          let(:params) {{ :pki => true}}

          it { is_expected.to create_class('sssd::pki') }
          it { is_expected.to create_pki__copy('sssd').with({
              :source => '/etc/pki/simp/x509',
              :pki    => true
            })
          }
        end

        context 'with pki = simp' do
          let(:params) {{ :pki => 'simp'}}

          it { is_expected.to create_class('sssd::pki') }
          it { is_expected.to create_pki__copy('sssd').with({
              :source => '/etc/pki/simp/x509',
              :pki    => 'simp'
            })
          }
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

        context 'with a custom config' do
          let(:params) {{ :custom_config => 'foo' }}

          it {
            is_expected.to create_sssd__config__entry('puppet_custom')
              .with_content('foo')
              .with_order(99999)
          }
        end

        context 'with ldap provider' do
          let(:params) {{
            :ldap_providers => {
              :test_provider => {
                :ldap_access_filter => 'memberOf=cn=allowedusers,ou=Groups,dc=example,dc=com',
              }
            }
          }}

          it {
            is_expected.to create_sssd__provider__ldap('test_provider').with( {
              :ldap_access_filter => 'memberOf=cn=allowedusers,ou=Groups,dc=example,dc=com',
            } )
          }
        end
      end
    end
  end
end
