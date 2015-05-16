require 'spec_helper'

describe 'sssd::provider::local' do

  let(:title) {'test_local_domain'}

  it { should compile.with_all_deps }
  it { should create_concat_fragment('sssd+test_local_domain#local_provider.domain') }
end
