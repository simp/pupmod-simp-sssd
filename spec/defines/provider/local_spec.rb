require 'spec_helper'

describe 'sssd::provider::local' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts }

        let(:title) {'test_local_domain'}

        it { is_expected.to compile.with_all_deps }

        it { is_expected.not_to create_concat__fragment("sssd_#{title}_local_provider.domain") }
      end
    end
  end
end
