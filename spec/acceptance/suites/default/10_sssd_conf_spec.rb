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
    'sssd::domains'               => [ 'local','test.case' ],
    'sssd::services'              => ['nss','pam'],
  }

  let(:manifest) { <<-EOF
      include 'sssd'
      include 'sssd::service::nss'
      include 'sssd::service::pam'
      include 'sssd::service::autofs'
      include 'sssd::service::sudo'
      include 'sssd::service::ssh'

      #{local_config}

      # LDAP CONFIG
      sssd::domain { 'LDAP':
        description               => 'LDAP Users Domain',
        id_provider               => 'ldap',
        auth_provider             => 'ldap',
        chpass_provider           => 'ldap',
        access_provider           => 'ldap',
        sudo_provider             => 'ldap',
        autofs_provider           => 'ldap',
        min_id                    => 1000,
        enumerate                 => false,
        cache_credentials         => true,
        use_fully_qualified_names => false,
      }
      sssd::provider::ldap { 'LDAP':
        ldap_user_gecos           => 'dn',
        ldap_id_mapping           => false,
        app_pki_key               => '/etc/pki/simp_apps/sssd/x509/private/host.test.case.pem',
        app_pki_cert              => '/etc/pki/simp_apps/sssd/x509/public/host.test.case.pub',
        ldap_default_authtok_type => 'password',
      }
    EOF
  }

  context 'generate a good sssd.conf' do
    hosts.each do |host|

      if fact_on(host, 'operatingsystemmajrelease') < '7'
        let(:local_config) { <<~EOM
            # LOCAL CONFIG
            sssd::domain { 'local':
              description       => 'LOCAL Users Domain',
              id_provider       => 'local',
              auth_provider     => 'local',
              access_provider   => 'permit',
              min_id            => 1000,
              enumerate         => false,
              cache_credentials => false
            }
            sssd::provider::local { 'local': }
          EOM
        }

        local_hiera = hiera
      else
        let(:local_config) { '' }

        local_hiera = hiera.merge(
          {
            'sssd::enable_files_domain' => true,
            'sssd::domains'             => [ 'test.case' ]
          }
        )
      end

      it 'should apply enough to generate sssd.conf' do
        set_hieradata_on(host, local_hiera)
        apply_manifest_on(host, manifest)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end

      it 'should be running sssd' do
        response = YAML.load(on(host, %{puppet resource service sssd --to_yaml}).stdout.strip)
        expect(response['service']['sssd']['ensure']).to eq('running')
        expect(response['service']['sssd']['enable']).to eq('true')
      end
    end
  end
end
