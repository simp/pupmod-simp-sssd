require 'spec_helper'

describe 'sssd::service::sudo' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_sssd__config__entry('puppet_service_sudo').without_content(%r{=\s*$}) }

        # The run-as-root drop-in works around the EL8/9 split where sssd
        # itself runs as root (root-owned config.ldb) but the socket-activated
        # responder does not (SSSD/sssd#5781).  On EL10 the whole stack runs
        # as sssd and the shipped unit sets CapabilityBoundingSet= (empty), so
        # a User=root override cannot read the sssd-owned 0600 config.ldb and
        # the responder crash-loops — the drop-in must stay OFF there.  These
        # expectations are deliberately not derived from the module's own
        # Hiera data, so a data regression fails this test.
        if os_facts[:os][:release][:major].to_i >= 10
          it { is_expected.not_to create_systemd__dropin_file('00_sssd_sudo_user_group.conf') }
        else
          it {
            is_expected.to create_systemd__dropin_file('00_sssd_sudo_user_group.conf')
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
          it { is_expected.not_to create_systemd__dropin_file('00_sssd_sudo_user_group.conf') }
        end

        it {
          is_expected.to create_service('sssd-sudo.socket')
            .with_enable(true)
            .that_requires('Sssd::Config::Entry[puppet_service_sudo]')
            .that_notifies('Class[sssd::service]')
        }
      end
    end
  end
end
