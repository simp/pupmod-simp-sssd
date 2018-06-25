require 'spec_helper_acceptance'

test_name 'SSSD connecting to an AD'

describe 'sssd class' do

  clients     = hosts_with_role(hosts,'client')
  ad          = hosts_with_role(hosts,'ad').first
  domain_pass = '@dm1n=P@ssw0r'
  domain      = fact_on(clients.first, 'domain')

  let(:ad_ip) {
    require 'json'
    f = JSON.load(on(ad, 'puppet facts').stdout)
    f['values']['networking']['interfaces']['Ethernet 2']['ip']
  }
  let(:hiera) {{
    'simp_options::sssd'          => true, # had to add because of the pam changes
    'simp_options::pki'           => true,
    'simp_options::pki::source'   => '/etc/pki/simp-testing/pki',
    'simp_options::dns::servers'  => [ad_ip],
    'simp_options::ldap::uri'     => ['ldap://FIXME'],
    'simp_options::ldap::bind_dn' => 'cn=Administrator,cn=Users,dc=test,dc=case',
    'simp_options::ldap::base_dn' => 'dc=test,dc=case',
    'simp_options::ldap::bind_pw' => '<PASSWORD>',
    # This causes a lot of noise and reboots
    'sssd::auditd'                => false,
    'sssd::domains'               => [ 'LOCAL','test.case' ],
    'resolv::named_autoconf'      => false,
    'resolv::caching'             => false,
    'resolv::resolv_domain'       => 'test.case',
    'pam::disable_authconfig'     => false,
    'ssh::server::conf::permitrootlogin'        => true,
    'ssh::server::conf::authorizedkeysfile'     => '.ssh/authorized_keys',
    'ssh::server::conf::gssapiauthentication'   => true,
    'ssh::server::conf::passwordauthentication' => true,
  }}
  let(:manifest) { <<-EOF
      include '::sssd'
      include '::sssd::service::nss'
      include '::sssd::service::pam'
      include '::sssd::service::autofs'
      include '::sssd::service::sudo'
      include '::sssd::service::ssh'
      include '::resolv'
      include '::pam'
      include '::simp::nsswitch'
      include '::ssh'

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

      ####################################################################
      # AD CONFIG
      sssd::domain { 'test.case':
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
      sssd::provider::ad { 'test.case':
        ad_domain         => 'test.case',
        ad_servers        => ['ad.test.case'],
        # ad_access_filters => 'test.case:OU=HeadQuarter,OU=Locations,DC=test,DC=case'
        ldap_id_mapping   => true,
        ldap_schema       => 'ad',
        krb5_realm        => 'TEST.CASE',
        dyndns_update     => true,     # add the host to dns
        dyndns_ifaces     => ['eth1'], # vagrant uses 2 interfaces, we want the second
        default_shell     => '/bin/bash',
        fallback_homedir  => '/home/%u@%d',
        krb5_store_password_if_offline => true,
      }
    EOF
  }

  context 'fix the hosts file' do
    clients.each do |host|
      it 'should install packages for testing' do
        host.install_package('epel-release')
        host.install_package('sshpass')
      end
      # On windows hosts, beaker does not detect the domain (that or it
      #  isn't set yet), so the bunk value must be removed and replaced with
      #  the FQDN of the AD server
      it 'should have the ad host with its fqdn' do
        require 'yaml'
        # Find the IP of the AD host and make a new host entry with FQDN and IP
        ad_host = YAML.load(on(host, 'puppet resource host ad. --to_yaml').stdout)
        ip = ad_host['host']['ad.']['ip']
        on(host, "puppet resource host ad.test.case ensure=present ip=#{ip} host_aliases=ad")
        # Remove incorrect and incomplete hosts entry
        on(host, 'puppet resource host ad. ensure=absent')
        # Also remove hosts entry with just a host shortname
        on(host, "puppet resource host #{host} ensure=absent")
      end
      it 'should make sure /etc/hosts only has the new domain in it' do
        on(host, "sed -i 's/#{domain}/test.case/' /etc/hosts")
      end
      it 'should install the realm or adcli packages' do
        # Some of these packages only exist on EL6 or EL7
        pp = "package { ['realmd','adcli','oddjob','oddjob-mkhomedir','samba-common-tools','pam_krb5','samba4-common','krb5-workstation']: ensure => installed }"
        apply_manifest_on(host, pp)
      end
    end
  end

  context 'generate a good sssd.conf' do
    clients.each do |host|
      it 'should apply enough to generate sssd.conf' do
        set_hieradata_on(host, hiera)
        apply_manifest_on(host, manifest)
        apply_manifest_on(host, manifest) # pam needs one more
      end
      describe file('/etc/sssd/sssd.conf') do
        expected = File.read('spec/acceptance/suites/ad/files/sssd.conf.txt')
        it { is_expected.to be_file }
        its(:content) { is_expected.to match(expected) }
      end
    end
  end

  context 'do realmd or adcli stuff' do
    clients.each do |host|
      case host[:platform]
      when /el-6-x86_64/
        it 'should join test.case' do
          on(host, "echo -n '#{domain_pass}' | adcli join -v -U Administrator test.case -H #{host}.test.case --stdin-password --show-details")
        end
        it 'should have a realm listed' do
          result = on(host, 'adcli info test.case')
          expect(result.stdout).to match(/domain-name = test.case/)
        end
      when /el-7-x86_64/
        it 'make sure it is not in a domain automatically' do
          on(host, 'realm leave')
        end
        it 'should join test.case' do
          on(host, "echo '#{domain_pass}' | realm join -v -U Administrator test.case")
        end
        it 'should have a realm listed' do
          result = on(host, 'realm list')
          expect(result.stdout).to match(/domain-name: test.case/)
        end
        it 'should have itself listed in DNS' do
          ip = on(host, "dig #{host}.test.case A +short")
          expect(ip.stdout).to match(/10.255/)
        end
      end
    end
  end

  context 'run puppet and still work' do
    clients.each do |host|
      it 'should copy certs to new hostnames' do
        on(host, "find /etc/pki/simp_apps/ -name #{host}.#{domain}* | sed -e \"p;s/#{domain}/test.case/\" | xargs -n2 cp")
      end
      it 'should run puppet without error' do
        apply_manifest_on(host, manifest, catch_failures: true)
        apply_manifest_on(host, manifest, catch_changes: true)
      end
      it 'should be able to id one of the test users' do
        ['mike.hammer','john.franklin','davegrohl'].each do |user|
          id = on(host, "id #{user}@test.case")
          expect(id.stdout).to match(/#{user}@test.case/)

          su = on(host, "su #{user}@test.case -c 'cd; pwd; exit'")
          expect(su.stdout).to match(%r{/home/#{user}@test.case})
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
      users.each do |user,pass|
        it 'should be able to log in with password' do
          ssh_cmd = [
            'sshpass',
            "-p 'suP3rP@ssw0r!'",
            'ssh',
            '-o StrictHostKeyChecking=no',
            "-l #{user}@test.case",
            "#{host}.test.case",
            "'cd; pwd; exit'"
          ].join(' ')
          ssh = on(host, ssh_cmd)

          expect(ssh.stdout).to match(%r{/home/#{user}@test.case})
        end
      end
    end
  end
end
