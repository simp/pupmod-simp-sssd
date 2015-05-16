require 'spec_helper'

describe 'sssd::domain' do

  let(:title) {'test_domain'}
  let(:params) {{
    :id_provider => 'test_provider'
  }}

  it { should compile.with_all_deps }
  it { should contain_concat_fragment('sssd+test_domain#.domain') }
end
