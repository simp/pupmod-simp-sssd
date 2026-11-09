require 'spec_helper'
require_relative '../../lib/sssd_spec_helpers'

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
            EOM

            expect(entry_content("puppet_provider_#{title}_files")).to content_matching(expected)
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
              passwd_files = /etc/passwd1, /etc/passwd2
              group_files = /etc/group1, /etc/group2
            EOM

            expect(entry_content("puppet_provider_#{title}_files")).to content_matching(expected)
          }
        end
      end
    end
  end
end
