require 'spec_helper'

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
        # Explicit per-release expectations: EL10 configs are group-readable
        # by the (non-root) sssd daemon user; EL8/9 stay root-only.
        let(:el10)  { facts[:os][:release][:major].to_i >= 10 }
        let(:group) { el10 ? 'sssd' : 'root' }
        let(:mode)  { el10 ? '0640' : '0600' }

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
