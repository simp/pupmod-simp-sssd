require 'spec_helper'

describe 'sssd::provider::ldap' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }

        let(:title) {'test_ldap_provider'}
        let(:params) {{
          :ldap_uri => ['ldap://test.example.domain'],
          :ldap_chpass_uri => ['ldap://test.example.domain'],
          :ldap_search_base => 'dc=example,dc=domain',
          :ldap_default_bind_dn => 'cn=hostAuth,ou=Hosts,dc=example,dc=domain',
          :ldap_default_authtok => 'sup3r$3cur3P@ssw0r?'
        }}
        let(:precondition){
          'include ::sssd'
        }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_concat_fragment('sssd+test_ldap_provider#ldap_provider.domain').without_content(%r(=\s*$)) }
      end
    end
  end
end
