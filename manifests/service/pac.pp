# == Class: sssd::service::pac
#
# This class sets up the [pac] section of /etc/sssd.conf.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
# == Parameters available in this template:
# allowed_uids
# debug_level
# debug_timestamps
# debug_microseconds
# description

class sssd::service::pac {

  include '::sssd'

  # These varaibles are referenced inside the autofs template, and
  # because we don't want to worry about scope inside of the template
  # we handle it here.

  $description        = $sssd::description
  $debug_level        = $sssd::debug_level
  $debug_timestamps   = $sssd::debug_timestamps
  $debug_microseconds = $sssd::debug_microseconds
  $allowed_uids       = $sssd::allowed_uids

  concat::fragment { 'sssd_pac.service':
    target  => $sssd::conf_file_path,
    content => template("${module_name}/service/pac.erb")
  }
}
