# == Class: sssd::service::sudo
#
# This class sets up the [sudo] section of /etc/sssd.conf.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
# == Parameters available to this template:
# debug_level
# debug_timestamps
# debug_microseconds
# description
# sudo_timed

class sssd::service::sudo {

  include '::sssd'

  # These varaibles are referenced inside the autofs template, and
  # because we don't want to worry about scope inside of the template
  # we handle it here.

  $description        = $sssd::description
  $debug_level        = $sssd::debug_level
  $debug_timestamps   = $sssd::debug_timestamps
  $debug_microseconds = $sssd::debug_microseconds
  $sudo_timed         = $sssd::sudo_timed

  concat::fragment { 'sssd_sudo.service':
    target  => $sssd::conf_file_path,
    content => template("${module_name}/service/sudo.erb")
  }
}
