require 'spec_helper'

describe 'sssd::service' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts }

        let(:pre_condition){
          <<~PRE_CONDITION
            function assert_private{ }
            PRE_CONDITION
        }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('sssd::service') }
        it {
          is_expected.to contain_service('sssd')
            .with_ensure(true)
            .with_enable(true)
        }

        context 'with an unsupported version of sssd' do
          let(:facts){
            os_facts.merge({:sssd_version => '1.14.0'})
          }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('sssd::service') }
          it {
            is_expected.to contain_service('sssd')
              .with_ensure(false)
              .with_enable(false)
          }
        end
      end
    end
  end
end
