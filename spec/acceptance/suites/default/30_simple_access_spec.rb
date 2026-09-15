require 'spec_helper_acceptance'

test_name 'sssd::domain simple access provider parameters'

describe 'sssd::domain with access_provider => simple' do
  let(:hiera) do
    {
      'simp_options::pki'           => true,
      'simp_options::pki::source'   => '/etc/pki/simp-testing/pki',
      'simp_options::ldap::uri'     => ['ldap://FIXME'],
      'simp_options::ldap::bind_dn' => 'cn=Administrator,cn=Users,dc=test,dc=case',
      'simp_options::ldap::base_dn' => 'dc=test,dc=case',
      'simp_options::ldap::bind_pw' => '<PASSWORD>',
      # This causes a lot of noise and reboots
      'sssd::auditd'                => false,
      'sssd::enable_files_domain'   => true,
      'sssd::domains'               => ['LDAP'],
    }
  end

  let(:manifest) do
    <<~EOF
      include 'sssd'

      sssd::domain { 'LDAP':
        description         => 'LDAP Users Domain',
        id_provider         => 'ldap',
        auth_provider       => 'ldap',
        access_provider     => 'simple',
        min_id              => 1000,
        simple_allow_users  => ['alice', 'bob'],
        simple_deny_users   => ['mallory'],
        simple_allow_groups => ['operators', 'wheel'],
        # Deliberately empty: an empty list must be omitted rather than
        # rendered as a bare 'simple_deny_groups =', since sssd-simple(5)
        # documents no behaviour for an empty value
        simple_deny_groups  => [],
      }
      sssd::provider::ldap { 'LDAP':
        ldap_user_gecos           => 'dn',
        ldap_id_mapping           => false,
        app_pki_key               => '/etc/pki/simp_apps/sssd/x509/private/host.test.case.pem',
        app_pki_cert              => '/etc/pki/simp_apps/sssd/x509/public/host.test.case.pub',
        ldap_default_authtok_type => 'password',
      }
    EOF
  end

  hosts.each do |host|
    context "on #{host}" do
      let(:domain_conf) { '/etc/sssd/conf.d/50_puppet_domain_LDAP.conf' }

      it 'applies with no errors' do
        set_hieradata_on(host, hiera)
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      it 'renders the simple access provider options as comma-separated lists' do
        conf = on(host, "cat #{domain_conf}").stdout
        expect(conf).to match(%r{^access_provider = simple$})
        expect(conf).to match(%r{^simple_allow_users = alice,bob$})
        expect(conf).to match(%r{^simple_deny_users = mallory$})
        expect(conf).to match(%r{^simple_allow_groups = operators,wheel$})
      end

      it 'omits simple_* options that are set to an empty list' do
        conf = on(host, "cat #{domain_conf}").stdout
        expect(conf).not_to match(%r{simple_deny_groups})
      end

      it 'is running sssd' do
        response = YAML.safe_load(on(host, %(puppet resource service sssd --to_yaml)).stdout.strip)
        expect(response['service']['sssd']['ensure']).to eq('running')
      end

      it 'passes sssd config validation' do
        # sssctl config-check validates option names against sssd's own
        # schema, catching a misspelled or misplaced option that unit tests
        # (which only pin the template output) can never see
        on(host, 'sssctl config-check')
      end
    end
  end
end
