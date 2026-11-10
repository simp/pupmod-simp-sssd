require 'spec_helper'

describe 'sssd::service' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        let(:pre_condition) do
          <<~PRE_CONDITION
            function assert_private{ }
          PRE_CONDITION
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('sssd::service') }

        # The service is only managed when a site asks for it.
        it { is_expected.not_to contain_service('sssd') }

        context 'with ensure and enable set' do
          let(:params) { { ensure: 'running', enable: true } }

          it {
            is_expected.to contain_service('sssd')
              .with_ensure('running')
              .with_enable(true)
          }
        end

        context 'with only enable set' do
          let(:params) { { enable: true } }

          it { is_expected.to contain_service('sssd').with_enable(true).without_ensure }
        end
      end
    end
  end
end
