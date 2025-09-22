require 'spec_helper'

describe 'sssd::service::ifp' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts }

        context "with default params" do
          expected = <<~EXPECTED
            # sssd::service::ifp
            [ifp]
            debug_timestamps = true
            debug_microseconds = false
            EXPECTED

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd::service') }
          it { is_expected.to create_sssd__config__entry('puppet_service_ifp').with_content(expected) }
        end

        context "with parameters" do
          let (:params){{
            'wildcard_limit' => 5,
            'allowed_uids'   => ["me","you"],
            'user_attributes' => ['x', 'y','z']
          }}

          expected = <<~EXPECTED
            # sssd::service::ifp
            [ifp]
            debug_timestamps = true
            debug_microseconds = false
            allowed_uids = me, you
            user_attributes = x, y, z
            wildcard_limit = 5
            EXPECTED

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd::service') }
          it { is_expected.to create_sssd__config__entry('puppet_service_ifp').with_content(expected) }
        end
      end
    end
  end
end
