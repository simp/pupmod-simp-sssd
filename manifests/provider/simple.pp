# @summary
#
# Any parameter not explicitly documented directly follows the documentation
# from sssd-simples(5).
#
# @see sssd-simple(5)
#
# @param simple_allow_users
#   An explicit list of allowed users
#
# @param simple_deny_users
#   An explicit list of denied users
#
# @param simple_allow_groups
#   An explicit list of allowed groups
#
# @param simple_deny_groups
#   An explicit list of denied groups
#
define sssd::provider::simple (
  Optional[Array[String[1],1]] $simple_allow_users  = undef,
  Optional[Array[String[1],1]] $simple_deny_users   = undef,
  Optional[Array[String[1],1]] $simple_allow_groups = undef,
  Optional[Array[String[1],1]] $simple_deny_groups  = undef,
) {
  sssd::config::entry { "puppet_provider_${name}_simple":
    content => template("${module_name}/provider/simple.erb"),
  }
}
