require 'spec_helper_acceptance'

test_name 'SSSD connecting to an AD'

describe 'sssd class' do
  clients     = hosts_with_role(hosts, 'client')
  ad          = hosts_with_role(hosts, 'ad').first
  domain_pass = '@dm1n=P@ssw0r'
  domain      = fact_on(clients.first, 'domain')
  ldap_dc     = domain.split('.').map { |x| "DC=#{x}" }.join(',')

  require 'json'
  ad_ip = JSON.parse(on(ad, 'puppet facts').stdout)['values']['networking']['interfaces']['Ethernet 2']['ip']

  let(:v2_manifest) do
    <<-EOF
      include 'sssd'
      include 'resolv'
      include 'pam'
      include 'simp::nsswitch'
      include 'ssh'
      EOF
  end

  let(:ad_manifest) do
    <<-EOF
      ####################################################################
      # AD CONFIG
      sssd::domain { 'AD':
        access_provider   => 'ad',
        cache_credentials => true,
        id_provider       => 'ad',
        enumerate         => undef,
        realmd_tags       => 'manages-system joined-with-samba',
        case_sensitive    => true,
        max_id            => 0,
        ignore_group_members => true,
        use_fully_qualified_names => true
      }

      sssd::provider::ad { 'AD':
        ad_domain         => '#{domain}',
        ad_servers        => ['ad.#{domain}'],
        # ad_access_filters => '#{domain}:OU=HeadQuarter,OU=Locations,#{ldap_dc}'
        ldap_id_mapping   => true,
        ldap_schema       => 'ad',
        krb5_realm        => '#{domain.upcase}',
        dyndns_update     => true,     # add the host to dns
        dyndns_ifaces     => ['eth1'], # vagrant uses 2 interfaces, we want the second
        default_shell     => '/bin/bash',
        fallback_homedir  => '/home/%u@%d',
        krb5_store_password_if_offline => true
      }
    EOF
  end

  hieradata = <<~EOM
    ---
    simp_options::sssd: true
    simp_options::pki: true
    simp_options::pki::source: '/etc/pki/simp-testing/pki'
    simp_options::ldap::uri: ['ldap://FIXME']
    simp_options::ldap::bind_dn: "CN=Administrator,CN=Users,#{ldap_dc}"
    simp_options::ldap::base_dn: "#{ldap_dc}"
    simp_options::ldap::bind_pw: '<PASSWORD>'
    # This causes a lot of noise and reboots
    sssd::auditd: false
    resolv::named_autoconf: false
    resolv::caching: false
    resolv::resolv_domain: "#{domain}"
    pam::disable_authconfig: false
    ssh::server::conf::permitrootlogin: true
    ssh::server::conf::authorizedkeysfile: '.ssh/authorized_keys'
    ssh::server::conf::gssapiauthentication: true
    ssh::server::conf::passwordauthentication: true
    EOM

  context 'fix the hosts file' do
    clients.each do |host|
      it 'installs packages for testing' do
        host.install_package('epel-release')
        host.install_package('sshpass')
      end
      # On windows hosts, beaker does not detect the domain (that or it
      #  isn't set yet), so the bunk value must be removed and replaced with
      #  the FQDN of the AD server
      it 'has the ad host with its fqdn' do
        require 'yaml'
        # Find the IP of the AD host and make a new host entry with FQDN and IP
        ad_host = YAML.safe_load(on(host, 'puppet resource host ad. --to_yaml').stdout)
        ip = ad_host['host']['ad.']['ip']
        on(host, "puppet resource host ad.#{domain} ensure=present ip=#{ip} host_aliases=ad")
        # Remove incorrect and incomplete hosts entry
        on(host, 'puppet resource host ad. ensure=absent')
        # Also remove hosts entry with just a host shortname
        on(host, "puppet resource host #{host} ensure=absent")
      end
      it 'installs the realm or adcli packages' do
        # Some of these packages only exist on EL6 or EL7
        pp = "package { ['realmd','adcli','oddjob','oddjob-mkhomedir','samba-common-tools','pam_krb5','samba4-common','krb5-workstation']: ensure => installed }"
        apply_manifest_on(host, pp)
      end
    end
  end

  context 'configure basic SSSD' do
    clients.each do |host|
      client_hiera = hieradata.dup

      let(:manifest) { v2_manifest }

      # An error is raised if the domain is already in the sssd.conf so
      # need to configure sssd without the domain.  (It looks like this
      # is an old error that was fixed in 2015 but el8 has the latest
      # version of realmd.)
      client_hiera += <<~EOM
        simp_options::dns::servers: ["#{ad_ip}"]
        sssd::enable_files_domain: true
        sssd::domains: []
      EOM

      it 'runs puppet without error configure basic SSSD' do
        set_hieradata_on(host, client_hiera)
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end
    end
  end

  context 'joining AD' do
    clients.each do |host|
      it 'joins the AD domain' do
        on(host, "echo -n '#{domain_pass}' | adcli join -v -S #{ad} -U Administrator #{domain} -H #{host}.#{domain} --stdin-password --show-details")
      end

      it 'has a realm listed' do
        result = on(host, "adcli info -S #{ad} #{domain}")
        expect(result.stdout).to match(%r{domain-name = #{domain}})
      end
    end
  end

  context 'when connected to AD' do
    clients.each do |host|
      let(:manifest) { v2_manifest }

      it 'updates sssd::domains in hiera' do
        # you can't have the domain in sssd before joing the realm or it
        # errors out so add it n here.
        client_hiera = hieradata + <<-EOM.gsub(%r{^\s+}, '')
          simp_options::dns::servers:    ["#{ad_ip}"]
          sssd::domains: ['AD']
        EOM

        set_hieradata_on(host, client_hiera)
      end

      let(:_ad_manifest) do
        [manifest, ad_manifest].join("\n")
      end
      it 'runs puppet without error connected to AD' do
        apply_manifest_on(host, _ad_manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, _ad_manifest, catch_changes: true)
      end

      it 'is able to id one of the test users' do
        ['mike.hammer', 'john.franklin', 'davegrohl'].each do |user|
          id = on(host, "id #{user}@AD")
          expect(id.stdout).to match(%r{#{user}@AD})

          su = on(host, "su #{user}@AD -c 'cd; pwd; exit'")
          expect(su.stdout).to match(%r{/home/#{user}@AD})
        end
      end
    end
  end

  context 'ssh into the other node' do
    users = {
      'mike.hammer'   => 'suP3rP@ssw0r!',
      'john.franklin' => 'suP3rP@ssw0r!',
      'davegrohl'     => 'suP3rP@ssw0r!',
    }

    clients.each do |host|
      users.each_key do |user|
        it 'is able to log in with password' do
          ssh_cmd = [
            'sshpass',
            "-p 'suP3rP@ssw0r!'",
            'ssh',
            '-o IdentitiesOnly=yes',
            '-F /dev/null',
            '-o StrictHostKeyChecking=no',
            "-l #{user}@AD",
            "#{host}.#{domain}",
            "'cd; pwd; exit'",
          ].join(' ')
          ssh = on(host, ssh_cmd)

          expect(ssh.stdout).to match(%r{/home/#{user}@AD})
        end
      end
    end
  end
end
