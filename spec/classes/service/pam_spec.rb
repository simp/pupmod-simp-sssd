require 'spec_helper'

describe 'sssd::service::pam' do

  it { should compile.with_all_deps }
  it { should create_concat_fragment('sssd+pam.service') }
end
