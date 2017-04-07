require 'spec_helper'

describe 'sssd::provider::ldap' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }

        let(:title) {'test_ldap_provider'}
        let(:precondition){
          'include ::sssd'
        }
        let(:params) {{
          :ldap_uri => ['ldap://test.example.domain'],
          :ldap_chpass_uri => ['ldap://test.example.domain'],
          :ldap_search_base => 'dc=example,dc=domain',
          :ldap_default_bind_dn => 'cn=hostAuth,ou=Hosts,dc=example,dc=domain',
          :ldap_default_authtok => 'sup3r$3cur3P@ssw0r?',
          :ldap_id_use_start_tls => true
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_concat__fragment("sssd_#{title}_ldap_provider.domain").without_content(%r(=\s*$)) }
        it { is_expected.to create_concat__fragment("sssd_#{title}_ldap_provider.domain").without_content(%r(^\s*_.+=)) }

        if ['RedHat','CentOS'].include?(facts[:os][:name])
          if facts[:os][:release][:major] < '7'
            it { is_expected.to create_concat__fragment("sssd_#{title}_ldap_provider.domain").with_content(%r(ldap_tls_cipher_suite.*-AES128)) }
          else
            it { is_expected.to create_concat__fragment("sssd_#{title}_ldap_provider.domain").without_content(%r(ldap_tls_cipher_suite.*-AES128)) }
          end
        end
      end
    end
  end
end
