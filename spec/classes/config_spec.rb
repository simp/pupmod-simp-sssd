require 'spec_helper'

default_content  = <<EOM

# sssd::config
[sssd]
domains = LOCAL, LDAP
services = nss, pam, ssh, sudo
config_file_version = 2
reconnection_retries = 3
debug_timestamps = true
debug_microseconds = false
EOM

default_content_with_ipa_domain = default_content.gsub(/LOCAL, LDAP/,'LOCAL, LDAP, ipa.example.com')

default_content_plus_optional = <<EOM

# sssd::config
[sssd]
description = sssd section description
domains = LOCAL, LDAP
services = nss, pam, ssh, sudo
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
  it { is_expected.to contain_class('sssd::config') }
  it { is_expected.to contain_concat('/etc/sssd/sssd.conf').with({
      :owner          => 'root',
      :group          => 'root',
      :mode           => '0600',
      :ensure_newline => true,
      :warn           => true,
      :notify         => 'Class[Sssd::Service]'
    })
  }

  it { is_expected.to contain_concat__fragment('sssd_main_config').with({
      :target  => '/etc/sssd/sssd.conf',
      :content => content
    })
  }
end

# We have to test sssd::config via sssd, because sssd::config is
# private.  To take advantage of hooks built into puppet-rspec, the
# class described needs to be the class instantiated, i.e., sssd.
describe 'sssd' do
  let(:sssd_domains) { ['LOCAL', 'LDAP'] }
  let(:ipa_fact_joined) {
    {
      :ipa => {
        :domain => 'ipa.example.com',
        :server => 'ipaserver.example.com',
      }
    }
  }

  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts){ os_facts }

        context 'with default parameters used by sssd::config' do
          let(:params) {{ :domains => sssd_domains }}

          context 'when not joined to an IPA domain' do
            let(:facts) { os_facts }

            it_should_behave_like 'a sssd::config', default_content
            it { is_expected.to_not contain_class('sssd::config::ipa_domain') }
          end

          context 'when joined to an IPA domain' do
            let(:facts) { os_facts.merge( ipa_fact_joined ) }

            it_should_behave_like 'a sssd::config', default_content_with_ipa_domain
            it { is_expected.to contain_class('sssd::config::ipa_domain') }
          end
        end

        context 'with no domains specified' do
          let(:params) {{ :domains => [] }}

          if os_facts[:os][:release][:major] <= '7'
            it 'should fail with no domain for el7 or before' do
              expect { should raise_error(Puppet::Error, /SSSD requires a domain be defined/)}
            end
          else
            it { is_expected.to compile.with_all_deps }
          end
        end

        context 'with all optional sssd config parameters specified' do
          let(:params) { {
            :domains               => sssd_domains,
            :debug_level           => 3,
            :description           => 'sssd section description',
            :re_expression         => '(.+)@(.+)',
            :enable_files_domain   => false,
            :full_name_format      => ' %1$s@%2$s',
            :try_inotify           =>  true,
            :krb5_rcache_dir       =>  '__LIBKRB5_DEFAULTS__',
            :user                  =>  'sssduser',
            :default_domain_suffix =>  'example.com',
            :override_space        =>  '__',
          } }

          it_should_behave_like 'a sssd::config', default_content_plus_optional
        end

        context 'when $::sssd::auto_add_ip_domain is false' do
          let(:params) { {
            :domains => sssd_domains,
            :auto_add_ipa_domain => false
          } }

          context 'when not joined to an IPA domain' do
            it_should_behave_like 'a sssd::config', default_content
            it { is_expected.to_not contain_class('sssd::config::ipa_domain') }
          end

          context 'when joined to an IPA domain' do
            let(:facts) { os_facts.merge( ipa_fact_joined ) }

            it_should_behave_like 'a sssd::config', default_content
            it { is_expected.to_not contain_class('sssd::config::ipa_domain') }
          end

        end

        context 'when $::sssd::domains has duplicate entries' do
          let(:params) {{ :domains => sssd_domains + sssd_domains }}

          # this verifies domain list is deduped in content
          it_should_behave_like 'a sssd::config', default_content
          it { is_expected.to_not contain_class('sssd::config::ipa_domain') }
        end

        context 'with service ifp requested' do
          let(:params) {{
            :domains  => sssd_domains,
            :services => ['nss','pam','ifp']
          }}
          if os_facts[:init_systems].member?('systemd')
            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_class('sssd::service::ifp') }
          else
            it 'should fail because ifp is not available ' do
              expect { should raise_error(Puppet::Error, /SSSD service ifp is not valid on systems without systemd/)}
            end
          end
        end

      end
    end
  end
end
