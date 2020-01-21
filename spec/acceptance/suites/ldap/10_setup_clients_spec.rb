require 'spec_helper_acceptance'

test_name 'Setup SSSD clients to talk to LDAP'



describe 'LDAP' do

  ldap_servers = hosts_with_role(hosts,'ldap')
  clients      = hosts_with_role(hosts,'client')
  server_fqdn  = fact_on(ldap_servers.first,'fqdn')
  domain       = fact_on(ldap_servers.first, 'domain')
  base_dn      = domain.split('.').map{ |d| "DC=#{d}" }.join(',')

let(:client_manifest) {
   <<-EOS

      sssd::domain { 'LOCAL':
        description       => 'LOCAL Users Domain',
        id_provider       => 'local',
        auth_provider     => 'local',
        access_provider   => 'permit',
        min_id            => 500,
        # These don't make sense on the local domain
        enumerate         => false,
        cache_credentials => false
      }
     sssd::domain { 'LDAP':
        description       => 'LDAP Users Domain',
        id_provider       => 'ldap',
        auth_provider     => 'ldap',
        chpass_provider   => 'ldap',
        access_provider   => 'ldap',
        sudo_provider     => 'ldap',
        autofs_provider   => 'ldap',
        min_id            => 500,
        enumerate         => true,
        cache_credentials => true
      }

      sssd::provider::ldap { 'LDAP':
        ldap_default_authtok_type => 'password',
        ldap_user_gecos           => 'dn'
      }

      class { 'nsswitch':
        passwd => ['sss', 'files'],
        group  => ['sss', 'files'],
        shadow => ['sss', 'files'],
      }

   EOS
}

  clients.each do |client|
    context 'on each client set up sssd' do
      # set sssd domains for template
      case client[:platform]
      when  /el-6-x86_64/
        let(:sssd_domains) {['LOCAL', 'LDAP']}
      when /el-7-x86_64/
        let(:sssd_domains) {['LOCAL', 'LDAP']}
      else /el-8-x86_64/
        let(:sssd_domains) {['LDAP']}
      end
      let(:client_hieradata)  {
        ERB.new(File.read(File.expand_path('templates/server_hieradata_tls.yaml.erb', File.dirname(__FILE__)))).result(binding) + "\nsssd::domains: #{sssd_domains}"
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
        ['test.user','real.user'].each do |user|
          id = on(client, "id #{user}")
          expect(id.stdout).to match(/#{user}/)
        end
      end
    end

  end
end
