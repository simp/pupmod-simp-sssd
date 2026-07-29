require 'spec_helper_acceptance'

test_name 'sssd::provider::krb5 multiple servers'

# Exercises the krb5 provider end to end: a single krb5_server/krb5_backup_server
# value and an array must both render as a comma-separated list in the generated
# drop-in (see #160).
describe 'sssd::provider::krb5 with multiple servers' do
  clients = hosts_with_role(hosts, 'client')

  let(:hieradata) do
    {
      'simp_options::pki'         => true,
      'simp_options::pki::source' => '/etc/pki/simp-testing/pki',
      # auditd causes a lot of noise and reboots
      'sssd::auditd'              => false,
      'sssd::enable_files_domain' => true,
      'sssd::domains'             => ['KRB5TEST'],
    }
  end

  let(:manifest) do
    <<~EOS
      include 'sssd'

      sssd::domain { 'KRB5TEST':
        id_provider    => 'proxy',
        proxy_lib_name => 'files',
        auth_provider  => 'krb5',
        min_id         => 1000,
      }

      sssd::provider::krb5 { 'KRB5TEST':
        krb5_realm         => 'EXAMPLE.COM',
        krb5_server        => ['kdc1.example.com', 'kdc2.example.com:88'],
        krb5_backup_server => 'kdc3.example.com',
      }
    EOS
  end

  clients.each do |client|
    context "on #{client}" do
      it 'applies the manifest' do
        set_hieradata_on(client, hieradata)
        apply_manifest_on(client, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(client, manifest, catch_changes: true)
      end

      it 'renders krb5_server and krb5_backup_server as comma-separated lists' do
        content = on(client, 'cat /etc/sssd/conf.d/50_puppet_provider_KRB5TEST_krb5.conf').stdout
        expect(content).to match(%r{^krb5_server = kdc1\.example\.com,kdc2\.example\.com:88$})
        expect(content).to match(%r{^krb5_backup_server = kdc3\.example\.com$})
      end
    end
  end
end
