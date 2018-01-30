#
# Configuration class called from sssd.
#
# Sets up the ``[sssd]`` section of '/etc/sssd/sssd.conf', and,
# optionally, a domain section for the IPA domain to which the host
# is joined.  When the IPA domain is configured, the IPA domain is
# automatically added to ``$domains`` to generate the list of domains
# in the ``[sssd]`` section.
#
class sssd::config {
  assert_private()
  concat { '/etc/sssd/sssd.conf':
    owner          => 'root',
    group          => 'root',
    mode           => '0600',
    ensure_newline => true,
    warn           => true,
    notify         => Class['sssd::service']
  }

  if ($sssd::auto_add_ipa_domain and $facts['ipa']) {
    # this host has joined an IPA domain
    $_domains = unique(concat($::sssd::domains, $facts['ipa']['domain']))
    include 'sssd::config::ipa_domain'
  }
  else {
    $_domains = unique($::sssd::domains)
  }

  $_debug_level           = $::sssd::debug_level
  $_debug_timestamps      = $::sssd::debug_timestamps
  $_debug_microseconds    = $::sssd::debug_microseconds
  $_description           = $::sssd::description
  $_config_file_version   = $::sssd::config_file_version
  $_services              = $::sssd::services
  $_reconnection_retries  = $::sssd::reconnection_retries
  $_re_expression         = $::sssd::re_expression
  $_full_name_format      = $::sssd::full_name_format
  $_try_inotify           = $::sssd::try_inotify
  $_krb5_rcache_dir       = $::sssd::krb5_rcache_dir
  $_user                  = $::sssd::user
  $_default_domain_suffix = $::sssd::default_domain_suffix
  $_override_space        = $::sssd::override_space

  concat::fragment { 'sssd_main_config':
    target  => '/etc/sssd/sssd.conf',
    content => template("${module_name}/sssd.conf.erb")
  }
}
