require 'spec_helper'

shared_examples_for 'a sssd::config::ipa_domain' do
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_class('sssd::config::ipa_domain') }
  it { is_expected.to contain_sssd__domain('ipa.example.com').with({
      :description       => 'IPA Domain ipa.example.com',
      :id_provider       => 'ipa',
      :auth_provider     => 'ipa',
      :chpass_provider   => 'ipa',
      :access_provider   => 'ipa',
      :sudo_provider     => 'ipa',
      :autofs_provider   => 'ipa',
      :min_id            => 1,
      :enumerate         => false,
      :cache_credentials => true
    })
  }

  it { is_expected.to contain_sssd__provider__ipa('ipa.example.com').with({
      :ipa_domain => 'ipa.example.com',
      :ipa_server => [ 'ipaserver.example.com' ]
    })
  }
end

# We have to test sssd::config::ipa_config via sssd, because
# sssd::config:ipa_config is private.  To take advantage of hooks built
# into puppet-rspec, the class described needs to be the class
# instantiated, i.e., sssd.
describe 'sssd' do
  let(:ipa_fact_joined) {
    {
      :ipa => {
        :domain => 'ipa.example.com',
        :server => 'ipaserver.example.com',
      }
    }
  }

  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        context 'when joined to an IPA domain' do
          let(:facts) { os_facts.merge(ipa_fact_joined) }
          let(:params) {{ :domains => ['ipa.example.com'] }}

          it_should_behave_like 'a sssd::config::ipa_domain'
        end
      end
    end
  end
end
