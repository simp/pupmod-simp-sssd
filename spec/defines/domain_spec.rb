require 'spec_helper'

describe 'sssd::domain' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts }

        let(:title) {'ldap'}
        let(:params) {{
          :id_provider => 'ldap'
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_sssd__config__entry("puppet_domain_#{title}").without_content(%r(=\s*$)) }
      end
    end
  end
end
