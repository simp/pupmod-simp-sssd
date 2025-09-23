require 'spec_helper'

describe 'sssd::provider::krb5' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:title) { 'krb5_test_domain' }

      context 'with default parameters' do
        let(:params) do
          {
            krb5_server: 'test.example.domain',
            krb5_realm: 'EXAMPLE.REALM',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_krb5")
            .with_content(<<~EOM)
              [domain/krb5_test_domain]
              # sssd::provider::krb5
              debug_timestamps = true
              debug_microseconds = false
              krb5_server = test.example.domain
              krb5_realm = EXAMPLE.REALM
              krb5_auth_timeout = 15
              krb5_validate = false
              krb5_store_password_if_offline = false
              krb5_renew_interval = 0
            EOM
        }
      end

      context 'with optional parameters' do
        let(:params) do
          {
            krb5_server: 'test.example.domain',
            krb5_realm: 'EXAMPLE.REALM',
            debug_level: '0x0080',
            krb5_kpasswd: 'the_krb5_kpasswd',
            krb5_ccachedir: '/alternate/krb5/ccache/dir',
            krb5_ccname_template: '/alternate/krb5/ccname/template',
            krb5_keytab: '/alternate/krb5/keytab',
            krb5_renewable_lifetime: '60m',
            krb5_lifetime: '90m',
            krb5_use_fast: 'try',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_krb5")
            .with_content(<<~EOM)
              [domain/krb5_test_domain]
              # sssd::provider::krb5
              debug_level = 0x0080
              debug_timestamps = true
              debug_microseconds = false
              krb5_server = test.example.domain
              krb5_realm = EXAMPLE.REALM
              krb5_kpasswd = the_krb5_kpasswd
              krb5_ccachedir = /alternate/krb5/ccache/dir
              krb5_ccname_template = /alternate/krb5/ccname/template
              krb5_auth_timeout = 15
              krb5_validate = false
              krb5_keytab = /alternate/krb5/keytab
              krb5_store_password_if_offline = false
              krb5_renewable_lifetime = 60m
              krb5_lifetime = 90m
              krb5_renew_interval = 0
              krb5_use_fast = try
            EOM
        }
      end
    end
  end
end
