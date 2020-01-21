require 'spec_helper'


describe 'sssd::service::nss' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts){ facts }
        context 'with defalt params' do

          it { is_expected.to create_class('sssd::service::nss') }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_concat__fragment('sssd_nss.service').without_content(%r(=\s*$)) }
        end
        context 'with custom options' do
          let(:hieradata){ 'service_nss'}

          it { is_expected.to create_class('sssd::service::nss') }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_concat__fragment('sssd_nss.service').with_content(<<-EOM.gsub(/^\s+/,''))
            #
            # This section is auto generate from a user supplied Hash
            [nss]
            filter_users = user1, user2
            override_shell = /bin/bash
            enum_cache_timeout = 5
            #
            EOM
          }
        end
      end
    end
  end
end
