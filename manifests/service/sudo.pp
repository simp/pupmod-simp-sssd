# This class sets up the [sudo] section of /etc/sssd.conf.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) man page.
#
# @param description
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param sudo_threshold
# @param sudo_timed
#
# @param custom_options
#   If defined, this hash will be used to create the service
#   section instead of the parameters.  You must provide all options
#   in the section you want to add.  Each entry in the hash will be
#   added as a simple init pair
#   key = value
#   under the section in the sssd.conf file.
#   No error checking will be performed.
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service::sudo (
  Optional[String]            $description        = undef,
  Optional[Sssd::Debuglevel]  $debug_level        = undef,
  Boolean                     $debug_timestamps   = true,
  Boolean                     $debug_microseconds = false,
  Boolean                     $sudo_timed         = false,
  Integer[1]                  $sudo_threshold     = 50,
  Optional[Hash]              $custom_options     = undef

) {
  if $custom_options {
    $_content = epp("${module_name}/service/custom_options.epp", {
        'service_name' => 'sudo',
        'options'      => $custom_options
      })
  } else {
    $_content = template("${module_name}/service/sudo.erb")
  }

  sssd::config::entry { 'puppet_service_sudo':
    content => $_content
  }

  $_override_content = @(END)
    # This is required due to the permissions on /var/lib/sss/db/config.ldb
    # This may be a regression in sssd
    [Service]
    User = root
    Group = root
    | END

  systemd::dropin_file { '00_sssd_sudo_user_group.conf':
    unit          => 'sssd-sudo.service',
    content       => $_override_content,
    daemon_reload => 'eager'
  }

  service { 'sssd-sudo.socket':
    enable  => true,
    require => [
      Sssd::Config::Entry['puppet_service_sudo'],
      Systemd::Dropin_file['00_sssd_sudo_user_group.conf']
    ],
    notify  => Class["${module_name}::service"]
  }
}
