require 'spec_helper_acceptance'

test_name 'SSSD Base Tests'

describe 'sssd class' do
  clients = hosts_with_role(hosts, 'client')

  let(:default_hieradata) do
    {
      'simp_options::pki'         => true,
      'simp_options::pki::source' => '/etc/pki/simp-testing/pki',
      # This causes a lot of noise and reboots
      'sssd::auditd'              => false,
    }
  end

  let(:manifest) do
    <<~EOS
      include sssd
    EOS
  end

  let(:manifest_el8) do
    <<~EOS
      # Note: IFP is not needed for SSSD to work
      # it gives a simple way to test if sssd is working
      class {'sssd':
        services => ['nss','pam',"sudo", 'ssh', 'ifp'],
      }
    EOS
  end

  clients.each do |client|
    context 'default parameters' do
      it 'manifest should work with no errors' do
        set_hieradata_on(client, default_hieradata)
        apply_manifest_on(client, manifest, catch_failures: true)

        # idempotent

        apply_manifest_on(client, manifest, catch_changes: true)
      end

      it 'starts sssd' do
        on(client, 'systemctl status sssd', acceptable_exit_codes: [0])
      end
    end

    context 'with default files domain set up' do
      # To make sssctl work ifd needs to be turned on in EL8 and
      # a files domain needs to be created in EL7.
      os_release = fact_on(client, 'os.release.major')

      it 'manifest should work with no errors' do
        set_hieradata_on(client, default_hieradata)
        apply_manifest_on(client, manifest_el8, catch_failures: true)

        # idempotent

        apply_manifest_on(client, manifest_el8, catch_changes: true)
      end

      # rubocop:disable RSpec/RepeatedDescription
      it 'gets local user information' do
        on(client, 'useradd testuser --password "mypassword" -M -u 97979 -U')

        # Allow sssd to wake up and do whatever it does :-|
        sleep(10)

        result = on(client, 'sssctl user-checks testuser').stdout
        expect(result).to match(%r{.*- user id: 97979.*})
      end

      if os_release >= '8'
        it 'is running and have set up implicit_files domain' do
          result = on(client, 'sssctl domain-list; sssctl domain-list').stdout
          expect(result).to match(%r{.*implicit_files.*})
        end
      end

      it 'gets local user information' do
        result = on(client, 'sssctl user-checks testuser 2>&1', accept_all_exit_codes: true).stdout
        expect(result).to match(%r{.*- user id: 97979.*})
      end
      # rubocop:enable RSpec/RepeatedDescription
    end
  end
end
