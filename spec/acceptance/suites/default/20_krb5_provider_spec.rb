require 'spec_helper_acceptance'

test_name 'sssd::provider::krb5 with multiple servers'

describe 'sssd::provider::krb5' do
  hosts.each do |host|
    let(:default_hieradata) do
      {
        'simp_options::pki'         => true,
        'simp_options::pki::source' => '/etc/pki/simp-testing/pki',
        'sssd::auditd'              => false,
      }
    end

    context 'with single krb5_server (backwards compatibility)' do
      let(:manifest) do
        <<~EOS
          include sssd

          sssd::domain { 'krb5_test':
            description     => 'KRB5 Test Domain',
            id_provider     => 'krb5',
            auth_provider   => 'krb5',
            chpass_provider => 'krb5',
          }

          sssd::provider::krb5 { 'krb5_test':
            krb5_server => 'kdc.example.com',
            krb5_realm  => 'EXAMPLE.COM',
          }
        EOS
      end

      it 'applies manifest with single krb5_server' do
        set_hieradata_on(host, default_hieradata)
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      it 'generates correct sssd.conf with single server' do
        result = on(host, 'cat /etc/sssd/sssd.conf').stdout
        expect(result).to match(%r{krb5_server = kdc\.example\.com})
        expect(result).to match(%r{krb5_realm = EXAMPLE\.COM})
      end
    end

    context 'with multiple krb5_servers' do
      let(:manifest) do
        <<~EOS
          include sssd

          sssd::domain { 'krb5_multi':
            description     => 'KRB5 Multi Server Domain',
            id_provider     => 'krb5',
            auth_provider   => 'krb5',
            chpass_provider => 'krb5',
          }

          sssd::provider::krb5 { 'krb5_multi':
            krb5_server => ['kdc1.example.com', 'kdc2.example.com', '192.168.1.100'],
            krb5_realm  => 'EXAMPLE.COM',
          }
        EOS
      end

      it 'applies manifest with multiple krb5_servers' do
        set_hieradata_on(host, default_hieradata)
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      it 'generates correct sssd.conf with multiple servers' do
        result = on(host, 'cat /etc/sssd/sssd.conf').stdout
        expect(result).to match(%r{krb5_server = kdc1\.example\.com,kdc2\.example\.com,192\.168\.1\.100})
        expect(result).to match(%r{krb5_realm = EXAMPLE\.COM})
      end
    end

    context 'with array containing single krb5_server' do
      let(:manifest) do
        <<~EOS
          include sssd

          sssd::domain { 'krb5_array':
            description     => 'KRB5 Array Domain',
            id_provider     => 'krb5',
            auth_provider   => 'krb5',
            chpass_provider => 'krb5',
          }

          sssd::provider::krb5 { 'krb5_array':
            krb5_server => ['kdc.example.com'],
            krb5_realm  => 'EXAMPLE.COM',
          }
        EOS
      end

      it 'applies manifest with array of single krb5_server' do
        set_hieradata_on(host, default_hieradata)
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      it 'generates correct sssd.conf with single server from array' do
        result = on(host, 'cat /etc/sssd/sssd.conf').stdout
        expect(result).to match(%r{krb5_server = kdc\.example\.com})
        expect(result).to match(%r{krb5_realm = EXAMPLE\.COM})
      end
    end
  end
end
