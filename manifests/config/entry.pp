# @summary Manage the settings of one section of an SSSD configuration file
#
# Each setting is edited in place with its own `ini_setting`, so only the
# settings passed in are managed. Anything else in the file, whether added by
# an administrator, another tool or an earlier Puppet run, is left alone.
#
# * A setting whose value is `undef` is not managed at all.
# * A setting whose value is `'absent'` is removed from the section.
# * Any other value is written as `key = value`; an Array is joined with
#   `', '`.
#
# The file itself is declared only to apply `sssd::config::sssd_config_file_params`
# (owner, group and mode), because SSSD refuses to start with an `sssd.conf`,
# and ignores a `conf.d` snippet, that has looser permissions than it expects.
# It is never given any content.
#
# @param name
#   A unique name that will be used for generating the target filename
#
#   Should not be fully qualified, unless `path` is set
#
# @param section
#   The INI section to manage, without the brackets, e.g. `nss` or
#   `domain/EXAMPLE.COM`
#
# @param settings
#   The settings to manage in `section`, as setting name to value
#
# @param order
#   The order in which the file should be processed
#
# @param path
#   The file to edit. Defaults to `/etc/sssd/conf.d/<order>_<name>.conf`.
#
define sssd::config::entry (
  String[1]                    $section,
  Hash[String[1], Any]         $settings,
  Integer[0]                   $order = 50,
  Optional[Stdlib::Absolutepath] $path = undef,
) {
  assert_private()

  if $path =~ Undef and $title =~ /\// {
    fail('$name cannot be fully qualified')
  }

  include "${module_name}::config"
  include "${module_name}::service"

  $_safe_filename = simplib::safe_filename("${order}_${title}.conf")

  $_path = $path ? {
    undef   => "/etc/sssd/conf.d/${_safe_filename}",
    default => $path,
  }

  # undef means "leave this setting alone", so it is dropped rather than
  # written as an empty value.
  $_settings = $settings.filter |$_setting, $_value| { $_value =~ NotUndef }

  unless empty($_settings) {
    # Several sections can live in the same file (sssd::custom_settings), so
    # the file may already have been declared by another entry.
    ensure_resource('file', $_path, $sssd::config::sssd_config_file_params + {
        'ensure'  => 'file',
        'require' => Package['sssd'],
    })

    $_settings.each |$_setting, $_value| {
      $_ini_value = $_value ? {
        'absent' => {
          'ensure' => 'absent',
        },
        Array    => {
          'ensure' => 'present',
          'value'  => $_value.join(', '),
        },
        default  => {
          'ensure' => 'present',
          'value'  => String($_value),
        },
      }

      ini_setting { "sssd ${_path} [${section}] ${_setting}":
        path              => $_path,
        section           => $section,
        setting           => $_setting,
        key_val_separator => ' = ',
        require           => [Package['sssd'], File[$_path]],
        notify            => Class["${module_name}::service"],
        *                 => $_ini_value,
      }
    }
  }
}
