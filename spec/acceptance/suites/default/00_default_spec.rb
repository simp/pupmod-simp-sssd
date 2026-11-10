require 'spec_helper_acceptance'

test_name 'SSSD Base Tests'

describe 'sssd class' do
  require_relative('lib/util')
  include SssdTestUtil

  clients = hosts_with_role(hosts, 'client')

  let(:default_hieradata) do
    {
      'simp_options::pki'         => true,
      'simp_options::pki::source' => '/etc/pki/simp-testing/pki',
      # This causes a lot of noise and reboots
      'sssd::auditd'              => false,
    }
  end

  let(:simp_defaults) { default_hieradata.merge(SssdTestUtil::SIMP_DEFAULTS) }

  let(:manifest) do
    <<~EOS
      include sssd
    EOS
  end

  clients.each do |client|
    os_release = fact_on(client, 'os.release.major').to_s.to_i

    # What SSSD requires of its configuration files: on EL10 sssd runs as
    # sssd:sssd and the files must be group-readable; EL8/9 keep them
    # root-only.
    let(:el10) { fact_on(client, 'os.release.major').to_s.to_i >= 10 }
    let(:owner) { el10 ? 'root:sssd' : 'root:root' }
    let(:mode) { el10 ? '0640' : '0600' }

    before(:context) { with_compliance_engine(client) }

    # Exercise noop from a clean (uninstalled) state: on a fresh node the Sicura
    # console previews the module with `puppet apply --noop`, which must not error
    # even though nothing sssd manages exists yet. A bare include declares only
    # packages, so the preview enforces simp:defaults, which is what a SIMP site
    # would apply. Real idempotence is covered by the applies below. A
    # post-convergence noop check is deliberately omitted: `puppet apply --noop
    # --detailed-exitcodes` always exits 0, so it could never fail and would
    # test nothing.
    context 'in noop mode from a clean state' do
      before(:context) do
        on(client, 'puppet resource package sssd ensure=absent')
      end

      it 'previews simp:defaults without errors' do
        set_hieradata_on(client, simp_defaults)
        result = apply_manifest_on(client, manifest, catch_failures: true, noop: true)

        # Guards against the preview quietly covering the packages alone if
        # the Compliance Engine layer stops resolving the profile.
        expect(result.output).to match(%r{Ini_setting\[sssd /etc/sssd/sssd\.conf \[sssd\] debug_timestamps\]/ensure: .*\(noop\)})
        expect(result.output).to match(%r{Ini_subsetting\[sssd /etc/sssd/sssd\.conf \[sssd\] services nss\]/ensure: .*\(noop\)})
      end
    end

    context 'with a bare include' do
      let(:admin_snippet) { '/etc/sssd/conf.d/60_admin.conf' }
      let(:stale_snippet) { '/etc/sssd/conf.d/50_puppet_stale.conf' }

      it 'installs the packages' do
        set_hieradata_on(client, {})
        apply_manifest_on(client, manifest, catch_failures: true)
        on(client, 'rpm -q sssd sssd-dbus sssd-client sssd-tools')
      end

      it 'leaves existing configuration alone' do
        # An administrator's snippet, one left behind by an earlier release
        # of this module, and the services line ipa-client-install and
        # realm join write.
        [admin_snippet, stale_snippet].each do |snippet|
          create_remote_file(client, snippet, "[nss]\nmemcache_timeout = 301\n")
          on(client, "chown #{owner} #{snippet} && chmod #{mode} #{snippet}")
        end
        create_remote_file(client, '/etc/sssd/sssd.conf', "[sssd]\nservices = nss, pam, sudo\n")
        on(client, "chown #{owner} /etc/sssd/sssd.conf && chmod #{mode} /etc/sssd/sssd.conf")

        before = etc_sssd_state(client)
        apply_manifest_on(client, manifest, catch_changes: true)
        expect(etc_sssd_state(client)).to eq(before)
      end
    end

    context 'with simp:defaults enforced' do
      it 'applies with no errors' do
        set_hieradata_on(client, simp_defaults)
        apply_manifest_on(client, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(client, manifest, catch_changes: true)
      end

      it 'starts sssd and the sudo socket' do
        on(client, 'systemctl is-active sssd')
        on(client, 'systemctl is-enabled sssd')
        on(client, 'systemctl restart sssd-sudo.socket && systemctl is-active sssd-sudo.socket')
      end

      # sudo is removed from the line, or sssd-sudo.socket won't start.
      it 'writes the [sssd] settings in place' do
        conf = on(client, 'cat /etc/sssd/sssd.conf').stdout
        expect(conf).to match(%r{^services = nss,pam,ssh$})
        expect(conf).not_to match(%r{^services = .*sudo})
        expect(conf).to match(%r{^debug_timestamps = true$})
        stat = on(client, 'stat -c "%U:%G %a" /etc/sssd/sssd.conf').stdout.strip
        expect(stat).to eq("#{owner} #{mode.delete_prefix('0')}")
      end

      it 'keeps the administrator snippet and removes the stale Puppet one' do
        on(client, 'test -f /etc/sssd/conf.d/60_admin.conf')
        on(client, 'test ! -e /etc/sssd/conf.d/50_puppet_stale.conf')
      end

      it 'passes sssctl config-check' do
        on(client, 'sssctl config-check')
      end
    end

    context 'with default files domain set up' do
      # To make sssctl work ifp needs to be turned on in EL8+.  Note: IFP is
      # not needed for SSSD to work; it gives a simple way to test if sssd is
      # working.  services_entries is deep merged, so this adds ifp to the
      # profile's list.
      let(:hieradata) { simp_defaults.merge('sssd::services_entries' => { 'ifp' => {} }) }

      it 'manifest should work with no errors' do
        set_hieradata_on(client, hieradata)
        apply_manifest_on(client, manifest, catch_failures: true)

        # idempotent

        apply_manifest_on(client, manifest, catch_changes: true)
      end

      # rubocop:disable RSpec/RepeatedDescription
      it 'gets local user information' do
        on(client, 'useradd testuser --password "mypassword" -M -u 97979 -U')

        # Allow sssd to wake up and do whatever it does :-|
        sleep(10)

        result = on(client, 'sssctl user-checks testuser').stdout
        expect(result).to match(%r{.*- user id: 97979.*})
      end

      # SSSD 2.10 dismantled the implicit files domain.  On EL10 the profile
      # configures the documented replacement instead -- the LOCAL proxy
      # domain with proxy_lib_name => 'files' -- so assert whichever domain
      # this release is supposed to have rather than skipping the check.
      if os_release >= 10
        it 'is running and has set up the LOCAL proxy domain' do
          result = on(client, 'sssctl domain-list; sssctl domain-list').stdout
          expect(result).to include('LOCAL')
        end
      else
        it 'is running and have set up implicit_files domain' do
          result = on(client, 'sssctl domain-list; sssctl domain-list').stdout
          expect(result).to include('implicit_files')
        end
      end

      it 'gets local user information' do
        result = on(client, 'sssctl user-checks testuser 2>&1', accept_all_exit_codes: true).stdout
        expect(result).to match(%r{.*- user id: 97979.*})
      end
      # rubocop:enable RSpec/RepeatedDescription
    end

    # Every setting can be enforced and un-enforced on its own: a run that
    # stops setting something leaves it in place, and only 'absent' removes
    # it. No profile and no purge are in force here.
    context 'with a single setting, enforced and then un-enforced' do
      let(:setting) { %r{^debug_level = 3$} }

      it 'sets it' do
        set_hieradata_on(client, default_hieradata.merge('sssd::debug_level' => 3))
        apply_manifest_on(client, manifest, catch_failures: true)
        expect(on(client, 'cat /etc/sssd/sssd.conf').stdout).to match(setting)
        on(client, 'sssctl config-check')
      end

      it 'takes effect' do
        # The service is not managed without the profile, so apply the change
        # by hand, as the README describes.
        on(client, 'systemctl restart sssd && systemctl is-active sssd')
      end

      it 'leaves it, and everything the profile set, alone once unset' do
        set_hieradata_on(client, default_hieradata)
        apply_manifest_on(client, manifest, catch_changes: true)

        conf = on(client, 'cat /etc/sssd/sssd.conf').stdout
        expect(conf).to match(setting)
        expect(conf).to match(%r{^debug_timestamps = true$})
        expect(on(client, 'cat /etc/sssd/conf.d/50_puppet_service_nss.conf').stdout).to match(%r{^filter_users = root$})
        on(client, 'systemctl is-active sssd')
      end

      it 'removes it when set to absent' do
        set_hieradata_on(client, default_hieradata.merge('sssd::debug_level' => 'absent'))
        apply_manifest_on(client, manifest, catch_failures: true)
        expect(on(client, 'cat /etc/sssd/sssd.conf').stdout).not_to match(%r{^debug_level})
        on(client, 'sssctl config-check')
      end
    end
  end
end
