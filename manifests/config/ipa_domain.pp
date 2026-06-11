# Configures SSSD for the IPA domain to which the host has joined.
#
# When ``sssd::force_ipa_domain`` is true, the IPA domain is configured even
# if the ``ipa`` fact reports ``connected => false`` or is missing entirely.
# In that case ``sssd::ipa_domain_name`` and ``sssd::ipa_servers`` are used
# to fill in any values the fact does not provide.
#
class sssd::config::ipa_domain {
  assert_private()

  if $facts.dig('ipa', 'connected') or $sssd::force_ipa_domain {
    $_ipa_domain = pick_default($facts.dig('ipa', 'domain'), $sssd::ipa_domain_name)
    $_fact_server = $facts.dig('ipa', 'server')
    $_ipa_servers = $_fact_server ? {
      undef   => $sssd::ipa_servers,
      default => [$_fact_server],
    }

    if empty($_ipa_domain) or empty($_ipa_servers) {
      fail('sssd::ipa_domain_name and sssd::ipa_servers must be set when sssd::force_ipa_domain is true and the ipa fact does not provide them')
    }

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
      ipa_server => $_ipa_servers,
    }
  }
}
