# frozen_string_literal: true

require 'spec_helper_acceptance'

test_name 'sssd simple access provider enforcement'

describe 'sssd::domain using the simple access provider' do
  raise 'No hosts with role "client" found in the nodeset' if hosts_with_role(hosts, 'client').empty?

  # Runs against the environment built by the earlier specs in this suite: a
  # 389DS server holding the users 'testuser' and 'realuser' (uid 1001 and
  # 1002, each the sole member of a matching primary posixgroup), and a
  # client whose hieradata already configures the 'LDAP' sssd domain.  Only
  # the manifest changes here: the domain switches from the ldap access
  # provider to the simple one.

  def manifest_with(fqdn, simple_options)
    <<~EOS
      include 'sssd'
      include 'sssd::service::nss'
      include 'sssd::service::pam'
      include 'sssd::service::ssh'

      sssd::domain { 'LDAP':
        description               => 'LDAP Users Domain',
        id_provider               => 'ldap',
        auth_provider             => 'ldap',
        chpass_provider           => 'ldap',
        access_provider           => 'simple',
        min_id                    => 1000,
        enumerate                 => false,
        cache_credentials         => true,
        use_fully_qualified_names => false,
        #{simple_options}
      }
      sssd::provider::ldap { 'LDAP':
        ldap_pwd_policy            => none,
        ldap_user_gecos            => 'displayName',
        ldap_user_ssh_public_key   => 'nsSshPublicKey',
        ldap_account_expire_policy => 'ipa',
        ldap_id_mapping            => false,
        app_pki_key                => "/etc/pki/simp_apps/sssd/x509/private/#{fqdn}.pem",
        app_pki_cert               => "/etc/pki/simp_apps/sssd/x509/public/#{fqdn}.pub",
        ldap_default_authtok_type  => 'password',
      }

      class { 'nsswitch':
        passwd  => ['sss', 'files'],
        group   => ['sss', 'files'],
        shadow  => ['sss', 'files'],
        sudoers => ['files', 'sss'],
      }
    EOS
  end

  def access_check(client, user)
    # sssctl user-checks drives pam_acct_mgmt through the host's real PAM
    # stack for the given service, exactly like a login would.  Its exit
    # code does not reflect the PAM verdict, so callers match the reported
    # result instead.
    on(client, "sssctl user-checks -a acct -s sshd #{user}", accept_all_exit_codes: true).output
  end

  hosts_with_role(hosts, 'client').each do |client|
    context "on client #{client} allowing by user" do
      let(:fqdn) { fact_on(client, 'networking.fqdn') }
      let(:manifest) { manifest_with(fqdn, "simple_allow_users        => ['realuser'],") }

      it 'wires pam_sss into the PAM stack' do
        # The cloud images ship with no authselect profile and a bare
        # pam_unix-only account phase, which approves any NSS-resolvable
        # user without ever consulting sssd — every access check would
        # falsely succeed.  A kickstarted EL system defaults to the sssd
        # profile; select it explicitly here.  This also overwrites
        # nsswitch.conf, which the puppet apply below re-asserts.
        on(client, 'authselect select sssd --force')
      end

      it 'applies with no errors' do
        apply_manifest_on(client, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(client, manifest, catch_changes: true)
      end

      it 'renders the allow list into the domain drop-in' do
        on(client, %(grep -x 'simple_allow_users = realuser' /etc/sssd/conf.d/50_puppet_domain_LDAP.conf))
      end

      it 'still resolves both LDAP users' do
        # the access provider gates logins, not identity lookups
        ['testuser', 'realuser'].each do |user|
          expect(on(client, "id #{user}").stdout).to match(%r{#{user}})
        end
      end

      it 'permits the allowed user' do
        expect(access_check(client, 'realuser')).to match(%r{pam_acct_mgmt: Success})
      end

      it 'denies a user missing from the allow list' do
        expect(access_check(client, 'testuser')).to match(%r{pam_acct_mgmt: Permission denied})
      end
    end

    context "on client #{client} allowing by group" do
      let(:fqdn) { fact_on(client, 'networking.fqdn') }
      let(:manifest) do
        # 'testuser' here is the LDAP posixgroup of the same name, exercising
        # group resolution through the id provider rather than a local group
        manifest_with(fqdn, "simple_allow_groups       => ['testuser'],")
      end

      it 'applies with no errors' do
        apply_manifest_on(client, manifest, catch_failures: true)
      end

      it 'permits a member of an allowed group' do
        expect(access_check(client, 'testuser')).to match(%r{pam_acct_mgmt: Success})
      end

      it 'denies a user in none of the allowed groups' do
        expect(access_check(client, 'realuser')).to match(%r{pam_acct_mgmt: Permission denied})
      end
    end
  end
end
