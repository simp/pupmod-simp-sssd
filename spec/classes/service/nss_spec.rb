require 'spec_helper'

describe 'sssd::service::nss' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        context 'with defalt params' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd::service') }
          it { is_expected.to create_sssd__config__entry('puppet_service_nss').without_content(%r{=\s*$}) }
        end
        context 'with custom options' do
          let(:hieradata) { 'service_nss' }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd::service') }
          it {
            is_expected.to create_sssd__config__entry('puppet_service_nss')
              .with_content(<<~CONTENT)
                #
                # This section is auto generated from a user supplied Hash
                [nss]
                filter_users = user1, user2
                override_shell = /bin/bash
                enum_cache_timeout = 5
                #
              CONTENT
          }
        end
      end
    end
  end
end
