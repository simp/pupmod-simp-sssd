require 'spec_helper'

describe 'sssd::domain' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }

        let(:title) {'ldap'}
        let(:params) {{
          :id_provider => 'ldap'
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat__fragment("sssd_#{title}_.domain").without_content(%r(=\s*$)) }
      end
    end
  end
end
