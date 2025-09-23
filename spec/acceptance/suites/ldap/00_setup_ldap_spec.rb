require 'spec_helper_acceptance'

test_name 'Setup LDAP'

describe 'LDAP' do
  ldap_servers = hosts_with_role(hosts, 'ldap')

  let(:server_manifest) do
    <<~EOS
      include 'simp_openldap::server'
    EOS
  end

  ldap_servers.each do |server|
    server_fqdn  = fact_on(server, 'fqdn')
    domain       = fact_on(server, 'domain')
    base_dn      = domain.split('.').map { |d| "dc=#{d}" }.join(',')

    let(:server_hieradata) do
      ERB.new(File.read(File.expand_path('templates/server_hieradata_tls.yaml.erb', File.dirname(__FILE__)))).result(binding)
    end
    let(:add_testuser) do
      File.read(File.expand_path('templates/add_testuser.ldif.erb', File.dirname(__FILE__)))
    end

    it 'runs puppet' do
      on(server, 'mkdir -p /usr/local/sbin/simp')
      set_hieradata_on(server, server_hieradata)
      apply_manifest_on(server, server_manifest, catch_failures: true)
    end

    it 'is able to add a user' do
      create_remote_file(server, '/tmp/add_testuser.ldif', ERB.new(add_testuser).result(binding))

      on(server, "ldapadd -D cn=LDAPAdmin,ou=People,#{base_dn} -H ldaps://#{server_fqdn} -w suP3rP@ssw0r! -x -f /tmp/add_testuser.ldif")

      result = on(server, "ldapsearch -LLL -D cn=LDAPAdmin,ou=People,#{base_dn} -H ldaps://#{server_fqdn} -w suP3rP@ssw0r! -x uid=test.user")
      expect(result.stdout).to include("dn: uid=test.user,ou=People,#{base_dn}")
    end
  end
end
