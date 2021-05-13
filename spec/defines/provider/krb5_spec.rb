require 'spec_helper'

describe 'sssd::provider::krb5' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts }

        let(:title) {'krb5_test_domain'}
        let(:params) {{
          :krb5_server => 'test.example.domain',
          :krb5_realm  => 'example.realm'
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_sssd__config__entry("puppet_provider_#{title}_krb5").without_content(%r(=\s*$)) }
      end
    end
  end
end
