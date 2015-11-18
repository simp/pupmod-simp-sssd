require 'spec_helper'

describe 'sssd::provider::local' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }

        let(:title) {'test_local_domain'}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_concat_fragment('sssd+test_local_domain#local_provider.domain').without_content(%r(=\s*$)) }
      end
    end
  end
end
