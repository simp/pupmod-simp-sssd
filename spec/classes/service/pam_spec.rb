require 'spec_helper'

describe 'sssd::service::pam' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_sssd__config__entry('puppet_service_pam').without_content(%r{=\s*$}) }

        # SSSD 2.10 removed reconnection_retries from its schema -- sssctl
        # config-check rejects it outright -- so the module supplies it from
        # data/os/ only on the releases that still accept it.
        if os_facts[:os][:release][:major].to_i >= 10
          it { is_expected.to create_sssd__config__entry('puppet_service_pam').without_content(%r{^reconnection_retries}) }
        else
          it { is_expected.to create_sssd__config__entry('puppet_service_pam').with_content(%r{^reconnection_retries = 3$}) }
        end
      end
    end
  end
end
