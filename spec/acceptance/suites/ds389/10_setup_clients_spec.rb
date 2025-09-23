require 'spec_helper_acceptance'

test_name 'Setup SSSD clients to talk to LDAP'

describe '389ds' do
  ldap_servers = hosts_with_role(hosts, 'ldap')
  clients      = hosts_with_role(hosts, 'client')
  # base dn must match what is set in server setup.
  base_dn      = 'dc=test,dc=org'

  let(:client_manifest) do
    <<~EOS
      include 'sssd'
      include 'sssd::service::nss'
      include 'sssd::service::pam'
      include 'sssd::service::autofs'
      include 'sssd::service::sudo'
      include 'sssd::service::ssh'

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
        ldap_pwd_policy            => none,
        ldap_user_gecos            => 'displayName',
        ldap_user_ssh_public_key   => 'nsSshPublicKey',
        ldap_account_expire_policy => 'ipa',
        ldap_id_mapping            => false,
        app_pki_key                => "/etc/pki/simp_apps/sssd/x509/private/#{fqdn}.pem",
        app_pki_cert               => "/etc/pki/simp_apps/sssd/x509/public/#{fqdn}.pub",
        ldap_default_authtok_type  => 'password'
      }

      class { 'nsswitch':
        passwd  => ['sss', 'files'],
        group   => ['sss', 'files'],
        shadow  => ['sss', 'files'],
        sudoers => ['files', 'sss']
      }
    EOS
  end

  ldap_servers.each do |server|
    server_fqdn  = fact_on(server, 'fqdn')
    domain       = fact_on(server, 'domain')
    clients.each do |client|
      context 'on each client set up sssd' do
        # set sssd domains for template
        let(:sssd_extra) do
          <<~EOM
            sssd::enable_files_domain: true
          EOM
        end
        let(:fqdn) { fact_on(client, 'fqdn') }

        let(:client_hieradata) do
          ERB.new(File.read(File.expand_path('templates/ds389_hiera.yaml.erb', File.dirname(__FILE__)))).result(binding) + "\n#{sssd_extra}"
        end

        it 'runs puppet' do
          set_hieradata_on(client, client_hieradata)
          apply_manifest_on(client, client_manifest, catch_failures: true)
        end

        it 'is idempotent' do
          # ldap provider has checks for sssd version when creating the
          # sssd.conf entry.  Therefore it might chnage the second run when
          # it knows the version.  Check for idempotency on the third run
          apply_manifest_on(client, client_manifest, catch_failures: true)
          apply_manifest_on(client, client_manifest, catch_changes: true)
        end

        it 'sees ldap users' do
          ['testuser', 'realuser'].each do |user|
            id = on(client, "id #{user}")
            expect(id.stdout).to match(%r{#{user}})
          end
        end

        it 'runs sssd-sudo after querying for sudo rules' do
          on(client, 'sudo -l')
          response = YAML.safe_load(on(client, %(puppet resource service sssd-sudo --to_yaml)).stdout)
          expect(response['service']['sssd-sudo']['ensure']).to eq('running')
        end

        it 'has a sssd_sudo.log file after querying for sudo rules' do
          response = YAML.safe_load(on(client, %(puppet resource file /var/log/sssd/sssd_sudo.log --to_yaml)).stdout)
          expect(response['file']['/var/log/sssd/sssd_sudo.log']['ensure']).to eq('file')
        end
      end
    end
  end
end
