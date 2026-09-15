require 'spec_helper'

describe 'sssd::to_ini' do
  context 'with a single section' do
    it 'renders the section header and one line per setting' do
      is_expected.to run.with_params(
        'nss' => {
          'filter_users'     => 'root',
          'memcache_timeout' => 300,
        },
      ).and_return("[nss]\nfilter_users = root\nmemcache_timeout = 300")
    end
  end

  context 'with multiple sections' do
    it 'preserves Hash insertion order' do
      is_expected.to run.with_params(
        'pam'                => { 'pam_verbosity' => 1 },
        'domain/EXAMPLE.COM' => { 'id_provider' => 'ldap' },
      ).and_return("[pam]\npam_verbosity = 1\n[domain/EXAMPLE.COM]\nid_provider = ldap")
    end
  end

  context 'with value types that need conversion' do
    it 'renders Arrays as comma-separated lists' do
      is_expected.to run.with_params(
        'nss' => { 'filter_users' => ['root', 'named'] },
      ).and_return("[nss]\nfilter_users = root, named")
    end

    it 'renders Booleans in the same case as the rest of the module' do
      is_expected.to run.with_params(
        'nss' => { 'filter_users_in_groups' => false },
      ).and_return("[nss]\nfilter_users_in_groups = false")
    end
  end

  context 'with undef settings' do
    it 'omits them' do
      is_expected.to run.with_params(
        'nss' => {
          'filter_users'     => 'root',
          'memcache_timeout' => :undef,
        },
      ).and_return("[nss]\nfilter_users = root")
    end

    it 'omits a section that has no remaining settings' do
      is_expected.to run.with_params('nss' => { 'filter_users' => :undef }).and_return('')
    end

    it 'omits only the empty section, not the ones around it' do
      is_expected.to run.with_params(
        'pam'                => { 'pam_verbosity' => 1 },
        'domain/EXAMPLE.COM' => { 'id_provider' => :undef },
        'nss'                => { 'filter_users' => 'root' },
      ).and_return("[pam]\npam_verbosity = 1\n[nss]\nfilter_users = root")
    end
  end

  context 'with an empty section Hash' do
    it 'does not emit a bare section header' do
      is_expected.to run.with_params('domain/EXAMPLE.COM' => {}).and_return('')
    end
  end

  context 'with an empty String value' do
    it 'renders the bare assignment SSSD reads as "explicitly unset"' do
      is_expected.to run.with_params(
        'domain/EXAMPLE.COM' => { 'ldap_account_expire_policy' => '' },
      ).and_return("[domain/EXAMPLE.COM]\nldap_account_expire_policy = ")
    end
  end

  context 'with an empty Hash' do
    it { is_expected.to run.with_params({}).and_return('') }
  end

  context 'with input the type rejects' do
    it 'rejects a section name containing brackets' do
      is_expected.to run.with_params('[nss]' => { 'filter_users' => 'root' })
                        .and_raise_error(ArgumentError, %r{expects a match for Sssd::IniSectionName})
    end

    it 'rejects a value containing a newline' do
      is_expected.to run.with_params('nss' => { 'filter_users' => "root\n[pam]\npam_verbosity = 9" })
                        .and_raise_error(ArgumentError, %r{parameter 'settings' entry 'nss' entry 'filter_users'})
    end

    it 'rejects an Array element containing the list separator' do
      is_expected.to run.with_params('nss' => { 'filter_users' => ['root,named'] })
                        .and_raise_error(ArgumentError, %r{parameter 'settings' entry 'nss' entry 'filter_users'})
    end

    it 'rejects a setting name containing a space' do
      is_expected.to run.with_params('nss' => { 'filter users' => 'root' })
                        .and_raise_error(ArgumentError, %r{parameter 'settings' entry 'nss' key of entry 'filter users'})
    end
  end
end
