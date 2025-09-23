# @summary Add an entry to the /etc/sssd/conf.d directory
#
# @param name
#   A unique name that will be used for generating the target filename
#
#   Should not be fully qualified
#
# @param content
#   The content of the target file
# @param order
#   The order in which the file should be processed
#
define sssd::config::entry (
  String     $content,
  Integer[0] $order = 50,
) {
  assert_private()

  if $title =~ /\// {
    fail('$name cannot be fully qualified')
  }

  include "${module_name}::config"
  include "${module_name}::service"

  $_safe_filename = simplib::safe_filename("${order}_${title}.conf")

  file { "/etc/sssd/conf.d/${_safe_filename}":
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $content,
    notify  => Class["${module_name}::service"],
  }
}
