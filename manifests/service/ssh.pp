# == Class: sssd::service::ssh
#
# This class sets up the [ssh] section of /etc/sssd.conf.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
# == Parameters available to this template:
# debug_level
# debug_timestampts
# debug_microseconds
# description
# ssh_hash_known_hosts
# ssh_known_hosts_timeout
#

class sssd::service::ssh {

  include '::sssd'

  # These varaibles are referenced inside the autofs template, and
  # because we don't want to worry about scope inside of the template
  # we handle it here.

  $description             = $sssd::description
  $debug_level             = $sssd::debug_level
  $debug_timestamps        = $sssd::debug_timestamps
  $debug_microseconds      = $sssd::debug_microseconds
  $ssh_hash_known_hosts    = $sssd::ssh_hash_known_hosts
  $ssh_known_hosts_timeout = $sssd::ssh_known_hosts_timeout

  concat::fragment { 'sssd_ssh.service':
    target  => $sssd::conf_file_path,
    content => template("${module_name}/service/ssh.erb")
  }
}
