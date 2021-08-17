require 'spec_helper'

describe 'sssd::service::sudo' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_sssd__config__entry('puppet_service_sudo').without_content(%r(=\s*$)) }
        it {
          is_expected.to create_systemd__dropin_file('00_sssd_sudo_user_group.conf')
            .with_unit('sssd-sudo.service')
            .with_content(/User = root/)
            .with_content(/Group = root/)
            .with_daemon_reload('eager')
            .with_selinux_ignore_defaults(true)
        }
        it {
          is_expected.to create_service('sssd-sudo.socket')
            .with_enable(true)
            .that_requires('Sssd::Config::Entry[puppet_service_sudo]')
            .that_requires('Systemd::Dropin_file[00_sssd_sudo_user_group.conf]')
            .that_notifies('Class[sssd::service]')
        }
      end
    end
  end
end
