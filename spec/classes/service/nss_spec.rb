require 'spec_helper'

describe 'sssd::service::nss' do

  it { should create_class('sssd::service::nss') }
  it { should compile.with_all_deps }
  it { should contain_concat_fragment('sssd+nss.service') }
end
