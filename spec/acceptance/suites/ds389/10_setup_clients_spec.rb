require 'spec_helper_acceptance'

test_name 'Setup SSSD clients to talk to LDAP'



describe 'LDAP' do

  ldap_servers = hosts_with_role(hosts,'ldap')
  clients      = hosts_with_role(hosts,'client')
  server_fqdn  = fact_on(ldap_servers.first,'fqdn')
  domain       = fact_on(ldap_servers.first, 'domain')
  base_dn      = domain.split('.').map{ |d| "DC=#{d}" }.join(',')

  let(:client_manifest) { <<~EOS
    include '::sssd'
    include '::sssd::service::nss'
    include '::sssd::service::pam'
    include '::sssd::service::autofs'
    include '::sssd::service::sudo'
    include '::sssd::service::ssh'

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
      use_fully_qualified_names => false
    }
    sssd::provider::ldap { 'LDAP':
      ldap_pwd_policy => none,
      ldap_user_gecos => 'displayName',
      ldap_user_ssh_public_key => 'nsSshPublicKey',
      ldap_account_expire_policy => 'ipa',
      ldap_id_mapping => false,
      app_pki_key     => "/etc/pki/simp_apps/sssd/x509/private/#{fqdn}.pem",
      app_pki_cert    => "/etc/pki/simp_apps/sssd/x509/public/#{fqdn}.pub",
      ldap_default_authtok_type => 'password'
    }

#      class { 'nsswitch':
#        passwd => ['sss', 'files'],
#        group  => ['sss', 'files'],
#        shadow => ['sss', 'files'],
#      }
    EOS
  }

  clients.each do |client|
    context 'on each client set up sssd' do
      # set sssd domains for template
      let(:sssd_extra) { <<~EOM
          sssd::enable_files_domain: true
        EOM
      }

      let(:base_dn) { 'dc=test,dc=org'}

      let(:client_hieradata)  {
        ERB.new(File.read(File.expand_path('templates/ds389_hiera.yaml.erb',File.dirname(__FILE__)))).result(binding) + "\n#{sssd_extra}"
      }

      it 'should run puppet' do
        on(client, 'mkdir -p /usr/local/sbin/simp')
        set_hieradata_on(client, client_hieradata)
        apply_manifest_on(client, client_manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        # ldap provider has checks for sssd version when creating the
        # sssd.conf entry.  There for it might chnage the second run when
        # it knows the version.  Check for idempotency on the third run
        apply_manifest_on(client, client_manifest, :catch_failures => true)
        apply_manifest_on(client, client_manifest, :catch_changes => true)
      end

      it 'should see ldap users' do
        ['testuser','realuser'].each do |user|
          id = on(client, "id #{user}")
          expect(id.stdout).to match(/#{user}/)
        end
      end
    end
  end
end
