require 'spec_helper'
require 'support/hiera_data_helper'

describe 'sssd::config::entry' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        let(:pre_condition) do
          <<~PRE_CONDITION
            function assert_private(){}
          PRE_CONDITION
        end

        let(:title) { 'test' }
        let(:params) { { content: 'foo' } }
        let(:hiera) { module_hiera_data(facts[:os]) }
        let(:group) { hiera.dig('sssd::config::sssd_config_file_params', 'group') }
        let(:mode)  { hiera.dig('sssd::config::sssd_config_file_params', 'mode') }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('sssd::config') }
        it { is_expected.to contain_class('sssd::service') }
        it {
          is_expected.to contain_file('/etc/sssd/conf.d/50_test.conf')
            .with_owner('root')
            .with_group(group)
            .with_mode(mode)
            .with_content('foo')
            .that_notifies('Class[sssd::service]')
        }
      end
    end
  end
end
