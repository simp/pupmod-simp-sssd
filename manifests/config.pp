#
# Configuration class called from sssd.
#
# Sets up the ``[sssd]`` section of '/etc/sssd/sssd.conf', and,
# optionally, a domain section for the IPA domain to which the host
# is joined.  When the IPA domain is configured, the IPA domain is
# automatically added to ``$domains`` to generate the list of domains
# in the ``[sssd]`` section.
#
# @param authoritative
#   Set to `true` to purge unmanaged configuration files
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::config (
  Boolean $authoritative = pick(getvar("${module_name}::authoritative"), false)
){
  assert_private()

  include $module_name

  if ($sssd::auto_add_ipa_domain and $facts['ipa']) {
    # this host has joined an IPA domain
    $_domains = unique(concat($sssd::domains, $facts['ipa']['domain']))
    include 'sssd::config::ipa_domain'
  }
  else {
    $_domains = unique($sssd::domains)
  }

  $_debug_level           = $sssd::debug_level
  $_debug_timestamps      = $sssd::debug_timestamps
  $_debug_microseconds    = $sssd::debug_microseconds
  $_description           = $sssd::description
  $_enable_files_domain   = $sssd::enable_files_domain
  $_config_file_version   = $sssd::config_file_version
  $_services              = $sssd::services
  $_reconnection_retries  = $sssd::reconnection_retries
  $_re_expression         = $sssd::re_expression
  $_full_name_format      = $sssd::full_name_format
  $_try_inotify           = $sssd::try_inotify
  $_krb5_rcache_dir       = $sssd::krb5_rcache_dir
  $_user                  = $sssd::user
  $_default_domain_suffix = $sssd::default_domain_suffix
  $_override_space        = $sssd::override_space

  if $sssd::include_svc_config {
    $_services.each | $service | {
      include "sssd::service::${service}"
    }
  }

  file { '/etc/sssd':
    ensure => 'directory',
    mode   => 'go-rw'
  }

  file { '/etc/sssd/conf.d':
    ensure  => 'directory',
    purge   => $authoritative,
    recurse => true
  }

  unless $authoritative {
    tidy { '/etc/sssd/conf.d':
      matches => '*_puppet_*.conf',
      recurse => true
    }
  }

  file { '/etc/sssd/sssd.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template("${module_name}/sssd.conf.erb"),
    notify  => Class["${module_name}::service"]
  }
}
