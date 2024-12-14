require 'spec_helper'

describe 'sssd::provider::files' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:title) { 'test_files_provider' }

        context('with default parameters') do
          it { is_expected.to compile.with_all_deps }

          it {
            expected = <<~EOM
              [domain/#{title}]
              # sssd::provider::files
              EOM

            is_expected.to create_sssd__config__entry("puppet_provider_#{title}_files").with_content(expected)
          }
        end

        context('with explicit parameters') do
          let(:params) do
            {
              passwd_files: [ '/etc/passwd1', '/etc/passwd2'],
           group_files: [ '/etc/group1', '/etc/group2'],
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            expected = <<~EOM
              [domain/#{title}]
              # sssd::provider::files
              passwd_files = /etc/passwd1, /etc/passwd2
              group_files = /etc/group1, /etc/group2
              EOM

            is_expected.to create_sssd__config__entry("puppet_provider_#{title}_files").with_content(expected)
          }
        end
      end
    end
  end
end
