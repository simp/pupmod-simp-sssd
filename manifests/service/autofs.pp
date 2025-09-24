# This class sets up the [autofs] section of /etc/sssd.conf.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) man page.
#
# @param description
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param autofs_negative_timeout
#
# @param custom_options
#   If defined, this hash will be used to create the service
#   section instead of the parameters.  You must provide all options
#   in the section you want to add.  Each entry in the hash will be
#   added as a simple init pair key = value under the section in
#   the sssd.conf file.
#   No error checking will be performed.
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service::autofs (
  Optional[String]            $description              = undef,
  Optional[Sssd::DebugLevel]  $debug_level              = undef,
  Boolean                     $debug_timestamps         = true,
  Boolean                     $debug_microseconds       = false,
  Optional[Integer]           $autofs_negative_timeout  = undef,
  Optional[Hash]              $custom_options           = undef,
) {
  if $custom_options {
    $_content = epp(
      "${module_name}/service/custom_options.epp",
      {
        'service_name' => 'autofs',
        'options'      => $custom_options,
      },
    )
  } else {
    # Build configuration content for the AutoFS service
    $_base_content = [
      '# sssd::service::autofs',
      '[autofs]',
    ]

    # Add conditional parameters if defined
    if $description {
      $_description_entries = ["description = ${description}"]
    } else {
      $_description_entries = []
    }

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

    if $autofs_negative_timeout {
      $_autofs_negative_timeout_entries = ["autofs_negative_timeout = ${autofs_negative_timeout}"]
    } else {
      $_autofs_negative_timeout_entries = []
    }

    # Combine all configuration entries in the expected order
    $_all_entries = $_base_content + $_description_entries + $_debug_level_entries + $_debug_timestamps_entries + $_debug_microseconds_entries + $_autofs_negative_timeout_entries

    $_final_content = $_all_entries.join("\n")

    $_content = epp(
      "${module_name}/service/autofs.epp",
      {
        'content' => $_final_content,
      },
    )
  }

  sssd::config::entry { 'puppet_service_autofs':
    content => $_content,
  }
}
