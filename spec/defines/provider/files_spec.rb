require 'spec_helper'

describe 'sssd::provider::files' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts }
        let(:title) {'test_files_provider'}

        if os_facts[:operatingsystemmajrelease] > '6'
          context('with default parameters') do
            it { is_expected.to compile.with_all_deps }

            it {
              expected_content = <<~EOM
                # sssd::provider::files
              EOM

              is_expected.to create_concat__fragment("sssd_#{title}_files.domain").with_content(expected_content)
             }
          end

          context('with explicit parameters') do
            let(:params) {{
              :passwd_files   => [ '/etc/passwd1', '/etc/passwd2'],
              :group_files   => [ '/etc/group1', '/etc/group2'],
            }}

            it { is_expected.to compile.with_all_deps }

            it {
              expected_content = <<~EOM
                # sssd::provider::files
                passwd_files = /etc/passwd1, /etc/passwd2
                group_files = /etc/group1, /etc/group2
              EOM

              is_expected.to create_concat__fragment("sssd_#{title}_files.domain").with_content(expected_content)
             }
          end
        else
          context('with default parameters') do
            it { is_expected.to compile.with_all_deps }

            it { is_expected.not_to create_concat__fragment("sssd_#{title}_files.domain") }
          end
        end
      end
    end
  end
end
