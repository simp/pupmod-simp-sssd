require 'spec_helper'

describe 'sssd::service::autofs' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_concat__fragment('sssd_autofs.service').without_content(%r(=\s*$)) }
      end
    end
  end
end
