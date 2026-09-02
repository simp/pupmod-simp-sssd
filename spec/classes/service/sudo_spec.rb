require 'spec_helper'

describe 'sssd::service::sudo' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_sssd__config__entry('puppet_service_sudo').without_content(%r{=\s*$}) }

        # The run-as-root drop-in is expected on every supported OS: EL8/9 via
        # data/os/RedHat-{8,9}.yaml and EL10 via data/os/RedHat-10.yaml.  The
        # expectation is deliberately not derived from the module's own Hiera
        # data, so a data regression fails this test.
        it {
          is_expected.to create_systemd__dropin_file('00_sssd_sudo_user_group.conf')
            .with_unit('sssd-sudo.service')
            .with_content(%r{ExecStartPre=-/bin/touch /var/log/sssd/sssd_sudo.log})
            .with_content(%r{ExecStartPre=-/bin/chown sssd:sssd /var/log/sssd/sssd_sudo.log})
            .with_content(%r{User=root})
            .with_content(%r{Group=root})
            .with_selinux_ignore_defaults(true)
        }

        context 'with manage_group_dropin_file disabled' do
          let(:hieradata) { 'no_group_dropin' }

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
