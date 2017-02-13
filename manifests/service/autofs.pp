# == Class: sssd::service::autofs
#
# This class sets up the [autofs] section of /etc/sssd.conf.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
#
# === Parameters Available in this Template:
# $autofs_negative_timeout
# $debug_level
# $debug_timestamps
# $debug_microseconds
# $description

class sssd::service::autofs {

  include '::sssd'

  # These varaibles are referenced inside the autofs template, and 
  # because we don't want to worry about scope inside of the template
  # we handle it here. 

  $autofs_negative_timeout = $sssd::autofs_negative_timeout
  $debug_level             = $sssd::debug_level
  $debug_timestamps        = $sssd::debug_timestamps
  $debug_microseconds      = $sssd::debug_microseconds
  $description             = $sssd::description

  concat::fragment { 'sssd_autofs.service':
    target  => $sssd::conf_file_path,
    content => template("${module_name}/service/autofs.erb")
  }
}
