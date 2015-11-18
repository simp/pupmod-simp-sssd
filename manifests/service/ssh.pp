# == Class: sssd::service::ssh
#
# This class sets up the [ssh] section of /etc/sssd.conf.
#
# == Authors
#
# == Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
class sssd::service::ssh (
  $description = '',
  $debug_level = '',
  $debug_timestamps = '',
  $ssh_hash_known_hosts = true,
  $ssh_known_hosts_timeout = ''
) {

  validate_string($description)
  validate_string($debug_level)
  unless empty($debug_timestamps) { validate_bool($debug_timestamps) }
  unless empty($debug_microseconds) { validate_bool($debug_microseconds) }
  validate_bool($ssh_hash_known_hosts)
  unless empty($ssh_known_hosts_timeout) { validate_integer($ssh_known_hosts_timeout) }

  concat_fragment { 'sssd+ssh.service':
    content => template('sssd/service/ssh.erb')
  }
}
