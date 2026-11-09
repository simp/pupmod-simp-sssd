require 'spec_helper'
require_relative '../../lib/sssd_spec_helpers'

describe 'sssd::service::sudo' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        context 'with default params' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd::service') }

          # Every setting is left alone until its parameter is set.
          it { is_expected.to have_ini_setting_resource_count(0) }
          it { is_expected.not_to contain_file('/etc/sssd/conf.d/50_puppet_service_sudo.conf') }
        end

        context 'with parameters' do
          let(:params) do
            {
              debug_timestamps: true,
              debug_microseconds: false,
              sudo_threshold: 50,
              sudo_timed: false,
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/etc/sssd/conf.d/50_puppet_service_sudo.conf').that_requires('Package[sssd]') }
          it { expect(entry_content('puppet_service_sudo')).to eq(<<~CONTENT) }
            [sudo]
            debug_timestamps = true
            debug_microseconds = false
            sudo_threshold = 50
            sudo_timed = false
            CONTENT
        end

        context 'with a setting set to absent' do
          let(:params) { { debug_level: 'absent' } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_ini_setting('sssd /etc/sssd/conf.d/50_puppet_service_sudo.conf [sudo] debug_level').with_ensure('absent') }
        end

        context 'with custom_options' do
          let(:params) do
            {
              debug_level: 5,
              custom_options: { 'key1' => 'value1', 'key2' => 'absent' },
            }
          end

          it { is_expected.to compile.with_all_deps }

          # The custom options are managed instead of the typed parameters.
          it { is_expected.to contain_ini_setting('sssd /etc/sssd/conf.d/50_puppet_service_sudo.conf [sudo] key1').with_value('value1') }
          it { is_expected.to contain_ini_setting('sssd /etc/sssd/conf.d/50_puppet_service_sudo.conf [sudo] key2').with_ensure('absent') }
          it { is_expected.not_to contain_ini_setting('sssd /etc/sssd/conf.d/50_puppet_service_sudo.conf [sudo] debug_level') }
        end

        it { is_expected.not_to create_systemd__dropin_file('00_sssd_sudo_user_group.conf') }
        it { is_expected.not_to create_service('sssd-sudo.socket') }

        # The run-as-root drop-in works around the EL8/9 split where sssd
        # itself runs as root (root-owned config.ldb) but the socket-activated
        # responder does not (SSSD/sssd#5781).  On EL10 the whole stack runs
        # as sssd and the shipped unit sets CapabilityBoundingSet= (empty), so
        # a User=root override cannot read the sssd-owned 0600 config.ldb and
        # the responder crash-loops; the simp:defaults profile only turns it on
        # for EL8/9.
        context 'with manage_group_dropin_file enabled' do
          let(:params) { { manage_group_dropin_file: true } }

          it {
            is_expected.to create_systemd__dropin_file('00_sssd_sudo_user_group.conf')
              .with_ensure('present')
              .with_unit('sssd-sudo.service')
              .with_content(%r{ExecStartPre=-/bin/touch /var/log/sssd/sssd_sudo.log})
              .with_content(%r{ExecStartPre=-/bin/chown sssd:sssd /var/log/sssd/sssd_sudo.log})
              .with_content(%r{User=root})
              .with_content(%r{Group=root})
              .with_selinux_ignore_defaults(true)
          }
        end

        context 'with manage_group_dropin_file disabled' do
          let(:hieradata) { 'sssd__service__sudo_no_dropin' }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_systemd__dropin_file('00_sssd_sudo_user_group.conf').with_ensure('absent') }
        end

        context 'with socket_enable set' do
          let(:params) { { socket_enable: true, manage_group_dropin_file: true } }

          it {
            is_expected.to create_service('sssd-sudo.socket')
              .with_enable(true)
              .without_ensure
              .that_requires('Package[sssd]')
              .that_requires('Sssd::Config::Entry[puppet_service_sudo]')
              .that_requires('Systemd::Dropin_file[00_sssd_sudo_user_group.conf]')
              .that_notifies('Class[sssd::service]')
          }
        end
      end
    end
  end
end
