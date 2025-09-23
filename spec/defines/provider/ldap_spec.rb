require 'spec_helper'

# Some of these tests depend upon simp_options::ldap::* being set in
# spec/fixtures/hieradata/default.yaml.
#
describe 'sssd::provider::ldap' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'ldap' }

      context 'with sssd_version 1.16.0' do
        let(:facts) do
          os_facts.merge({ sssd_version: '1.16.0' })
        end

        it do
          ldap_tls_cipher_suite = 'ldap_tls_cipher_suite = HIGH:-SSLv2'

          expected = <<~EXPECTED
            [domain/#{title}]
            # sssd::provider::ldap
            debug_microseconds = false
            krb5_canonicalize = false
            krb5_use_kdcinfo = true
            ldap_access_order = expire,lockout,ppolicy,pwd_expire_policy_renew
            ldap_account_expire_policy = shadow
            ldap_chpass_update_last_change = true
            ldap_default_authtok = sup3r$3cur3P@ssw0r?
            ldap_default_bind_dn = cn=hostAuth,ou=Hosts,dc=example,dc=domain
            ldap_disable_paging = false
            ldap_disable_range_retrieval = false
            ldap_force_upper_case_realm = false
            ldap_groups_use_matching_rule_in_chain = false
            ldap_id_mapping = false
            ldap_id_use_start_tls = true
            ldap_idmap_autorid_compat = false
            ldap_initgroups_use_matching_rule_in_chain = false
            ldap_krb5_init_creds = true
            ldap_pwd_policy = shadow
            ldap_referrals = true
            ldap_sasl_canonicalize = false
            ldap_schema = rfc2307
            ldap_search_base = dc=example,dc=domain
            ldap_sudo_include_netgroups  = true
            ldap_sudo_include_regexp = true
            ldap_sudo_use_host_filter = true
            ldap_tls_cacertdir = /etc/pki/simp_apps/sssd/x509/cacerts
            ldap_tls_cert = /etc/pki/simp_apps/sssd/x509/public/foo.example.com.pub
            #{ldap_tls_cipher_suite}
            ldap_tls_key = /etc/pki/simp_apps/sssd/x509/private/foo.example.com.pem
            ldap_tls_reqcert = demand
            ldap_uri = ldap://test.example.domain
            ldap_use_tokengroups = false
            EXPECTED

          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ldap").with_content(expected)
        end
      end

      context 'with sssd_version > 2.0.0 ' do
        let(:facts) do
          os_facts.merge({ sssd_version: '2.2.0' })
        end

        it do
          ldap_tls_cipher_suite = 'ldap_tls_cipher_suite = HIGH:-SSLv2'

          expected = <<~EXPECTED
            [domain/#{title}]
            # sssd::provider::ldap
            debug_microseconds = false
            krb5_canonicalize = false
            krb5_use_kdcinfo = true
            ldap_access_order = expire,lockout,ppolicy,pwd_expire_policy_renew
            ldap_account_expire_policy = shadow
            ldap_chpass_update_last_change = true
            ldap_default_authtok = sup3r$3cur3P@ssw0r?
            ldap_default_bind_dn = cn=hostAuth,ou=Hosts,dc=example,dc=domain
            ldap_disable_paging = false
            ldap_disable_range_retrieval = false
            ldap_force_upper_case_realm = false
            ldap_id_mapping = false
            ldap_id_use_start_tls = true
            ldap_idmap_autorid_compat = false
            ldap_krb5_init_creds = true
            ldap_pwd_policy = shadow
            ldap_referrals = true
            ldap_sasl_canonicalize = false
            ldap_schema = rfc2307
            ldap_search_base = dc=example,dc=domain
            ldap_sudo_include_netgroups  = true
            ldap_sudo_include_regexp = true
            ldap_sudo_use_host_filter = true
            ldap_tls_cacertdir = /etc/pki/simp_apps/sssd/x509/cacerts
            ldap_tls_cert = /etc/pki/simp_apps/sssd/x509/public/foo.example.com.pub
            #{ldap_tls_cipher_suite}
            ldap_tls_key = /etc/pki/simp_apps/sssd/x509/private/foo.example.com.pem
            ldap_tls_reqcert = demand
            ldap_uri = ldap://test.example.domain
            ldap_use_tokengroups = false
            EXPECTED

          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ldap").with_content(expected)
        end
      end

      context 'with ldap_user_cert set' do
        let(:params) { { ldap_user_cert: 'userCertificate;binary' } }

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ldap")
            .with_content(%r{ldap_user_cert = userCertificate;binary})
        }
      end

      context 'with app_pki_ca_dir set' do
        let(:params) { { app_pki_ca_dir: '/path/to/ca' } }

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ldap")
            .with_content(%r{ldap_tls_cacertdir = /path/to/ca})
        }
      end

      context 'with app_pki_key set' do
        let(:params) { { app_pki_key: '/path/to/private/fqdn.pem' } }

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ldap")
            .with_content(%r{ldap_tls_key = /path/to/private/fqdn.pem})
        }
      end

      context 'with app_pki_cert set' do
        let(:params) { { app_pki_cert: '/path/to/public/fqdn.pub' } }

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ldap")
            .with_content(%r{ldap_tls_cert = /path/to/public/fqdn.pub})
        }
      end

      context 'with empty ldap_account_expire_policy' do
        let(:params) { { ldap_account_expire_policy: '' } }

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ldap")
            .without_content(%r{ldap_account_expire_policy})
        }
      end

      context 'with multiple ldap_uri values' do
        let(:params) do
          {
            ldap_uri: ['ldap://test1.example.domain', 'ldap://test2.example.domain'],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ldap")
            .with_content(%r{ldap_uri = ldap://test1.example.domain,ldap://test2.example.domain})
        }
      end

      context 'with client_tls set to false' do
        let(:params) { { client_tls: false } }

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ldap")
            .without_content(%r{ldap_tls_cacertdir})
            .without_content(%r{ldap_tls_key})
            .without_content(%r{ldap_tls_cert})
        }
      end

      # This set of parameters exercises the logic in the code but is NOT at all
      # realistic!
      context 'with other optional parameters set' do
        let(:facts) do
          os_facts.merge({ sssd_version: '1.16.0' })
        end

        let(:params) do
          {
            debug_level: 3,
         debug_timestamps: false,
         krb5_backup_server: [ '1.2.3.4:5678', 'backup.example.domain'],
         krb5_realm: 'my_krb5_realm',
         krb5_server: [ '1.2.3.5:5678', 'primary.example.domain'],
         ldap_access_filter: 'my_ldap_access_filter',
         ldap_autofs_entry_key: 'my_ldap_autofs_entry_key',
         ldap_autofs_entry_object_class: 'my_ldap_autofs_entry_object_class',
         ldap_autofs_entry_value: 'my_ldap_autofs_entry_value',
         ldap_autofs_map_master_name: 'my_ldap_autofs_map_master_name',
         ldap_autofs_map_name: 'my_ldap_autofs_map_name',
         ldap_autofs_map_object_class: 'my_ldap_autofs_map_object_class',
         ldap_autofs_search_base: 'my_ldap_autofs_search_base',
         ldap_backup_uri: ['ldap://backup1.example.domain', 'ldap://backup2.example.domain'],
         ldap_chpass_backup_uri: ['ldap://backup3.example.domain', 'ldap://backup4.example.domain'],
         ldap_chpass_dns_service_name: 'my_ldap_chpass_dns_service_name',
         ldap_chpass_uri: ['ldap://chpass1.example.domain', 'ldap://chpass2.example.domain'],
         ldap_connection_expire_timeout: 4,
         ldap_default_authtok_type: 'password',
          ldap_deref_threshold: 5,
          ldap_deref: 'finding',
          ldap_dns_service_name: 'my_ldap_dns_service_name',
          ldap_enumeration_refresh_timeout: 6,
          ldap_enumeration_search_timeout: 7,
          ldap_group_gid_number: 'my_ldap_group_gid_number',
          ldap_group_member: 'my_ldap_group_member',
          ldap_group_modify_timestamp: 'my_ldap_group_modify_timestamp',
          ldap_group_name: 'my_ldap_group_name',
          ldap_group_nesting_level: 8,
          ldap_group_object_class: 'my_ldap_group_object_class',
          ldap_group_objectsid: 'my_ldap_group_objectsid',
          ldap_group_search_base: 'my_ldap_group_search_base',
          ldap_group_type: 9,
          ldap_group_uuid: 'my_ldap_group_uuid',
          ldap_idmap_default_domain: 'my_ldap_idmap_default_domain',
          ldap_idmap_default_domain_sid: 'my_ldap_idmap_default_domain_sid',
          ldap_idmap_range_max: 10,
          ldap_idmap_range_min: 11,
          ldap_idmap_range_size: 12,
          ldap_krb5_keytab: '/my_ldap_krb5_keytab',
          ldap_krb5_ticket_lifetime: 13,
          ldap_max_id: 14,
          ldap_min_id: 15,
          ldap_netgroup_member: 'my_ldap_netgroup_member',
          ldap_netgroup_modify_timestamp: 'my_ldap_netgroup_modify_timestamp',
          ldap_netgroup_name: 'my_ldap_netgroup_name',
          ldap_netgroup_object_class: 'my_ldap_netgroup_object_class',
          ldap_netgroup_search_base: 'my_ldap_netgroup_search_base',
          ldap_netgroup_triple: 'my_ldap_netgroup_triple',
          ldap_netgroup_uuid: 'my_ldap_netgroup_uuid',
          ldap_network_timeout: 16,
          ldap_ns_account_lock: 'my_ldap_ns_account_lock',
          ldap_opt_timeout: 17,
          ldap_page_size: 18,
          ldap_purge_cache_timeout: 19,
          ldap_pwdlockout_dn: 'my_ldap_pwdlockout_dn',
          ldap_sasl_authid: 'my_ldap_sasl_authid',
          ldap_sasl_mech: 'my_ldap_sasl_mech',
          ldap_sasl_minssf: 20,
          ldap_sasl_realm: 'my_ldap_sasl_realm',
          ldap_search_timeout: 21,
          ldap_service_name: 'my_ldap_service_name',
          ldap_service_port: 'my_ldap_service_port',
          ldap_service_proto: 'my_ldap_service_proto',
          ldap_service_search_base: 'my_sldap_ervice_search_base',
          ldap_sudo_full_refresh_interval: 22,
          ldap_sudo_hostnames: ['sudo1.example.com', 'sudo2.example.com'],
          ldap_sudo_ip: [ '2.3.4.1', '2.3.4.2'],
          ldap_sudo_search_base: 'my_ldap_sudo_search_base',
          ldap_sudo_smart_refresh_interval: 23,
          ldap_sudorule_command: 'my_ldap_sudorule_command',
          ldap_sudorule_host: 'my_ldap_sudorule_host',
          ldap_sudorule_name: 'my_ldap_sudorule_name',
          ldap_sudorule_notafter: 'my_ldap_sudorule_notafter',
          ldap_sudorule_notbefore: 'my_ldap_sudorule_notbefore',
          ldap_sudorule_object_class: 'my_ldap_sudorule_object_class',
          ldap_sudorule_option: 'my_ldap_sudorule_option',
          ldap_sudorule_order: 'my_ldap_sudorule_order',
          ldap_sudorule_runasgroup: 'my_ldap_sudorule_runasgroup',
          ldap_sudorule_runasuser: 'my_ldap_sudorule_runasuser',
          ldap_sudorule_user: 'my_ldap_sudorule_user',
          ldap_tls_cacert: '/path/to/cacert.pem',
          ldap_user_ad_account_expires: 'my_ldap_user_ad_account_expires',
          ldap_user_ad_user_account_control: 'my_ldap_user_ad_user_account_control',
          ldap_user_authorized_host: 'my_ldap_user_authorized_host',
          ldap_user_authorized_service: 'my_ldap_user_authorized_service',
          ldap_user_extra_attrs: [ 'attr1', 'attr2' ],
          ldap_user_fullname: 'my_ldap_user_fullname',
          ldap_user_gecos: 'my_ldap_user_gecos',
          ldap_user_gid_number: 'my_ldap_user_gid_number',
          ldap_user_home_directory: 'my_ldap_user_home_directory',
          ldap_user_krb_last_pwd_change: 'my_ldap_user_krb_last_pwd_change',
          ldap_user_krb_password_expiration: 'my_ldap_user_krb_password_expiration',
          ldap_user_member_of: 'my_ldap_user_member_of',
          ldap_user_modify_timestamp: 'my_ldap_user_modify_timestamp',
          ldap_user_name: 'my_ldap_user_name',
          ldap_user_nds_login_allowed_time_map: 'my_ldap_user_nds_login_allowed_time_map',
          ldap_user_nds_login_disabled: 'my_ldap_user_nds_login_disabled',
          ldap_user_nds_login_expiration_time: 'my_ldap_user_nds_login_expiration_time',
          ldap_user_object_class: 'my_ldap_user_object_class',
          ldap_user_objectsid: 'my_ldap_user_objectsid',
          ldap_user_principal: 'my_ldap_user_principal',
          ldap_user_search_base: 'my_ldap_user_search_base',
          ldap_user_shadow_expire: 'my_ldap_user_shadow_expire',
          ldap_user_shadow_inactive: 'my_ldap_user_shadow_inactive',
          ldap_user_shadow_last_change: 'my_ldap_user_shadow_last_change',
          ldap_user_shadow_max: 'my_ldap_user_shadow_max',
          ldap_user_shadow_min: 'my_ldap_user_shadow_min',
          ldap_user_shadow_warning: 'my_ldap_user_shadow_warning',
          ldap_user_shell: 'my_ldap_user_shell',
          ldap_user_ssh_public_key: 'my_ldap_user_ssh_public_key',
          ldap_user_uid_number: 'my_ldap_user_uid_number',
          ldap_user_uuid: 'my_ldap_user_uuid',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it do
          expected = <<~EXPECTED
            [domain/#{title}]
            # sssd::provider::ldap
            debug_level = 3
            debug_microseconds = false
            debug_timestamps = false
            krb5_backup_server = 1.2.3.4:5678,backup.example.domain
            krb5_canonicalize = false
            krb5_realm = my_krb5_realm
            krb5_server = 1.2.3.5:5678,primary.example.domain
            krb5_use_kdcinfo = true
            ldap_access_filter = my_ldap_access_filter
            ldap_access_order = expire,lockout,ppolicy,pwd_expire_policy_renew
            ldap_account_expire_policy = shadow
            ldap_autofs_entry_key = my_ldap_autofs_entry_key
            ldap_autofs_entry_object_class = my_ldap_autofs_entry_object_class
            ldap_autofs_entry_value = my_ldap_autofs_entry_value
            ldap_autofs_map_master_name = my_ldap_autofs_map_master_name
            ldap_autofs_map_name = my_ldap_autofs_map_name
            ldap_autofs_map_object_class = my_ldap_autofs_map_object_class
            ldap_autofs_search_base = my_ldap_autofs_search_base
            ldap_backup_uri = ldap://backup1.example.domain,ldap://backup2.example.domain
            ldap_chpass_backup_uri = ldap://backup3.example.domain,ldap://backup4.example.domain
            ldap_chpass_dns_service_name = my_ldap_chpass_dns_service_name
            ldap_chpass_update_last_change = true
            ldap_chpass_uri = ldap://chpass1.example.domain,ldap://chpass2.example.domain
            ldap_connection_expire_timeout = 4
            ldap_default_authtok = sup3r$3cur3P@ssw0r?
            ldap_default_authtok_type = password
            ldap_default_bind_dn = cn=hostAuth,ou=Hosts,dc=example,dc=domain
            ldap_deref = finding
            ldap_deref_threshold = 5
            ldap_disable_paging = false
            ldap_disable_range_retrieval = false
            ldap_dns_service_name = my_ldap_dns_service_name
            ldap_enumeration_refresh_timeout = 6
            ldap_enumeration_search_timeout = 7
            ldap_force_upper_case_realm = false
            ldap_group_gid_number = my_ldap_group_gid_number
            ldap_group_member = my_ldap_group_member
            ldap_group_modify_timestamp = my_ldap_group_modify_timestamp
            ldap_group_name = my_ldap_group_name
            ldap_group_nesting_level = 8
            ldap_group_object_class = my_ldap_group_object_class
            ldap_group_objectsid = my_ldap_group_objectsid
            ldap_group_search_base = my_ldap_group_search_base
            ldap_group_type = 9
            ldap_group_uuid = my_ldap_group_uuid
            ldap_groups_use_matching_rule_in_chain = false
            ldap_id_mapping = false
            ldap_id_use_start_tls = true
            ldap_idmap_autorid_compat = false
            ldap_idmap_default_domain = my_ldap_idmap_default_domain
            ldap_idmap_default_domain_sid = my_ldap_idmap_default_domain_sid
            ldap_idmap_range_max = 10
            ldap_idmap_range_min = 11
            ldap_idmap_range_size = 12
            ldap_initgroups_use_matching_rule_in_chain = false
            ldap_krb5_init_creds = true
            ldap_krb5_keytab = /my_ldap_krb5_keytab
            ldap_krb5_ticket_lifetime = 13
            ldap_max_id = 14
            ldap_min_id = 15
            ldap_netgroup_member = my_ldap_netgroup_member
            ldap_netgroup_modify_timestamp = my_ldap_netgroup_modify_timestamp
            ldap_netgroup_name = my_ldap_netgroup_name
            ldap_netgroup_object_class = my_ldap_netgroup_object_class
            ldap_netgroup_search_base = my_ldap_netgroup_search_base
            ldap_netgroup_triple = my_ldap_netgroup_triple
            ldap_netgroup_uuid = my_ldap_netgroup_uuid
            ldap_network_timeout = 16
            ldap_ns_account_lock = my_ldap_ns_account_lock
            ldap_opt_timeout = 17
            ldap_page_size = 18
            ldap_purge_cache_timeout = 19
            ldap_pwd_policy = shadow
            ldap_pwdlockout_dn = my_ldap_pwdlockout_dn
            ldap_referrals = true
            ldap_sasl_authid = my_ldap_sasl_authid
            ldap_sasl_canonicalize = false
            ldap_sasl_mech = my_ldap_sasl_mech
            ldap_sasl_minssf = 20
            ldap_sasl_realm = my_ldap_sasl_realm
            ldap_schema = rfc2307
            ldap_search_base = dc=example,dc=domain
            ldap_search_timeout = 21
            ldap_service_name = my_ldap_service_name
            ldap_service_port = my_ldap_service_port
            ldap_service_proto = my_ldap_service_proto
            ldap_service_search_base = my_sldap_ervice_search_base
            ldap_sudo_full_refresh_interval = 22
            ldap_sudo_hostnames = sudo1.example.com sudo2.example.com
            ldap_sudo_include_netgroups  = true
            ldap_sudo_include_regexp = true
            ldap_sudo_ip = 2.3.4.1 2.3.4.2
            ldap_sudo_search_base = my_ldap_sudo_search_base
            ldap_sudo_smart_refresh_interval = 23
            ldap_sudo_use_host_filter = true
            ldap_sudorule_command = my_ldap_sudorule_command
            ldap_sudorule_host = my_ldap_sudorule_host
            ldap_sudorule_name = my_ldap_sudorule_name
            ldap_sudorule_notafter = my_ldap_sudorule_notafter
            ldap_sudorule_notbefore = my_ldap_sudorule_notbefore
            ldap_sudorule_object_class = my_ldap_sudorule_object_class
            ldap_sudorule_option = my_ldap_sudorule_option
            ldap_sudorule_order = my_ldap_sudorule_order
            ldap_sudorule_runasgroup = my_ldap_sudorule_runasgroup
            ldap_sudorule_runasuser = my_ldap_sudorule_runasuser
            ldap_sudorule_user = my_ldap_sudorule_user
            ldap_tls_cacert = /path/to/cacert.pem
            ldap_tls_cacertdir = /etc/pki/simp_apps/sssd/x509/cacerts
            ldap_tls_cert = /etc/pki/simp_apps/sssd/x509/public/foo.example.com.pub
            ldap_tls_cipher_suite = HIGH:-SSLv2
            ldap_tls_key = /etc/pki/simp_apps/sssd/x509/private/foo.example.com.pem
            ldap_tls_reqcert = demand
            ldap_uri = ldap://test.example.domain
            ldap_use_tokengroups = false
            ldap_user_ad_account_expires = my_ldap_user_ad_account_expires
            ldap_user_ad_user_account_control = my_ldap_user_ad_user_account_control
            ldap_user_authorized_host = my_ldap_user_authorized_host
            ldap_user_authorized_service = my_ldap_user_authorized_service
            ldap_user_extra_attrs = attr1,attr2
            ldap_user_fullname = my_ldap_user_fullname
            ldap_user_gecos = my_ldap_user_gecos
            ldap_user_gid_number = my_ldap_user_gid_number
            ldap_user_home_directory = my_ldap_user_home_directory
            ldap_user_krb_last_pwd_change = my_ldap_user_krb_last_pwd_change
            ldap_user_krb_password_expiration = my_ldap_user_krb_password_expiration
            ldap_user_member_of = my_ldap_user_member_of
            ldap_user_modify_timestamp = my_ldap_user_modify_timestamp
            ldap_user_name = my_ldap_user_name
            ldap_user_nds_login_allowed_time_map = my_ldap_user_nds_login_allowed_time_map
            ldap_user_nds_login_disabled = my_ldap_user_nds_login_disabled
            ldap_user_nds_login_expiration_time = my_ldap_user_nds_login_expiration_time
            ldap_user_object_class = my_ldap_user_object_class
            ldap_user_objectsid = my_ldap_user_objectsid
            ldap_user_principal = my_ldap_user_principal
            ldap_user_search_base = my_ldap_user_search_base
            ldap_user_shadow_expire = my_ldap_user_shadow_expire
            ldap_user_shadow_inactive = my_ldap_user_shadow_inactive
            ldap_user_shadow_last_change = my_ldap_user_shadow_last_change
            ldap_user_shadow_max = my_ldap_user_shadow_max
            ldap_user_shadow_min = my_ldap_user_shadow_min
            ldap_user_shadow_warning = my_ldap_user_shadow_warning
            ldap_user_shell = my_ldap_user_shell
            ldap_user_ssh_public_key = my_ldap_user_ssh_public_key
            ldap_user_uid_number = my_ldap_user_uid_number
            ldap_user_uuid = my_ldap_user_uuid
            EXPECTED

          is_expected.to create_sssd__config__entry("puppet_provider_#{title}_ldap").with_content(expected)
        end
      end
    end
  end
end
