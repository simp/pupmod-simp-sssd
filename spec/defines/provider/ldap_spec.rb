require 'spec_helper'

describe 'sssd::provider::ldap' do

  let(:title) {'test_ldap_provider'}
  let(:facts) {{
    :operatingsystem   => 'RedHat',
    :lsbmajdistrelease => '6',
    :fqdn => 'test.example.domain',
    # for auditd/templates/base.erb:
    :hardwaremodel     => 'x86_64',
    :root_audit_level  => 'none',
    :grub_version      => '0',
    # for auditd/manifests/init.pp:
    :uid_min           => 500,
  }}
  let(:params) {{
    :ldap_uri => 'ldap://test.example.domain',
    :ldap_chpass_uri => 'ldap://test.example.domain',
    :ldap_search_base => 'dc=example,dc=domain',
    :ldap_default_bind_dn => 'cn=hostAuth,ou=Hosts,dc=example,dc=domain',
    :ldap_default_authtok => 'sup3r$3cur3P@ssw0r?'
  }}

  it { should compile.with_all_deps }
  it { should create_concat_fragment('sssd+test_ldap_provider#ldap_provider.domain') }
  it { should contain_class('openldap::pam') }
end
