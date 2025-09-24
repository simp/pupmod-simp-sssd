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
  Boolean $authoritative = pick(getvar("${module_name}::authoritative"), false),
) {
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
    mode   => 'go-rw',
  }

  file { '/etc/sssd/conf.d':
    ensure  => 'directory',
    purge   => $authoritative,
    recurse => true,
  }

  unless $authoritative {
    tidy { '/etc/sssd/conf.d':
      matches => '*_puppet_*.conf',
      recurse => true,
    }
  }

  # Build configuration lines in order (matching expected test output)
  # Services configuration - sudo has to be started by the socket
  $filtered_services = Array($_services) - ['sudo']
  $services_line = $_services.empty ? {
    true => [],
    false => $filtered_services.empty ? { true => [], false => ["services = ${filtered_services.join(',')}"] }
  }

  # Basic configuration
  $description_line = $_description ? { undef => [], default => ["description = ${_description}"] }

  # Domains configuration
  $domains_line = $_domains.empty ? { true => [], false => ["domains = ${Array($_domains).join(', ')}"] }

  # Required configuration parameters
  $config_file_version_line = ["config_file_version = ${_config_file_version}"]
  $reconnection_retries_line = ["reconnection_retries = ${_reconnection_retries}"]

  # Optional string parameters
  $re_expression_line = $_re_expression ? { undef => [], default => ["re_expression = ${_re_expression}"] }
  $full_name_format_line = $_full_name_format ? { undef => [], default => ["full_name_format = ${_full_name_format}"] }

  # Optional boolean parameters (special undef checking)
  $try_inotify_line = $_try_inotify ? { undef => [], default => ["try_inotify = ${_try_inotify}"] }
  $enable_files_domain_line = $_enable_files_domain ? { undef => [], default => ["enable_files_domain = ${_enable_files_domain}"] }

  # Optional directory and user parameters
  $krb5_rcache_dir_line = $_krb5_rcache_dir ? { undef => [], default => ["krb5_rcache_dir = ${_krb5_rcache_dir}"] }
  $user_line = $_user ? { undef => [], default => ["user = ${_user}"] }
  $default_domain_suffix_line = $_default_domain_suffix ? { undef => [], default => ["default_domain_suffix = ${_default_domain_suffix}"] }
  $override_space_line = $_override_space ? { undef => [], default => ["override_space = ${_override_space}"] }

  # Debug configuration
  $debug_level_line = $_debug_level ? { undef => [], default => ["debug_level = ${_debug_level}"] }
  $debug_timestamps_line = ["debug_timestamps = ${_debug_timestamps}"]
  $debug_microseconds_line = ["debug_microseconds = ${_debug_microseconds}"]

  # Combine all lines in order
  $config_lines = (
    $services_line +
    $description_line +
    $domains_line +
    $config_file_version_line +
    $reconnection_retries_line +
    $re_expression_line +
    $full_name_format_line +
    $try_inotify_line +
    $krb5_rcache_dir_line +
    $user_line +
    $default_domain_suffix_line +
    $override_space_line +
    $enable_files_domain_line +
    $debug_level_line +
    $debug_timestamps_line +
    $debug_microseconds_line
  )

  # Join all configuration lines
  $content = $config_lines.join("\n")

  file { '/etc/sssd/sssd.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp("${module_name}/content_only.epp", {
        'content' => "# sssd::config\n[sssd]\n${content}",
    }),
    notify  => Class["${module_name}::service"],
  }
}
