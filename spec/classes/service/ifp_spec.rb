require 'spec_helper'

describe 'sssd::service::ifp' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts }

        context "with default params" do
          expected = <<-EOF
# sssd::service::ifp
[ifp]
debug_timestamps = true
debug_microseconds = false
EOF
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_concat__fragment('sssd_ifp.service').with_content(expected)}
        end

        context "with parameters" do
          let (:params){{
            'wildcard_limit' => 5,
            'allowed_uids'   => ["me","you"],
            'user_attributes' => ['x', 'y','z']
          }}
          expected = <<-EOF
# sssd::service::ifp
[ifp]
debug_timestamps = true
debug_microseconds = false
allow_uids = me, you
user_attributes = x, y, z
wildcard_limit = 5
EOF

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_concat__fragment('sssd_ifp.service').with_content(expected) }
        end
      end
    end
  end
end
