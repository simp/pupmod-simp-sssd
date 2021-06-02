# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'sssd' do

  ldapservers =  hosts_with_role(hosts, 'ldap')

  ldapservers.each do |host|
    let(:root_pw) {'s00perS3kr!tP@ssw0rd'}
    let(:base_dn) { 'dc=test,dc=org' }
#    let(:hiera_template){ File.read('spec/acceptance/common_files/ds389_hiera.yaml.erb')}
                                    

    let(:manifest) do
      <<~MANIFEST
        include 'simp_ds389::instances::accounts'
        # To make sure in the unlikely case that something goes wrong during
        # test, you can still vagrant ssh in
        simp_firewalld::rule { "Allow ssh":
          trusted_nets => ['ALL'],
          apply_to     => 'all',
          dports       => [22],
          protocol     => 'tcp'
        }
     MANIFEST
    end
    let(:remove_manifest) do
      <<~RMANIFEST
        ds389::instance { 'accounts':
          ensure => 'absent'
        }
      RMANIFEST
    end
    let(:sssd_extra){ <<~EOM
      simp_ds389::instances::accounts::root_pw: #{root_pw}
    EOM
    }
    let(:server_hieradata) {
      ERB.new(File.read(File.expand_path('templates/ds389_hiera.yaml.erb',File.dirname(__FILE__)))).result(binding) + "\n#{sssd_extra}"
    }
    let(:fqdn) do
      fact_on(host,'fqdn').strip
    end
    let(:ds_root_name) { 'accounts'}
    let(:domain) do
      fact_on(host,'domain').strip
    end

    context 'install the server' do
      it 'works with no errors' do
#        default_hieradata = YAML.load(ERB.new(hiera_template).result(binding) + "\n#{server_hieradata}")
        set_hieradata_on(host, server_hieradata)
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      it 'can login to 389DS via LDAPI' do
        on(host, %(ldapsearch -x -w "#{root_pw}" -D "cn=Directory_Manager" -H ldapi://%2fvar%2frun%2fslapd-#{ds_root_name}.socket -b "cn=tasks,cn=config"))
      end
    end

    context 'when adding a test user' do
      let(:ldap_add_user) do
        <<~LDAP_ADD_USER
          dsidm "#{ds_root_name}" -b "#{base_dn}" posixgroup create --cn testuser --gidNumber 1001
          dsidm "#{ds_root_name}" -b "#{base_dn}" user create --cn testuser --uid testuser --displayName "Test User" --uidNumber 1001 --gidNumber 1001 --homeDirectory /home/testuser
          dsidm "#{ds_root_name}" -b "#{base_dn}" user modify testuser add:userPassword:{SSHA}NDZnXytV04X8JdhiN8zpcCE/r7Wrc9CiCukwtw==
          dsidm "#{ds_root_name}" -b "#{base_dn}" posixgroup create --cn realuser --gidNumber 1002
          dsidm "#{ds_root_name}" -b "#{base_dn}" user create --cn testuser --uid testuser --displayName "Real User" --uidNumber 1001 --gidNumber 1002 --homeDirectory /home/realuser
          dsidm "#{ds_root_name}" -b "#{base_dn}" user modify realuser add:userPassword:{SSHA}NDZnXytV04X8JdhiN8zpcCE/r7Wrc9CiCukwtw==
          LDAP_ADD_USER
      end

      it 'adds an LDAP user' do
        create_remote_file(host, '/tmp/ldap_add_user', ldap_add_user)
        on(host, 'chmod +x /tmp/ldap_add_user')
        on(host, '/tmp/ldap_add_user')
      end
    end

  end
end


