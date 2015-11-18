require 'spec_helper'

describe 'sssd::service::nss' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }

        it { is_expected.to create_class('sssd::service::nss') }
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat_fragment('sssd+nss.service').without_content(%r(=\s*$)) }
      end
    end
  end
end
