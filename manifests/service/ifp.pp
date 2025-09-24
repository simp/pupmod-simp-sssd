# This class sets up the [ifp] section of /etc/sssd.conf.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) and sssd-ifp man pages.
#
# @param description
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param wildcard_limit
# @param allowed_uids
# @param user_attributes
#
# @param custom_options
#   If defined, this hash will be used to create the service
#   section instead of the parameters.  You must provide all options
#   in the section you want to add.  Each entry in the hash will be
#   added as a simple init pair
#    key = value
#   under the section in the sssd.conf file.
#   No error checking will be performed.
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service::ifp (
  Optional[String]            $description        = undef,
  Optional[Sssd::Debuglevel]  $debug_level        = undef,
  Boolean                     $debug_timestamps   = true,
  Boolean                     $debug_microseconds = false,
  Optional[Integer[0]]        $wildcard_limit     = undef,
  Optional[Array[String[1]]]  $allowed_uids       = undef,
  Optional[Array[String[1]]]  $user_attributes    = undef,
  Optional[Hash]              $custom_options     = undef,
) {
  if $custom_options {
    $_content = epp(
      "${module_name}/service/custom_options.epp",
      {
        'service_name' => 'ifp',
        'options'      => $custom_options,
      },
    )
  } else {
    # Build configuration content for the IFP service
    $_base_content = [
      '# sssd::service::ifp',
      '[ifp]',
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

    if $allowed_uids {
      $_allowed_uids_entries = ["allowed_uids = ${allowed_uids.join(', ')}"]
    } else {
      $_allowed_uids_entries = []
    }

    if $user_attributes {
      $_user_attributes_entries = ["user_attributes = ${user_attributes.join(', ')}"]
    } else {
      $_user_attributes_entries = []
    }

    if $wildcard_limit {
      $_wildcard_limit_entries = ["wildcard_limit = ${wildcard_limit}"]
    } else {
      $_wildcard_limit_entries = []
    }

    # Combine all configuration entries in the expected order
    $_all_entries = $_base_content + $_description_entries + $_debug_level_entries + $_debug_timestamps_entries + $_debug_microseconds_entries + $_allowed_uids_entries + $_user_attributes_entries + $_wildcard_limit_entries

    $_final_content = "${_all_entries.join("\n")}"

    $_content = epp(
      "${module_name}/content_only.epp",
      {
        'content' => $_final_content,
      },
    )
  }

  sssd::config::entry { 'puppet_service_ifp':
    content => $_content,
  }
}
