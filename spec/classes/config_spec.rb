require 'spec_helper'

default_content = <<~EOM
  # sssd::config
  [sssd]
  services = nss,pam,ssh
  config_file_version = 2
  reconnection_retries = 3
  enable_files_domain = true
  debug_timestamps = true
  debug_microseconds = false
EOM

default_content_with_domains = <<~EOM
  # sssd::config
  [sssd]
  services = nss,pam,ssh
  domains = FILE, LDAP
  config_file_version = 2
  reconnection_retries = 3
  enable_files_domain = true
  debug_timestamps = true
  debug_microseconds = false
EOM
default_content_with_ipa_domain = default_content_with_domains.gsub('FILE, LDAP', 'FILE, LDAP, ipa.example.com')

default_content_plus_optional = <<~EOM
  # sssd::config
  [sssd]
  services = nss,pam,ssh
  description = sssd section description
  domains = FILE, LDAP
  config_file_version = 2
  reconnection_retries = 3
  re_expression = (.+)@(.+)
  full_name_format =  %1$s@%2$s
  try_inotify = true
  krb5_rcache_dir = __LIBKRB5_DEFAULTS__
  user = sssduser
  default_domain_suffix = example.com
  override_space = __
  enable_files_domain = false
  debug_level = 3
  debug_timestamps = true
  debug_microseconds = false
EOM

shared_examples_for 'a sssd::config' do |content|
  it { is_expected.to compile.with_all_deps }
  it {
    is_expected.to contain_file('/etc/sssd').with({
                                                    ensure: 'directory',
    mode: 'go-rw',
                                                  })
  }
  it {
    is_expected.to contain_file('/etc/sssd/sssd.conf').with({
                                                              owner: 'root',
      group: 'root',
      mode: '0600',
      content: content,
                                                            })
  }
end

# We have to test sssd::config via sssd, because sssd::config is
# private.  To take advantage of hooks built into puppet-rspec, the
# class described needs to be the class instantiated, i.e., sssd.
describe 'sssd' do
  let(:sssd_domains) { ['FILE', 'LDAP'] }
  let(:ipa_fact_joined) do
    {
      ipa: {
        domain: 'ipa.example.com',
        server: 'ipaserver.example.com',
      },
    }
  end

  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        context 'with default params' do
          let(:facts) { os_facts }
          let(:params) { { domains: [] } }

          # make sure no IPA domains are defined
          it { is_expected.not_to contain_class('sssd::config::ipa_domain') }
          it_behaves_like 'a sssd::config', default_content
        end

        context 'with domains defined used by sssd::config' do
          let(:params) { { domains: sssd_domains } }

          context 'when not joined to an IPA domain' do
            let(:facts) { os_facts }

            it_behaves_like 'a sssd::config', default_content_with_domains
            it { is_expected.not_to contain_class('sssd::config::ipa_domain') }
          end

          context 'when joined to an IPA domain' do
            let(:facts) { os_facts.merge(ipa_fact_joined) }

            it_behaves_like 'a sssd::config', default_content_with_ipa_domain
            it { is_expected.to contain_class('sssd::config::ipa_domain') }
          end
        end

        context 'with all optional sssd config parameters specified' do
          let(:params) do
            {
              domains: sssd_domains,
            debug_level: 3,
            description: 'sssd section description',
            re_expression: '(.+)@(.+)',
            enable_files_domain: false,
            full_name_format: ' %1$s@%2$s',
            try_inotify: true,
            krb5_rcache_dir: '__LIBKRB5_DEFAULTS__',
            user: 'sssduser',
            default_domain_suffix: 'example.com',
            override_space: '__',
            }
          end

          it_behaves_like 'a sssd::config', default_content_plus_optional
        end

        context 'when $::sssd::auto_add_ip_domain is false' do
          let(:params) do
            {
              domains: sssd_domains,
            auto_add_ipa_domain: false,
            }
          end

          context 'when not joined to an IPA domain' do
            it_behaves_like 'a sssd::config', default_content_with_domains
            it { is_expected.not_to contain_class('sssd::config::ipa_domain') }
          end

          context 'when joined to an IPA domain' do
            let(:facts) { os_facts.merge(ipa_fact_joined) }

            it_behaves_like 'a sssd::config', default_content_with_domains
            it { is_expected.not_to contain_class('sssd::config::ipa_domain') }
          end
        end

        context 'when $::sssd::domains has duplicate entries' do
          let(:params) { { domains: sssd_domains + sssd_domains } }

          # this verifies domain list is deduped in content
          it_behaves_like 'a sssd::config', default_content_with_domains
          it { is_expected.not_to contain_class('sssd::config::ipa_domain') }
        end

        context 'with service ifp requested' do
          let(:params) do
            {
              domains: sssd_domains,
           services: ['nss', 'pam', 'ifp'],
            }
          end

          if os_facts[:init_systems].member?('systemd')
            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_class('sssd::service::ifp') }
          else
            it 'fails because ifp is not available' do
              expect { is_expected.to raise_error(Puppet::Error, %r{SSSD service ifp is not valid on systems without systemd}) }
            end
          end
        end
      end
    end
  end
end
