require 'spec_helper_acceptance'

test_name 'SSSD Base Tests'

describe 'sssd class' do

  clients = hosts_with_role(hosts,'client')

  let(:default_hieradata) {
    {
      'simp_options::pki'         => true,
      'simp_options::pki::source' => '/etc/pki/simp-testing/pki',
      # This causes a lot of noise and reboots
      'sssd::auditd'              => false
    }
  }

  let(:manifest) {
    <<-EOS
      include sssd
      EOS
  }

  let(:manifest_el7) {
    <<-EOS
    # sssctl does not work with just the implicat_file domain on el7 so we set
    # up a basic file provider here.
      class { 'sssd':
        domains => ['FILES']
      }

      # To be used with the default_hieradata above
     sssd::domain { 'FILES':
        description   => 'Default Local domain',
        id_provider   => 'files',
        auth_provider => 'files'
      }

      sssd::provider::files { 'FILES': }
    EOS
  }

  let(:manifest_el8) {
    <<-EOS
      # Note: IFP is not needed for SSSD to work
      # it gives a simple way to test if sssd is working
      class {'sssd':
        services      => ['nss','pam',"sudo", 'ssh', 'ifp']
      }
    EOS
  }


  clients.each do |client|
    context 'default parameters' do
      it 'manifest should work with no errors' do
        set_hieradata_on(client, default_hieradata)
        apply_manifest_on(client, manifest, :catch_failures => true)

        # idempotent

        apply_manifest_on(client, manifest, :catch_changes => true)
      end

      it 'should start sssd' do
        on(client, 'systemctl status sssd', :acceptable_exit_codes => [0])
      end

    end

    context 'with default files domain set up' do

      # To make sssctl work ifd needs to be turned on in EL8 and
      # a files domain needs to be created in EL7.
      os_release = fact_on(client, 'operatingsystemmajrelease')

      it 'manifest should work with no errors' do
        if os_release >= '8'
          _manifest = manifest_el8
        else
          _manifest = manifest_el7
        end
        set_hieradata_on(client, default_hieradata)
        apply_manifest_on(client, _manifest, :catch_failures => true)

        # idempotent

        apply_manifest_on(client, _manifest, :catch_changes => true)
      end

      it 'should get local user information' do
        on(client, 'useradd testuser --password "mypassword" -M -u 97979 -U')

        # Allow sssd to wake up and do whatever it does :-|
        sleep(10)

        result = on(client, 'sssctl user-checks testuser').stdout
        expect(result).to match(/.*- user id: 97979.*/)
      end

      if os_release >= '8'
        it 'should be running and have set up implicit_files domain' do
          result = on(client, 'sssctl domain-list; sssctl domain-list').stdout
          expect(result).to match(/.*implicit_files.*/)
        end
      end

      it 'should get local user information' do
        result = on(client, 'sssctl user-checks testuser 2>&1', :accept_all_exit_codes => true).stdout
        expect(result).to match(/.*- user id: 97979.*/)
      end
    end
  end
end
