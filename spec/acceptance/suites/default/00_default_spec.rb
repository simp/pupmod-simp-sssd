require 'spec_helper_acceptance'

test_name 'SSSD Base Tests'

describe 'sssd class' do

  clients = hosts_with_role(hosts,'client')

  let(:default_hieradata) {
    {
      'sssd::domains'             => [ 'LOCAL' ],
      'simp_options::pki'         => true,
      'simp_options::pki::source' => '/etc/pki/simp-testing/pki',
      # This causes a lot of noise and reboots
      'sssd::auditd'              => false
    }
  }

  let(:manifest) {
    <<-EOS
      class { 'sssd': }

      # To be used with the default_hieradata above
      sssd::domain { 'LOCAL':
        description   => 'Default Local domain',
        id_provider   => 'local',
        auth_provider => 'local'
      }

      sssd::provider::local { 'LOCAL': }
    EOS
  }

  clients.each do |client|
    context 'default parameters' do
      # Using puppet_apply as a helper
      it 'should work with no errors' do
        set_hieradata_on(client, default_hieradata)
        apply_manifest_on(client, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(client, manifest, :catch_changes => true)
      end

      it 'should be able to create an SSSD user' do
        on(client, %(sss_useradd simptest))
        # Make sure that we didn't have this in /etc/password for some reason
        on(client, %(grep -q '^simptest' /etc/passwd), :acceptable_exit_codes => [1])
        # Getent doesn't return anything on EL6!
        # Just have to try to make the user again and see if it fails.
        expect(
          on(client,
             %(sss_useradd simptest),
             :accept_all_exit_codes => true,
             :silent => true
            ).output
        ).to match(/already exists/)
      end
    end
  end
end
