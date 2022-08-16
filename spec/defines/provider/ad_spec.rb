require 'spec_helper'

describe 'sssd::provider::ad' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts){ os_facts }

      let(:title) {'test_ad_provider'}

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it do
          expected = <<~EXPECTED
            [domain/#{title}]
            # sssd::provider::ad
            dyndns_update = true
            krb5_store_password_if_offline = false
            ldap_id_mapping = true
            ldap_use_tokengroups = true
            EXPECTED

          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ad").with_content(expected)
        end
      end

      context 'with dyndns_update false' do
        # set all optional dyndns_update parameters, even though
        # they are inapplicable
        let(:params) {{
          :dyndns_update           => false,
          :dyndns_ttl              => 3,
          :dyndns_ifaces           => ['iface1', 'iface2'],
          :dyndns_refresh_interval => 4,
          :dyndns_update_ptr       => false,
          :dyndns_force_tcp        => false,
          :dyndns_server           => 'my.dyndns.server'
        }}

        it { is_expected.to compile.with_all_deps }
        it do
          expected = <<~EXPECTED
            [domain/#{title}]
            # sssd::provider::ad
            dyndns_update = false
            krb5_store_password_if_offline = false
            ldap_id_mapping = true
            ldap_use_tokengroups = true
            EXPECTED

          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ad").with_content(expected)
        end
      end

      # This set of parameters exercises the logic in the code but is NOT at all
      # realistic!
      context 'with all optional parameters set' do
        let(:params) {{
          :ad_domain                                => 'my_ad_domain',
          :ad_enabled_domains                       => ['enabled_domain1', 'enabled_domain2'],
          :ad_servers                               => ['server1.example.domain', 'server2.example.domain'],
          :ad_backup_servers                        => ['backup1.example.domain', 'backup2.example.domain'],
          :ad_hostname                              => 'my.ad.hostname',
          :ad_enable_dns_sites                      => false,
          :ad_access_filters                        => ['filter1', 'filter2'],
          :ad_site                                  => 'my_ad_site',
          :ad_enable_gc                             => false,
          :ad_gpo_access_control                    => 'enforcing',
          :ad_gpo_cache_timeout                     => 1,
          :ad_gpo_map_interactive                   => ['interactive1','interactive2'],
          :ad_gpo_map_remote_interactive            => ['remote_interactive1','remote_interactive2'],
          :ad_gpo_map_network                       => ['network1','network2'],
          :ad_gpo_map_batch                         => ['batch1','batch2'],
          :ad_gpo_map_service                       => ['service1','service2'],
          :ad_gpo_map_permit                        => ['permit1','permit2'],
          :ad_gpo_map_deny                          => ['deny1','deny2'],
          :ad_gpo_default_right                     => 'interactive',
          :ad_maximum_machine_account_password_age  => 2,
          :ad_machine_account_password_renewal_opts => '1234:567',
          :default_shell                            => 'my_default_shell',
          :dyndns_update                            => true,
          :dyndns_ttl                               => 3,
          :dyndns_ifaces                            => ['iface1', 'iface2'],
          :dyndns_refresh_interval                  => 4,
          :dyndns_update_ptr                        => false,
          :dyndns_force_tcp                         => false,
          :dyndns_server                            => 'my.dyndns.server',
          :override_homedir                         => 'my_override_homedir',
          :fallback_homedir                         => 'my_fallback_homedir',
          :homedir_substring                        => '/my/homedir/substring',
          :krb5_realm                               => 'my_krb5_realm',
          :krb5_confd_path                          => 'none',
          :krb5_use_enterprise_principal            => false,
          :krb5_store_password_if_offline           => true,
          :ldap_schema                              => 'my_ldap_schema',
          :ldap_idmap_range_min                     => 5,
          :ldap_idmap_range_max                     => 6,
          :ldap_idmap_range_size                    => 7,
          :ldap_idmap_default_domain_sid            => 'my_ldap_idmap_default_domain_sid',
          :ldap_idmap_default_domain                => 'my_ldap_idmap_default_domain',
          :ldap_idmap_autorid_compat                => false,
          :ldap_idmap_helper_table_size             => 8,
          :ldap_group_objectsid                     => 'my_ldap_group_objectsid',
          :ldap_user_objectsid                      => 'my_ldap_user_objectsid',
          :ldap_user_extra_attrs                    => 'altSecurityIdentities',
          :ldap_user_ssh_public_key                 => 'altSecurityIdentities'
        }}

        it do
          expected = <<~EXPECTED
            [domain/#{title}]
            # sssd::provider::ad
            ad_domain = my_ad_domain
            ad_enabled_domains = enabled_domain1, enabled_domain2
            ad_server = server1.example.domain, server2.example.domain
            ad_backup_server = backup1.example.domain, backup2.example.domain
            ad_hostname = my.ad.hostname
            ad_enable_dns_sites = false
            ad_access_filter = filter1?filter2
            ad_site = my_ad_site
            ad_enable_gc = false
            ad_gpo_access_control = enforcing
            ad_gpo_cache_timeout = 1
            ad_gpo_map_interactive = interactive1, interactive2
            ad_gpo_map_remote_interactive = remote_interactive1, remote_interactive2
            ad_gpo_map_network = network1, network2
            ad_gpo_map_batch = batch1, batch2
            ad_gpo_map_service = service1, service2
            ad_gpo_map_permit = permit1, permit2
            ad_gpo_map_deny = deny1, deny2
            ad_gpo_default_right = interactive
            ad_maximum_machine_account_password_age = 2
            ad_machine_account_password_renewal_opts = 1234:567
            default_shell = my_default_shell
            dyndns_update = true
            dyndns_ttl = 3
            dyndns_iface = iface1, iface2
            dyndns_refresh_interval = 4
            dyndns_update_ptr = false
            dyndns_force_tcp = false
            dyndns_server = my.dyndns.server
            override_homedir = my_override_homedir
            homedir_substring = /my/homedir/substring
            fallback_homedir = my_fallback_homedir
            krb5_realm = my_krb5_realm
            krb5_confd_path = none
            krb5_use_enterprise_principal = false
            krb5_store_password_if_offline = true
            ldap_id_mapping = true
            ldap_schema = my_ldap_schema
            ldap_idmap_range_min = 5
            ldap_idmap_range_max = 6
            ldap_idmap_range_size = 7
            ldap_idmap_default_domain_sid = my_ldap_idmap_default_domain_sid
            ldap_idmap_default_domain = my_ldap_idmap_default_domain
            ldap_idmap_autorid_compat = false
            ldap_idmap_helper_table_size = 8
            ldap_use_tokengroups = true
            ldap_group_objectsid = my_ldap_group_objectsid
            ldap_user_objectsid = my_ldap_user_objectsid
            ldap_user_extra_attrs = altSecurityIdentities
            ldap_user_ssh_public_key = altSecurityIdentities
            EXPECTED

          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ad").with_content(expected)
        end
      end
    end
  end
end
