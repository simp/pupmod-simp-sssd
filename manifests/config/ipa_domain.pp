# Configures SSSD for the IPA domain to which the host has joined
#
class sssd::config::ipa_domain {
  assert_private()

  if $facts.dig('ipa', 'connected') {
    # this host has joined an IPA domain
    $_ipa_domain = $facts['ipa']['domain']
    $_ipa_server = $facts['ipa']['server']

    sssd::domain { $_ipa_domain:
      description       => "IPA Domain ${_ipa_domain}",
      id_provider       => 'ipa',
      auth_provider     => 'ipa',
      chpass_provider   => 'ipa',
      access_provider   => 'ipa',
      sudo_provider     => 'ipa',
      autofs_provider   => 'ipa',
      min_id            => $sssd::min_id,
      enumerate         => $sssd::enumerate_users,
      cache_credentials => $sssd::cache_credentials,
    }

    sssd::provider::ipa { $_ipa_domain:
      ipa_domain => $_ipa_domain,
      ipa_server => [$_ipa_server],
    }
  }
}
