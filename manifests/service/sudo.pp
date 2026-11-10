# This class sets up the [sudo] section of /etc/sssd/sssd.conf.
#
# The class parameters map directly to SSSD configuration.  Full
# documentation of these configuration options can be found in the
# sssd.conf(5) man page.
#
# Each parameter that maps to a setting follows three states: `undef` (the
# default) leaves the setting alone, a value sets it, and `'absent'` removes
# it.  The class manages nothing until one of them is set.
#
# @param description
# @param debug_level
# @param debug_timestamps
# @param debug_microseconds
# @param sudo_threshold
# @param sudo_timed
#
# @param custom_options
#   If defined, these settings are managed in the section *instead of* the
#   ones from the other parameters, which are then ignored.  Each entry is
#   edited in place as `key = value` in the generated `/etc/sssd/conf.d/`
#   drop-in file; a value of `'absent'` removes that setting.
#   No error checking will be performed.
#
# @param manage_group_dropin_file
#   Manage a systemd drop-in file that runs the sssd-sudo service as root
#
#   * `true` creates it, `false` removes it, and `undef` leaves it alone.
#   * Needed on EL8 and EL9, where the `simp:defaults` profile turns it on.
#   * `true` is ignored while sudo is turned off; see `socket_enable`.
#
# @param socket_enable
#   The `enable` state of the `sssd-sudo.socket` unit, which starts the sudo
#   responder
#
#   * Unset, the socket is not managed, except while `sudo` is in the
#     deprecated `sssd::services` Array, which enables it as 10.x did.
#   * `true` is ignored while sudo is turned off: when `sudo` is `absent` in
#     `sssd::services_entries`, or the deprecated `sssd::services` is set
#     without it.  `false` is always applied.
#   * While this enables the socket, `sudo` is removed from the `services`
#     line, because the socket refuses to start while it is listed.
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
class sssd::service::sudo (
  Optional[String]                                    $description              = undef,
  Optional[Variant[Sssd::DebugLevel, Enum['absent']]] $debug_level              = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_timestamps         = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $debug_microseconds       = undef,
  Optional[Variant[Boolean, Enum['absent']]]          $sudo_timed               = undef,
  Optional[Variant[Integer[1], Enum['absent']]]       $sudo_threshold           = undef,
  Optional[Hash]                                      $custom_options           = undef,
  Optional[Boolean]                                   $manage_group_dropin_file = undef,
  Optional[Boolean]                                   $socket_enable            = undef,
) {
  $_settings = $custom_options ? {
    undef   => {
      'description'        => $description,
      'debug_level'        => $debug_level,
      'debug_timestamps'   => $debug_timestamps,
      'debug_microseconds' => $debug_microseconds,
      'sudo_threshold'     => $sudo_threshold,
      'sudo_timed'         => $sudo_timed,
    },
    default => $custom_options,
  }

  sssd::config::entry { 'puppet_service_sudo':
    section  => 'sudo',
    settings => $_settings,
  }

  $_override_content = @(END)
    # This is required due to the permissions on /var/lib/sss/db/config.ldb
    # This may be a regression in sssd
    [Service]
    ExecStartPre=-/bin/touch /var/log/sssd/sssd_sudo.log
    ExecStartPre=-/bin/chown sssd:sssd /var/log/sssd/sssd_sudo.log
    User=root
    Group=root
    | END

  # sudo is turned off when the services list says so, so that enforcing
  # simp:defaults doesn't start a responder a site dropped from its list.
  include 'sssd'
  $_sudo_on = sssd::sudo_on($sssd::services_entries, $sssd::services)

  # sudo in the deprecated services Array keeps its 10.x meaning: the
  # responder is socket-activated, so the socket is enabled unless
  # socket_enable says otherwise.  sssd::config leaves it off the services
  # line.
  $_legacy_sudo = $sssd::services =~ NotUndef and 'sudo' in $sssd::services
  $_socket_enable = ($socket_enable =~ Undef and $_legacy_sudo) ? {
    true    => true,
    default => $socket_enable,
  }

  $_dropin = $_sudo_on ? {
    true    => $manage_group_dropin_file,
    default => $manage_group_dropin_file ? { true => undef, default => $manage_group_dropin_file },
  }
  $_socket = $_sudo_on ? {
    true    => $_socket_enable,
    default => $_socket_enable ? { true => undef, default => $_socket_enable },
  }

  if $_dropin =~ NotUndef {
    systemd::dropin_file { '00_sssd_sudo_user_group.conf':
      ensure                  => $_dropin.bool2str('present', 'absent'),
      unit                    => 'sssd-sudo.service',
      content                 => $_override_content,
      selinux_ignore_defaults => true,
    }
  }

  if $_socket =~ NotUndef {
    service { 'sssd-sudo.socket':
      enable  => $_socket,
      require => [Package['sssd'], Sssd::Config::Entry['puppet_service_sudo']],
      notify  => Class["${module_name}::service"],
    }

    if $_dropin {
      Systemd::Dropin_file['00_sssd_sudo_user_group.conf'] -> Service['sssd-sudo.socket']
    }
  }
}
