require 'spec_helper'

describe 'sssd::provider::krb5' do

  let(:title) {'krb5_test_domain'}
  let(:params) {{
    :krb5_server => 'test.example.domain',
    :krb5_realm  => 'example.realm'
  }}

  it { should compile.with_all_deps }
  it { should create_concat_fragment('sssd+krb5_test_domain#krb5_provider.domain') }
end
