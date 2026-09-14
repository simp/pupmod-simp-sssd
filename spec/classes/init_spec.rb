require 'spec_helper'

describe 'sssd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
        # On EL10+ sssd runs as the unprivileged 'sssd' user, which must be
        # able to read the copied certs (simp/pupmod-simp-sssd#212)
        let(:expected_app_pki_group) { (facts[:os][:release][:major].to_i >= 10) ? 'sssd' : 'root' }

        context 'with_defaults' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd') }
          it { is_expected.to create_class('sssd::install').that_comes_before('Class[sssd::config]') }
          it { is_expected.to create_class('sssd::config') }
          it { is_expected.to create_class('sssd::service') }
          it { is_expected.not_to create_class('auditd') }
          it { is_expected.not_to create_audit__rule('sssd') }
          it { is_expected.not_to create_class('sssd::pki') }
          it { is_expected.not_to create_pki__copy('sssd') }
        end

        context 'with an unsupported version of sssd' do
          let(:facts) do
            os_facts.merge(sssd_version: '1.14.0')
          end

          it { is_expected.to compile.and_raise_error(%r{does not support}) }
        end

        context 'with auditd = true' do
          let(:params) { { auditd: true } }

          it { is_expected.to create_class('auditd') }
          it {
            is_expected.to create_auditd__rule('sssd').with(
              content: '-w /etc/sssd/ -p wa -k CFG_sssd',
            )
          }
        end

        context 'with pki = true' do
          let(:params) { { pki: true } }

          it { is_expected.to create_class('sssd::pki') }
          it {
            is_expected.to create_pki__copy('sssd').with(
              source: '/etc/pki/simp/x509',
              pki: true,
              group: expected_app_pki_group,
            )
          }
        end

        context 'with pki = simp' do
          let(:params) { { pki: 'simp' } }

          it { is_expected.to create_class('sssd::pki') }
          it {
            is_expected.to create_pki__copy('sssd').with(
              source: '/etc/pki/simp/x509',
              pki: 'simp',
              group: expected_app_pki_group,
            )
          }
        end

        context 'with pki = true and a custom app_pki_group' do
          let(:params) { { pki: true, app_pki_group: 'sssd-certs' } }

          it { is_expected.to create_pki__copy('sssd').with_group('sssd-certs') }
        end

        context 'with debug_level as an integer' do
          let(:params) { { debug_level: 9 } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd') }
        end

        context 'with debug_level as a two-byte hexidecimal' do
          let(:params) { { debug_level: '0x1234' } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd') }
        end

        context 'with debug_level as an invalid hex Sssd::DebugLevel' do
          let(:params) { { debug_level: '0x123z' } }

          it { is_expected.to compile.and_raise_error(%r{parameter 'debug_level' expects a}) }
        end

        context 'with debug_level as an invalid integer Sssd::DebugLevel' do
          let(:params) { { debug_level: 99 } }

          it { is_expected.to compile.and_raise_error(%r{parameter 'debug_level' expects a}) }
        end

        context 'with a custom config' do
          let(:params) { { custom_config: 'foo' } }

          it {
            is_expected.to create_sssd__config__entry('puppet_custom')
              .with_content('foo')
              .with_order(99_999)
          }
        end

        context 'with custom settings' do
          let(:params) do
            {
              custom_settings: {
                'certmap/EXAMPLE.COM/rule1' => {
                  'matchrule' => '<ISSUER>CN=Example CA',
                  'priority'  => 10,
                },
              },
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to create_sssd__config__entry('puppet_custom')
              .with_content(
                "[certmap/EXAMPLE.COM/rule1]\nmatchrule = <ISSUER>CN=Example CA\npriority = 10",
              )
              .with_order(99_999)
          }
        end

        context 'with both custom settings and a custom config' do
          let(:params) do
            {
              custom_settings: { 'nss' => { 'memcache_timeout' => 300 } },
              custom_config:   "[pam]\npam_verbosity = 2",
            }
          end

          it 'renders the structured sections first and appends the raw String' do
            is_expected.to create_sssd__config__entry('puppet_custom')
              .with_content("[nss]\nmemcache_timeout = 300\n[pam]\npam_verbosity = 2")
          end
        end

        context 'with an empty custom settings Hash' do
          let(:params) { { custom_settings: {} } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.not_to create_sssd__config__entry('puppet_custom') }
        end

        context 'with custom settings that render to nothing' do
          let(:params) do
            {
              custom_settings: {
                'domain/EXAMPLE.COM' => {},
                'nss'                => { 'filter_users' => :undef },
              },
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.not_to create_sssd__config__entry('puppet_custom') }
        end

        context 'with custom settings that render to nothing alongside a custom config' do
          let(:params) do
            {
              custom_settings: { 'nss' => { 'filter_users' => :undef } },
              custom_config:   "[pam]\npam_verbosity = 2",
            }
          end

          it 'does not prepend a blank line to the raw String' do
            is_expected.to create_sssd__config__entry('puppet_custom')
              .with_content("[pam]\npam_verbosity = 2")
          end
        end

        context 'with invalid custom settings' do
          let(:params) { { custom_settings: { 'nss' => { 'filter_users' => "root\n[pam]" } } } }

          it { is_expected.to compile.and_raise_error(%r{parameter 'custom_settings' entry 'nss' entry 'filter_users' expects a Sssd::IniValue}) }
        end

        context 'with ldap provider' do
          let(:params) do
            {
              ldap_providers: {
                test_provider: {
                  ldap_access_filter: 'memberOf=cn=allowedusers,ou=Groups,dc=example,dc=com',
                },
              },
            }
          end

          it {
            is_expected.to create_sssd__provider__ldap('test_provider').with(
              ldap_access_filter: 'memberOf=cn=allowedusers,ou=Groups,dc=example,dc=com',
            )
          }
        end
      end
    end
  end
end
