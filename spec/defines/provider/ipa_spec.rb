require 'spec_helper'

describe 'sssd::provider::ipa' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts }
        let(:title) {'test_ldap_provider'}

        context('with default parameters') do
          let(:params) {{
            :ipa_domain => facts[:domain],
            :ipa_server => ["ipaserver.#{facts[:domain]}"]
          }}

          it { is_expected.to compile.with_all_deps }
          it {
            expected = <<~EXPECTED
              [domain/#{title}]
              # sssd::provider::ipa
              ipa_domain = #{facts[:domain]}
              ipa_server = _srv_,ipaserver.#{facts[:domain]}
              ipa_enable_dns_sites = false
              ipa_hostname = #{facts[:networking][:fqdn]}
              ipa_server_mode = false
              dyndns_auth = GSS-TSIG
              dyndns_update = true
              krb5_store_password_if_offline = true
              ldap_tls_cacert = /etc/ipa/ca.crt
              ldap_tls_cipher_suite = HIGH:-SSLv2
              EXPECTED

            is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ipa").with_content(expected)
           }
        end

        context('with explicit parameters and use_service_discovery=false') do
          # The parameters being set are NOT realistic....just want to verify
          # content gets generated appropriately.
          let(:params) {{
            :ipa_domain                     => facts[:domain],
            :ipa_server                     => ["ipaserver1.#{facts[:domain]}"],
            :ipa_backup_server              => ["ipaserver2.#{facts[:domain]}"],
            :ipa_hostname                   => "ipaclient1.#{facts[:domain]}",
            :ipa_enable_dns_sites           => true,
            :ipa_server_mode                => true,
            :dyndns_auth                    => 'none',
            :dyndns_force_tcp               => false,
            :dyndns_iface                   => ['*'],
            :dyndns_refresh_interval        => 20,
            :dyndns_server                  => "dns1.#{facts[:domain]}",
            :dyndns_ttl                     => 10,
            :dyndns_update                  => false,
            :dyndns_update_ptr              => false,
            :ipa_automount_location         => 'export',
            :ipa_hbac_refresh               => 30,
            :ipa_hbac_search_base           => 'cn=hbacSearch,dc=example,dc=com',
            :ipa_hbac_selinux               => 40,
            :ipa_host_search_base           => 'cn=hostSearch,dc=example,dc=com',
            :ipa_master_domains_search_base => 'cn=masterDomainsSearch,dc=example,dc=com',
            :ipa_selinux_search_base        => 'cn=selinuxSearch,dc=example,dc=com',
            :ipa_subdomains_search_base     => 'cn=subdomainsSearch,dc=example,dc=com',
            :ipa_views_search_base          => 'cn=ipaViewsSearch,dc=example,dc=com',
            :krb5_confd_path                => '/etc/sssd/krb5',
            :krb5_realm                     => 'EXAMPLE.COM',
            :krb5_store_password_if_offline => false,
            :ldap_tls_cacert                => '/etc/ipa/cacert.crt',
            :ldap_tls_cipher_suite          => ['HIGH'],
            :use_service_discovery          => false
          }}

          it { is_expected.to compile.with_all_deps }
          it {
            expected = <<~EXPECTED
              [domain/#{title}]
              # sssd::provider::ipa
              ipa_domain = #{facts[:domain]}
              ipa_server = ipaserver1.#{facts[:domain]}
              ipa_backup_server = ipaserver2.#{facts[:domain]}
              ipa_enable_dns_sites = true
              ipa_hostname = ipaclient1.#{facts[:domain]}
              ipa_server_mode = true
              dyndns_auth = none
              dyndns_force_tcp = false
              dyndns_iface = *
              dyndns_refresh_interval = 20
              dyndns_server = dns1.#{facts[:domain]}
              dyndns_ttl = 10
              dyndns_update = false
              dyndns_update_ptr = false
              ipa_automount_location = export
              ipa_hbac_refresh = 30
              ipa_hbac_search_base = cn=hbacSearch,dc=example,dc=com
              ipa_hbac_selinux = 40
              ipa_host_search_base = cn=hostSearch,dc=example,dc=com
              ipa_master_domains_search_base = cn=masterDomainsSearch,dc=example,dc=com
              ipa_selinux_search_base = cn=selinuxSearch,dc=example,dc=com
              ipa_subdomains_search_base = cn=subdomainsSearch,dc=example,dc=com
              ipa_views_search_base = cn=ipaViewsSearch,dc=example,dc=com
              krb5_confd_path = /etc/sssd/krb5
              krb5_realm = EXAMPLE.COM
              krb5_store_password_if_offline = false
              ldap_tls_cacert = /etc/ipa/cacert.crt
              ldap_tls_cipher_suite = HIGH
              EXPECTED

            is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ipa").with_content(expected)
           }
        end
      end
    end
  end
end
