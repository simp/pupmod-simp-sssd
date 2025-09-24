# Define: sssd::provider::krb5
#
# This define sets up the 'krb5' provider section of a particular domain.
# $name should be the name of the associated domain in sssd.conf.
#
# See sssd-krb5.conf(5) for additional information.
#
# @param name
#   The name of the associated domain section in the configuration file.
#
# @param krb5_server
# @param krb5_realm
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param krb5_kpasswd
# @param krb5_ccachedir
# @param krb5_ccname_template
# @param krb5_auth_timeout
# @param krb5_validate
# @param krb5_keytab
# @param krb5_store_password_if_offline
# @param krb5_renewable_lifetime
# @param krb5_lifetime
# @param krb5_renew_interval
# @param krb5_use_fast
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
define sssd::provider::krb5 (
  String                                 $krb5_realm,
  Optional[Simplib::Host]                $krb5_server                    = undef,
  Optional[Sssd::DebugLevel]             $debug_level                    = undef,
  Boolean                                $debug_timestamps               = true,
  Boolean                                $debug_microseconds             = false,
  Optional[String]                       $krb5_kpasswd                   = undef,
  Optional[Stdlib::Absolutepath]         $krb5_ccachedir                 = undef,
  Optional[Stdlib::Absolutepath]         $krb5_ccname_template           = undef,
  Integer                                $krb5_auth_timeout              = 15,
  Boolean                                $krb5_validate                  = false,
  Optional[Stdlib::Absolutepath]         $krb5_keytab                    = undef,
  Boolean                                $krb5_store_password_if_offline = false,
  Optional[String]                       $krb5_renewable_lifetime        = undef,
  Optional[String]                       $krb5_lifetime                  = undef,
  Integer                                $krb5_renew_interval            = 0,
  Optional[Enum['never','try','demand']] $krb5_use_fast                  = undef,
) {
  # Build configuration content for the Kerberos provider
  $_content = [
    '# sssd::provider::krb5',
  ]

  # Add conditional parameters if defined in the correct order
  if $debug_level {
    $_debug_level_entries = ["debug_level = ${debug_level}"]
  } else {
    $_debug_level_entries = []
  }

  $_debug_timestamps_entries = $debug_timestamps ? {
    true  => ['debug_timestamps = true'],
    false => ['debug_timestamps = false'],
  }

  $_debug_microseconds_entries = $debug_microseconds ? {
    true  => ['debug_microseconds = true'],
    false => ['debug_microseconds = false'],
  }

  if $krb5_server {
    $_krb5_server_entries = ["krb5_server = ${krb5_server}"]
  } else {
    $_krb5_server_entries = []
  }

  $_krb5_realm_entries = ["krb5_realm = ${krb5_realm}"]

  if $krb5_kpasswd {
    $_krb5_kpasswd_entries = ["krb5_kpasswd = ${krb5_kpasswd}"]
  } else {
    $_krb5_kpasswd_entries = []
  }

  if $krb5_ccachedir {
    $_krb5_ccachedir_entries = ["krb5_ccachedir = ${krb5_ccachedir}"]
  } else {
    $_krb5_ccachedir_entries = []
  }

  if $krb5_ccname_template {
    $_krb5_ccname_template_entries = ["krb5_ccname_template = ${krb5_ccname_template}"]
  } else {
    $_krb5_ccname_template_entries = []
  }

  $_krb5_auth_timeout_entries = ["krb5_auth_timeout = ${krb5_auth_timeout}"]

  $_krb5_validate_entries = $krb5_validate ? {
    true  => ['krb5_validate = true'],
    false => ['krb5_validate = false'],
  }

  if $krb5_keytab {
    $_krb5_keytab_entries = ["krb5_keytab = ${krb5_keytab}"]
  } else {
    $_krb5_keytab_entries = []
  }

  $_krb5_store_password_if_offline_entries = $krb5_store_password_if_offline ? {
    true  => ['krb5_store_password_if_offline = true'],
    false => ['krb5_store_password_if_offline = false'],
  }

  if $krb5_renewable_lifetime {
    $_krb5_renewable_lifetime_entries = ["krb5_renewable_lifetime = ${krb5_renewable_lifetime}"]
  } else {
    $_krb5_renewable_lifetime_entries = []
  }

  if $krb5_lifetime {
    $_krb5_lifetime_entries = ["krb5_lifetime = ${krb5_lifetime}"]
  } else {
    $_krb5_lifetime_entries = []
  }

  $_krb5_renew_interval_entries = ["krb5_renew_interval = ${krb5_renew_interval}"]

  if $krb5_use_fast {
    $_krb5_use_fast_entries = ["krb5_use_fast = ${krb5_use_fast}"]
  } else {
    $_krb5_use_fast_entries = []
  }

  # Combine all configuration entries in the expected order
  $_all_entries = $_content + $_debug_level_entries + $_debug_timestamps_entries + $_debug_microseconds_entries + $_krb5_server_entries + $_krb5_realm_entries + $_krb5_kpasswd_entries + $_krb5_ccachedir_entries + $_krb5_ccname_template_entries + $_krb5_auth_timeout_entries + $_krb5_validate_entries + $_krb5_keytab_entries + $_krb5_store_password_if_offline_entries + $_krb5_renewable_lifetime_entries + $_krb5_lifetime_entries + $_krb5_renew_interval_entries + $_krb5_use_fast_entries

  $_final_content = "${_all_entries.join("\n")}"

  sssd::config::entry { "puppet_provider_${name}_krb5":
    content => epp(
      "${module_name}/generic.epp",
      {
        'title'   => "domain/${title}",
        'content' => $_final_content,
      },
    ),
  }
}
