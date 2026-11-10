require 'spec_helper'
require_relative '../lib/sssd_spec_helpers'

# Enforcing the `simp:defaults` compliance_engine profile must reproduce what a
# bare `include sssd` configured before 11.0.0.
describe 'sssd' do
  let(:hiera_config) do
    File.expand_path('../fixtures/hieradata/hiera_compliance_engine.yaml', __dir__)
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:el10) { os_facts[:os][:release][:major].to_i >= 10 }

      # Settings SSSD 2.10 (EL10) removed from its schema, written on EL8/9.
      let(:el8_9) { ->(lines) { el10 ? [] : lines } }

      context 'with simp:defaults enforced' do
        let(:hieradata) { 'simp_defaults_enforced' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_service('sssd').with_ensure('running').with_enable(true) }

        it {
          is_expected.to contain_file('/etc/sssd').with_ensure('directory').with_mode(el10 ? 'g-w,o-rw' : 'go-rw')
        }
        it {
          is_expected.to contain_file('/etc/sssd/conf.d')
            .with_ensure('directory')
            .with_mode(el10 ? 'g-w,o-rw' : 'go-rw')
            .with_recurse(true)
            .with_purge(false)
        }
        it { is_expected.to contain_tidy('/etc/sssd/conf.d').with_matches('*_puppet_*.conf') }

        it {
          expect(entry_content('sssd')).to eq(
            (['[sssd]'] + el8_9.call(['config_file_version = 2', 'reconnection_retries = 3', 'enable_files_domain = true']) +
              ['debug_timestamps = true', 'debug_microseconds = false']).join("\n") + "\n",
          )
        }

        it 'lists the same services' do
          ['nss', 'pam', 'ssh'].each do |service|
            is_expected.to contain_ini_subsetting("sssd /etc/sssd/sssd.conf [sssd] services #{service}").with_ensure('present')
          end
        end

        # sudo-socket refuses to start while sudo is listed.
        it { is_expected.to contain_ini_subsetting('sssd /etc/sssd/sssd.conf [sssd] services sudo').with_ensure('absent') }

        if os_facts[:os][:release][:major].to_i >= 10
          it { is_expected.to contain_sssd__domain('LOCAL').with_id_provider('proxy').with_proxy_lib_name('files') }
          it { is_expected.to contain_ini_subsetting('sssd /etc/sssd/sssd.conf [sssd] domains LOCAL') }
          it { is_expected.not_to contain_systemd__dropin_file('00_sssd_sudo_user_group.conf') }
        else
          it { is_expected.not_to contain_sssd__domain('LOCAL') }
          it { is_expected.to contain_systemd__dropin_file('00_sssd_sudo_user_group.conf').with_ensure('present') }
        end

        it {
          expect(entry_content('puppet_service_nss')).to eq(
            (['[nss]', 'debug_timestamps = true', 'debug_microseconds = false'] + el8_9.call(['reconnection_retries = 3']) +
              [
                'enum_cache_timeout = 120',
                'entry_cache_nowait_percentage = 0',
                'entry_negative_timeout = 15',
                'filter_users = root',
                'filter_groups = root',
                'filter_users_in_groups = true',
              ]).join("\n") + "\n",
          )
        }

        it {
          expect(entry_content('puppet_service_pam')).to eq(
            (['[pam]', 'debug_timestamps = true', 'debug_microseconds = false'] + el8_9.call(['reconnection_retries = 3']) +
              [
                'offline_credentials_expiration = 0',
                'offline_failed_login_attempts = 3',
                'offline_failed_login_delay = 5',
                'pam_verbosity = 1',
                'pam_id_timeout = 5',
                'pam_pwd_expiration_warning = 7',
              ]).join("\n") + "\n",
          )
        }

        it {
          expect(entry_content('puppet_service_ssh')).to eq(
            (['[ssh]', 'debug_timestamps = true', 'debug_microseconds = false'] + el8_9.call(['ssh_hash_known_hosts = true'])).join("\n") + "\n",
          )
        }

        it {
          expect(entry_content('puppet_service_sudo')).to eq(<<~EOM)
            [sudo]
            debug_timestamps = true
            debug_microseconds = false
            sudo_threshold = 50
            sudo_timed = false
          EOM
        }

        it { is_expected.to contain_service('sssd-sudo.socket').with_enable(true) }

        # Responders that weren't in the default services list are included
        # but stay unconfigured.
        ['autofs', 'ifp', 'pac'].each do |service|
          it { is_expected.not_to contain_file("/etc/sssd/conf.d/50_puppet_service_#{service}.conf") }
        end

        context 'when joined to an IPA domain' do
          let(:facts) do
            os_facts.merge(ipa: { connected: true, domain: 'ipa.example.com', server: 'ipaserver.example.com' })
          end

          it { is_expected.to contain_class('sssd::config::ipa_domain') }
          it { is_expected.to contain_sssd__domain('ipa.example.com').with_cache_credentials(true) }
          it { is_expected.to contain_ini_subsetting('sssd /etc/sssd/sssd.conf [sssd] domains ipa.example.com') }
        end
      end

      # Site Hiera sits above the Compliance Engine layer, so an explicit value
      # wins over the profile.
      context 'with simp:defaults enforced and site overrides' do
        let(:hieradata) { 'simp_defaults_with_override' }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_tidy('/etc/sssd/conf.d') }

        # services_entries is deep merged, so one entry changes and the rest of
        # the profile's list stays.
        it { is_expected.to contain_ini_subsetting('sssd /etc/sssd/sssd.conf [sssd] services ssh').with_ensure('absent') }
        it { is_expected.to contain_ini_subsetting('sssd /etc/sssd/sssd.conf [sssd] services nss').with_ensure('present') }
        it { is_expected.to contain_service('sssd').with_ensure('running') }
      end

      # The deprecated Arrays replace the profile's lists, as they replaced the
      # module defaults in 10.x.
      context 'with simp:defaults enforced and the deprecated lists' do
        let(:hieradata) { 'simp_defaults_legacy_lists' }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_ini_subsetting('sssd /etc/sssd/sssd.conf [sssd] services ssh') }
        it { is_expected.not_to contain_ini_subsetting('sssd /etc/sssd/sssd.conf [sssd] services sudo') }
        it { is_expected.to contain_ini_subsetting('sssd /etc/sssd/sssd.conf [sssd] domains LDAP') }
        it { is_expected.not_to contain_ini_subsetting('sssd /etc/sssd/sssd.conf [sssd] domains LOCAL') }

        # sudo was dropped from the list, so the profile doesn't turn it on.
        it { is_expected.not_to contain_service('sssd-sudo.socket') }
        it { is_expected.not_to contain_systemd__dropin_file('00_sssd_sudo_user_group.conf') }
      end
    end
  end
end
