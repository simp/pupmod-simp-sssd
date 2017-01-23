require 'spec_helper'

describe 'sssd::provider::krb5' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }

        let(:title) {'krb5_test_domain'}
        let(:params) {{
          :krb5_server => 'test.example.domain',
          :krb5_realm  => 'example.realm'
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_concat__fragment("sssd_#{title}_krb5_provider.domain").without_content(%r(=\s*$)) }
      end
    end
  end
end
