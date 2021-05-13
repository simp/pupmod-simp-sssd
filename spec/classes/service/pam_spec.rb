require 'spec_helper'

describe 'sssd::service::pam' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_sssd__config__entry('puppet_service_pam').without_content(%r(=\s*$)) }
      end
    end
  end
end
