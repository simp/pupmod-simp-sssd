require 'spec_helper'

describe 'sssd::config::ipa_domain' do
  let(:pre_condition) do
    <<~PRECOND
      function assert_private {}
      include sssd
    PRECOND
  end

  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        context 'when joined to an IPA domain' do
          let(:facts) do
            os_facts.merge(
              ipa: {
                basedn: 'dc=example,dc=com',
                domain: 'ipa.example.com',
                realm: 'EXAMPLE.COM',
                server: 'ipaserver.example.com',
                connected: true
              },
            )
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('sssd::config::ipa_domain') }
          it do
            is_expected.to contain_sssd__domain('ipa.example.com')
              .with_description('IPA Domain ipa.example.com')
              .with_id_provider('ipa')
              .with_auth_provider('ipa')
              .with_chpass_provider('ipa')
              .with_access_provider('ipa')
              .with_sudo_provider('ipa')
              .with_autofs_provider('ipa')
              .with_min_id(1)
              .with_enumerate(false)
              .with_cache_credentials(true)
          end

          it do
            is_expected.to contain_sssd__provider__ipa('ipa.example.com')
              .with_ipa_domain('ipa.example.com')
              .with_ipa_server(['ipaserver.example.com'])
          end
        end

        context 'when not joined to an IPA domain' do
          let(:facts) do
            os_facts.merge(
              ipa: {
                basedn: 'dc=example,dc=com',
                domain: 'ipa.example.com',
                realm: 'EXAMPLE.COM',
                connected: false
              },
            )
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('sssd::config::ipa_domain') }
          it { is_expected.not_to contain_sssd__domain('ipa.example.com') }
          it { is_expected.not_to contain_sssd__provider__ipa('ipa.example.com') }
        end
      end
    end
  end
end
