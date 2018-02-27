require 'spec_helper_acceptance'

describe 'sssd' do
  hiera = {
    'simp_options::pki'           => true,
    'simp_options::pki::source'   => '/etc/pki/simp-testing/pki',
    'simp_options::clamav'        => true,
    'simp_options::firewall'      => true,
    'simp_options::haveged'       => true,
    'simp_options::logrotate'     => true,
    'simp_options::pam'           => true,
    'simp_options::selinux'       => true,
    'simp_options::stunnel'       => true,
    'simp_options::syslog'        => true,
    'simp_options::tcpwrappers'   => true,
    'simp_options::ldap::uri'     => ['ldap://FIXME'],
    'simp_options::ldap::bind_dn' => 'cn=Administrator,cn=Users,dc=test,dc=case',
    'simp_options::ldap::base_dn' => 'dc=test,dc=case',
    'simp_options::ldap::bind_pw' => '<PASSWORD>',
    # This causes a lot of noise and reboots
    'sssd::auditd'                => false,
    'sssd::domains'               => [ 'LOCAL','test.case' ],
    'sssd::services'              => ['nss','pam'],
  }
  manifest = <<-EOF
      include '::sssd'
      include '::sssd::service::nss'
      include '::sssd::service::pam'
      include '::sssd::service::autofs'
      include '::sssd::service::sudo'
      include '::sssd::service::ssh'

      # LOCAL CONFIG
      sssd::domain { 'LOCAL':
        description       => 'LOCAL Users Domain',
        id_provider       => 'local',
        auth_provider     => 'local',
        access_provider   => 'permit',
        min_id            => 1000,
        enumerate         => false,
        cache_credentials => false
      }
      sssd::provider::local { 'LOCAL': }

      # LDAP CONFIG
      sssd::domain { 'LDAP':
        description       => 'LDAP Users Domain',
        id_provider       => 'ldap',
        auth_provider     => 'ldap',
        chpass_provider   => 'ldap',
        access_provider   => 'ldap',
        sudo_provider     => 'ldap',
        autofs_provider   => 'ldap',
        min_id            => 1000,
        enumerate         => false,
        cache_credentials => true,
        use_fully_qualified_names => false,
      }
      sssd::provider::ldap { 'LDAP':
        ldap_user_gecos => 'dn',
        ldap_id_mapping => false,
        app_pki_key     => '/etc/pki/simp_apps/sssd/x509/private/host.test.case.pem',
        app_pki_cert    => '/etc/pki/simp_apps/sssd/x509/public/host.test.case.pub',
        ldap_default_authtok_type => 'password',
      }

      ####################################################################
      # AD CONFIG
      sssd::domain { 'test.case':
        access_provider   => 'ad',
        cache_credentials => true,
        id_provider       => 'ad',
        enumerate         => undef,
        realmd_tags       => 'manages-system joined-with-adcli',
        case_sensitive    => true,
        ignore_group_members => true,
        use_fully_qualified_names => true
      }
      sssd::provider::ad { 'test.case':
        ad_domain        => 'test.case',
        ad_servers       => ['ad.test.case'],
        ldap_id_mapping  => false,
        krb5_realm       => 'TEST.CASE',
        dyndns_update    => undef,
        default_shell    => '/bin/bash',
        fallback_homedir => '/home/%u@%d',
        krb5_store_password_if_offline => true,
      }
    EOF
  context 'generate a good sssd.conf' do
    hosts.each do |host|
      it 'should apply enough to generate sssd.conf' do
        set_hieradata_on(host, hiera)
        apply_manifest_on(host, manifest)
      end
      describe file('/etc/sssd/sssd.conf') do
        expected = File.read('spec/acceptance/suites/default/files/sssd.conf.txt')
        it { is_expected.to be_file }
        its(:content) { is_expected.to match(expected) }
      end
    end
  end
end
