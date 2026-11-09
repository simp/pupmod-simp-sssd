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
        let(:path) { '/etc/sssd/conf.d/50_test.conf' }
        let(:params) do
          {
            section: 'nss',
            settings: {
              'filter_users' => 'root',
              'memcache_timeout' => 300,
              'enum_cache_timeout' => :undef,
              'fallback_homedir' => 'absent',
              'vetoed_shells' => ['/bin/csh', '/bin/tcsh'],
            },
          }
        end
        # Explicit per-release expectations: EL10 configs are group-readable
        # by the (non-root) sssd daemon user; EL8/9 stay root-only.
        let(:el10)  { facts[:os][:release][:major].to_i >= 10 }
        let(:group) { el10 ? 'sssd' : 'root' }
        let(:mode)  { el10 ? '0640' : '0600' }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('sssd::config') }
        it { is_expected.to contain_class('sssd::service') }

        it 'applies the permissions SSSD requires, without managing the content' do
          is_expected.to contain_file(path)
            .with_ensure('file')
            .with_owner('root')
            .with_group(group)
            .with_mode(mode)
            .without_content
            .that_requires('Package[sssd]')
        end

        it 'edits each setting in place' do
          is_expected.to contain_ini_setting("sssd #{path} [nss] filter_users")
            .with_ensure('present')
            .with_path(path)
            .with_section('nss')
            .with_setting('filter_users')
            .with_value('root')
            .with_key_val_separator(' = ')
            .that_requires(['Package[sssd]', "File[#{path}]"])
            .that_notifies('Class[sssd::service]')
        end

        it { is_expected.to contain_ini_setting("sssd #{path} [nss] memcache_timeout").with_value('300') }
        it { is_expected.to contain_ini_setting("sssd #{path} [nss] vetoed_shells").with_value('/bin/csh, /bin/tcsh') }

        it 'leaves an undef setting alone' do
          is_expected.not_to contain_ini_setting("sssd #{path} [nss] enum_cache_timeout")
        end

        it 'removes an absent setting' do
          is_expected.to contain_ini_setting("sssd #{path} [nss] fallback_homedir")
            .with_ensure('absent')
            .without_value
        end

        context 'with every setting undef' do
          let(:params) { { section: 'nss', settings: { 'filter_users' => :undef } } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.not_to contain_file(path) }
          it { is_expected.to have_ini_setting_resource_count(0) }
        end

        context 'with an explicit path' do
          let(:title) { 'puppet_custom certmap/EXAMPLE.COM/rule1' }
          let(:params) { { section: 'certmap/EXAMPLE.COM/rule1', settings: { 'priority' => 10 }, path: '/etc/sssd/conf.d/99_custom.conf' } }

          it { is_expected.to contain_file('/etc/sssd/conf.d/99_custom.conf') }
          it { is_expected.to contain_ini_setting('sssd /etc/sssd/conf.d/99_custom.conf [certmap/EXAMPLE.COM/rule1] priority').with_value('10') }
        end

        context 'with a fully qualified name' do
          let(:title) { 'foo/bar' }

          it { is_expected.to compile.and_raise_error(%r{cannot be fully qualified}) }
        end
      end
    end
  end
end
