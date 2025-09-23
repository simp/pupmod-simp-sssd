# @summary Configures the 'files' id_provider section of a particular domain.
#
# NOTE: This defined type has no effect on SSSD < 1.16.0
#
# $name should be the name of the associated domain in sssd.conf.
#
# This is not necessary for the file provider unless you want to use
# files other then /etc/passwd and /etc/group
#
# See man 'sssd-files' for additional information.
#
# @param name
#   The name of the associated domain section in the configuration file.
#
# @param passwd_files
# @param group_files
#
# @author https://github.com/simp/pupmod-simp-sssd/graphs/contributors
#
define sssd::provider::files (
  Optional[Array[Stdlib::Absolutepath]] $passwd_files = undef,
  Optional[Array[Stdlib::Absolutepath]] $group_files  = undef,
) {
  sssd::config::entry { "puppet_provider_${name}_files":
    content => epp(
      "${module_name}/provider/files.epp",
      {
        'passwd_files' => $passwd_files,
        'group_files'  => $group_files,
      }
    ),
  }
}
