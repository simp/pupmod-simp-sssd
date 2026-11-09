require 'spec_helper'
require_relative '../lib/sssd_spec_helpers'

# The entries of the `services` or `domains` setting in sssd.conf, as
# entry => ensure, from the ini_subsetting resources that edit them.
def sssd_list(setting)
  subsettings = catalogue.resources.select do |r|
    r.type == 'Ini_subsetting' && r[:path] == '/etc/sssd/sssd.conf' && r[:setting] == setting
  end

  subsettings.to_h { |r| [r[:subsetting], r[:ensure]] }
end

# We have to test sssd::config via sssd, because sssd::config is
# private.  To take advantage of hooks built into puppet-rspec, the
# class described needs to be the class instantiated, i.e., sssd.
describe 'sssd' do
  let(:ipa_fact_joined) do
    {
      ipa: {
        connected: true,
        domain: 'ipa.example.com',
        server: 'ipaserver.example.com',
      },
    }
  end

  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        # The permissions are stated explicitly per OS release instead of
        # being derived from the module's own Hiera data, so a data regression
        # fails these tests.  On EL10 sssd runs as sssd:sssd and the config
        # must be group-readable; EL8/9 run sssd as root and keep the config
        # root-only.
        let(:el10)  { facts[:os][:release][:major].to_i >= 10 }
        let(:group) { el10 ? 'sssd' : 'root' }
        let(:mode)  { el10 ? '0640' : '0600' }

        context 'with default params' do
          it { is_expected.to compile.with_all_deps }

          # Defined types (Sssd::Config::Entry) are containers; only the
          # resources they declare reach the node.
          it 'declares nothing but the packages' do
            types = catalogue.resources.map(&:type).uniq.reject { |t| t.include?('::') }
            expect(types - ['Class', 'Stage', 'Node']).to contain_exactly('Package')
          end

          it { is_expected.not_to contain_file('/etc/sssd') }
          it { is_expected.not_to contain_file('/etc/sssd/conf.d') }
          it { is_expected.not_to contain_file('/etc/sssd/sssd.conf') }
          it { is_expected.not_to contain_tidy('/etc/sssd/conf.d') }
          it { is_expected.not_to contain_service('sssd') }
          it { is_expected.not_to contain_sssd__domain('LOCAL') }
          it { is_expected.not_to contain_class('sssd::service::nss') }
          it { is_expected.not_to contain_class('sssd::config::ipa_domain') }

          context 'when joined to an IPA domain' do
            let(:facts) { os_facts.merge(ipa_fact_joined) }

            it { is_expected.not_to contain_class('sssd::config::ipa_domain') }
            it { is_expected.to have_ini_subsetting_resource_count(0) }
          end

          # On a fresh node the post-install sssd_version fact doesn't exist
          # yet, and the noop preview must still compile.
          context 'without the sssd_version fact' do
            let(:facts) { os_facts.reject { |fact, _| fact.to_s == 'sssd_version' } }

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to have_ini_setting_resource_count(0) }
          end
        end

        context 'with simp:defaults-like settings and without the sssd_version fact' do
          let(:facts) { os_facts.reject { |fact, _| fact.to_s == 'sssd_version' } }
          let(:params) { { services_entries: { 'nss' => {}, 'sudo' => {} }, debug_timestamps: true } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_ini_setting('sssd /etc/sssd/sssd.conf [sssd] debug_timestamps').that_requires('Package[sssd]') }
        end

        context 'with every [sssd] setting specified' do
          let(:params) do
            {
              debug_level: 3,
              debug_timestamps: true,
              debug_microseconds: false,
              description: 'sssd section description',
              config_file_version: 2,
              reconnection_retries: 3,
              re_expression: '(.+)@(.+)',
              enable_files_domain: false,
              full_name_format: ' %1$s@%2$s',
              try_inotify: true,
              krb5_rcache_dir: '__LIBKRB5_DEFAULTS__',
              user: 'sssduser',
              default_domain_suffix: 'example.com',
              override_space: '__',
              certificate_verification: 'ocsp_dgst=sha1, no_ocsp',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it 'applies the permissions SSSD requires, without managing the content' do
            is_expected.to contain_file('/etc/sssd/sssd.conf')
              .with_owner('root')
              .with_group(group)
              .with_mode(mode)
              .without_content
          end

          it {
            expect(entry_content('sssd')).to eq(<<~EOM)
              [sssd]
              description = sssd section description
              config_file_version = 2
              reconnection_retries = 3
              re_expression = (.+)@(.+)
              full_name_format =  %1$s@%2$s
              try_inotify = true
              krb5_rcache_dir = __LIBKRB5_DEFAULTS__
              user = sssduser
              default_domain_suffix = example.com
              override_space = __
              certificate_verification = ocsp_dgst=sha1, no_ocsp
              enable_files_domain = false
              debug_level = 3
              debug_timestamps = true
              debug_microseconds = false
            EOM
          }

          it {
            is_expected.to contain_ini_setting('sssd /etc/sssd/sssd.conf [sssd] debug_level')
              .with_path('/etc/sssd/sssd.conf')
              .with_section('sssd')
              .with_value('3')
              .that_requires('Package[sssd]')
              .that_notifies('Class[sssd::service]')
          }
        end

        context 'with a setting set to absent' do
          let(:params) { { config_file_version: 'absent' } }

          it { is_expected.to contain_ini_setting('sssd /etc/sssd/sssd.conf [sssd] config_file_version').with_ensure('absent') }
          it { is_expected.not_to contain_ini_setting('sssd /etc/sssd/sssd.conf [sssd] debug_level') }
        end

        context 'with services_entries' do
          let(:params) do
            {
              services_entries: {
                'nss'  => {},
                'pam'  => { 'ensure' => 'present' },
                'sudo' => {},
                'ssh'  => { 'ensure' => 'absent' },
              },
            }
          end

          it { is_expected.to compile.with_all_deps }

          # sudo is socket-activated, so it is never listed.
          it { expect(sssd_list('services')).to eq('nss' => 'present', 'pam' => 'present', 'ssh' => 'absent') }

          it {
            is_expected.to contain_ini_subsetting('sssd /etc/sssd/sssd.conf [sssd] services nss')
              .with_subsetting_separator(',')
              .with_key_val_separator(' = ')
              .with_use_exact_match(true)
              .that_requires(['Package[sssd]', 'File[/etc/sssd/sssd.conf]'])
              .that_notifies('Class[sssd::service]')
          }

          it { is_expected.to contain_file('/etc/sssd/sssd.conf').with_mode(mode) }
          it { is_expected.to contain_class('sssd::service::nss') }
          it { is_expected.to contain_class('sssd::service::pam') }
          it { is_expected.to contain_class('sssd::service::sudo') }
          it { is_expected.not_to contain_class('sssd::service::ssh') }

          context 'with include_svc_config disabled' do
            let(:params) { super().merge(include_svc_config: false) }

            it { is_expected.not_to contain_class('sssd::service::nss') }
            it { expect(sssd_list('services')).to include('nss' => 'present') }
          end

          context 'and the deprecated services Array' do
            let(:params) { super().merge(services: ['ifp', 'ssh']) }

            # The Array replaced the module's default list before 11.0.0, so
            # it is used instead of the Hash.
            it { is_expected.to compile.with_all_deps }
            it { expect(sssd_list('services')).to eq('ifp' => 'present', 'ssh' => 'present') }
            it { is_expected.to contain_class('sssd::service::ifp') }
            it { is_expected.to contain_class('sssd::service::ssh') }
            it { is_expected.not_to contain_class('sssd::service::nss') }
          end
        end

        context 'with domains_entries and the deprecated domains Array' do
          let(:params) do
            {
              domains_entries: { 'FILE' => {}, 'OLD' => { 'ensure' => 'absent' } },
              domains: ['LDAP', 'LDAP', '--FILE'],
            }
          end

          # The Array is used instead of the Hash, and a knockout entry in it
          # removes the domain.
          it { is_expected.to compile.with_all_deps }
          it { expect(sssd_list('domains')).to eq('LDAP' => 'present', 'FILE' => 'absent') }

          context 'without the Array' do
            let(:params) { super().merge(domains: []) }

            it { expect(sssd_list('domains')).to eq('FILE' => 'present', 'OLD' => 'absent') }
            it { is_expected.to contain_ini_subsetting('sssd /etc/sssd/sssd.conf [sssd] domains OLD').with_ensure('absent') }
          end
          it { is_expected.not_to contain_class('sssd::config::ipa_domain') }
        end

        context 'with auto_add_ipa_domain' do
          let(:params) { { auto_add_ipa_domain: true, domains_entries: { 'LDAP' => {} } } }

          context 'when joined to an IPA domain' do
            let(:facts) { os_facts.merge(ipa_fact_joined) }

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_class('sssd::config::ipa_domain') }
            it { expect(sssd_list('domains')).to eq('LDAP' => 'present', 'ipa.example.com' => 'present') }
          end

          context 'when not joined to an IPA domain' do
            it { is_expected.not_to contain_class('sssd::config::ipa_domain') }
            it { expect(sssd_list('domains')).to eq('LDAP' => 'present') }
          end

          context 'with the ipa fact present but not connected' do
            let(:facts) { os_facts.merge(ipa: ipa_fact_joined[:ipa].merge(connected: false)) }

            # The domain must not be added to the domains list nor
            # sssd::config::ipa_domain included, otherwise sssd.conf would
            # reference an unconfigured domain.
            it { is_expected.not_to contain_class('sssd::config::ipa_domain') }
            it { expect(sssd_list('domains')).to eq('LDAP' => 'present') }
          end

          context 'with force_ipa_domain and no ipa fact' do
            let(:params) do
              super().merge(
                force_ipa_domain: true,
                ipa_domain_name: 'ipa.example.com',
                ipa_servers: ['ipaserver.example.com'],
              )
            end

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_class('sssd::config::ipa_domain') }
            it { expect(sssd_list('domains')).to include('ipa.example.com' => 'present') }
          end

          context 'with force_ipa_domain and no domain name' do
            let(:params) { super().merge(force_ipa_domain: true) }

            it { is_expected.to compile.and_raise_error(%r{IPA domain must be provided}) }
          end
        end

        context 'with manage_base_domain' do
          let(:hieradata) { 'sssd_manage_base_domain' }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_sssd__domain('LOCAL').with_id_provider('proxy').with_proxy_lib_name('files') }

          # A domain the module declares itself is always listed.
          it { expect(sssd_list('domains')).to include('LOCAL' => 'present') }
        end

        context 'with sssd_config_dir_mode' do
          let(:hieradata) { 'sssd_config_dir_mode' }

          it { is_expected.to contain_file('/etc/sssd').with_ensure('directory').with_mode('go-rw') }
          it {
            is_expected.to contain_file('/etc/sssd/conf.d')
              .with_ensure('directory')
              .with_mode('go-rw')
              .with_recurse(true)
              .with_purge(false)
          }
          it { is_expected.not_to contain_tidy('/etc/sssd/conf.d') }
        end

        context 'with authoritative' do
          let(:params) { { authoritative: true, tidy_puppet_snippets: true } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.not_to contain_file('/etc/sssd') }
          it { is_expected.to contain_file('/etc/sssd/conf.d').with_purge(true).with_recurse(true).without_mode }

          # The purge removes them anyway.
          it { is_expected.not_to contain_tidy('/etc/sssd/conf.d') }
        end

        context 'with tidy_puppet_snippets' do
          let(:params) { { tidy_puppet_snippets: true } }

          it { is_expected.to contain_tidy('/etc/sssd/conf.d').with_matches('*_puppet_*.conf').with_recurse(true) }
          it { is_expected.not_to contain_file('/etc/sssd/conf.d') }
        end
      end
    end
  end
end
