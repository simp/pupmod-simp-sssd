# == Class: sssd
#
# This class allows you to install and configure SSSD.
# It will forcefully disable nscd which consequently prevents you from using an
# nscd module at the same time, which is the correct behavior.  ---
#
# == Authors
#
# @author Trevor Vaughan <mailto:tvaughan@onyxpoint.com>
#
# == Parameters:
#
# === Installation / Configuration Parameters ===
# The following parameters allow you to control the installation and
# configuration of the sssd package.
#
# @param client_package_name [Optional[String]]
#   The name of the sssd client package (varies by OS)
#   Default value: 'sssd-client'
#
# @param client_package_version [Optional[String]]
#   The version of the sssd client package
#   Default value: 'latest'
#
# @param conf_file_path [Stdlib::Absoultepath]
#   The path to the configuration file for sssd.
#   Default value: '/etc/sssd/sssd.conf'
#
# @param conf_dir_owner [Optional[String]]
#   The owner of the sssd configuration directory.
#   Default value: 'sssd'
#     On RHEL-6 and before, and CentOS-6 and before: 'root'
#
# @param conf_dir_path [Stdlib::Absolutepath]
#   The sssd configuration directory.
#   Default value: '/etc/sssd/'
#
# @param install_user_tools [Boolean]
#   Determines if this module should install the sssd tools package
#   Default value: true
#
# @param nscd_service_name [Optional[String]]
#   The name of the nscd service. sssd cannot coexist with nscd, so this
#   module will disable it. This is intended behavior.
#   Default value: 'nscd'
#
# @param package_name [Optional[String]]
#   The name of the sssd package that will be installed.
#   Default value: 'sssd'
#
# @param package_version [Optional[String]]
#   The version of the package to be installed.
#   Default value: 'latest'
#
# @param sssd_service_path [Stdlib::Absolutepath]
#   The path to the service executable for the sssd service
#   Default value: '/etc/init.d/sssd'
#
# @param sssd_service_name [Optional[String]]
#   The name of the sssd service
#   Default value: 'sssd'
#
# @param tools_package_name [Optional[String]]
#   The name of the sssd tools package
#   Default value: 'sssd-tools'
#
# @param tools_package_version [Optional[String]]
#   The version of the tools package to be installed
#   Default value: 'latest'
#
# === SIMP Integration Parameters ===
# These parameters control the integration of the sssd module with
# other SIMP modules and services. The variables that are being set here are
# resolved using simplib::lookup, a special function that helps SIMP
# integrate existing modules. Setting these values in hiera will supersede
# simplib::lookup, and is not recommended.
#
# @param app_pki_dir [Stdlib::Absolutepath]
#   Controls the basepath of the $app_pki_key, $app_pki_cert,
#   $app_pki_ca, $app_pki_ca_dir, and $app_pki_crl parameters.
#   Default value: '/etc/pki/simp_apps/sssd/x509'
#
# @param auditd [Boolean]
#   Determines if auditd is enabled at a global level. If it is,
#   this module will take steps to ensure sssd and auditd work
#   together.
#   Default value: false
#
# @param pki [[Boolean,Enum['simp']]]
#   Determines if pki is enabled at a global level. If it is,
#   this module will take steps to ensure that sssd and pki work
#   together.
#   Default value: false
#
# @param app_pki_cert_source [Stdlib::Absolutepath]
#   Determines the location that pki will look for certificates.
#   Default value: '/etc/pki/simp/x509'
#
# === Template Parameters ===
# The following parameters are exposed here, but are only used inside of
# templates that configure the sections of the sssd configuration file.
# Futher information about which parameters are available to each section
# of the configuration file can be found inside the manifests that control
# the corresponding sections. (ex: manifests/service/pam.pp)
#
# @param allowed_uids [Array[String]]
#   Sets the allowed_uids field in the pac section of the sssd config file.
#   Default value: []
#   Used in: templates/service/pac.erb
#
# @param autofs_negative_timeout [Optional[Integer]]
#   Sets autofs_negative_timeout in the autofs section of the sssd config file
#   Default value: null
#   Used in: templates/service/autofs.erb
#
# @param command [Optional[String]]
#   Sets command in the nss and pam sections of the sssd config file
#   Default value: null
#   Used in: templates/service/nss.erb
#            templates/service/pam.erb
#
# @param config_file_version [Integer]
#   Sets config_file_version in the sssd section of the sssd config file
#   Default value: 2
#   Used in: templates/sssd.conf.erb
#
# @param debug_level [Optional[Sssd::DebugLevel]]
#   Sets debug_level in each section of the config file.
#   Default value: null
#   Used in: templates/domain.erb
#            templates/provider/krb5.erb
#            templates/provider/ldap.erb
#            templates/provider/local.erb
#            templates/service/autofs.erb
#            templates/service/nss.erb
#            templates/service/pac.erb
#            templates/service/pam.erb
#            templates/service/ssh.erb
#            templates/service/sudo.erb
#            templates/sssd.conf.erb
#
# @param debug_timestamps [Boolean]
#   Turns on or off debug_timestamps in each section of the config file.
#   Default value: true
#   Used in: -see debug_level param-
#
# @param debug_microseconds [Boolean]
#   Turns on or off debug_microseconds in each section of the config file.
#   Default value: false
#   Used in: -see debug_level param-
#
# @param default_domain_suffix [Optional[String]]
#   Sets the default_domain_suffix in the sssd section of sssd config file.
#   Default value: null
#   Used in: templates/sssd.conf.erb
#
# @param default_shell [Optional[String]]
#   Sets the default_shell in local, nss sections of the sssd config file.
#   Default value: null
#   Used in: templates/provider/local.erb
#            templates/service/nss.erb
#
# @param description [Optional[String]]
#   Sets the desciption in each of the sections of the sssd config file.
#   Default value: null
#   Used in: -see debug_level param-
#
# @param domains [Array[String]]
#   Sets the domains field in the sssd section of the sssd config file.
#   Default value: null
#   Used in: templates/sssd.conf.erb
#
# @param entry_negative_timeout [Integer]
#   Sets the entry_negative_timeout field in the nss section of config file.
#   Default value: 15
#   Used in: templates/service/nss.erb
#
# @param entry_cache_nowait_percentage [Integer]
#   Sets the entry_cache_nowait_percentage field in the nss section of config.
#   Default value: 0
#   Used in: templates/service/nss.erb
#
# @param enum_cache_timeout [Integer]
#   Sets the enum_cache_timeout field in the nss section of the config file.
#   Default value: 120
#   Used in: templates/service/nss.erb
#
# @param fallback_homedir [Optional[String]]
#   Sets the fallback_homedir field in the nss section of the config file.
#   Default value: null
#   Used in: templates/service/nss.erb
#
# @param filter_users [String]
#   Sets the filter_users field in the nss section of the config file.
#   Default value: 'root'
#   Used in: templates/service/nss.erb
#
# @param filter_users_in_groups [Boolean]
#   Sets the value of the filter_users_in_groups field inside the nss
#   section of the sssd config file.
#   Default value: true
#   Used in: templates/service/nss.erb
#
# @param filter_groups [String]
#   Sets the filter_groups field inside the nss section of config file.
#   Default value: 'root'
#   Used in: templates/service/nss.erb
#
# @param full_name_format [Optional[String]]
#   Sets the full_name_format field inside the sssd and domain sections
#   of the sssd config file.
#   Default value: null
#   Used in: templates/sssd.conf.erb
#            templates/domain.erb
#
# @param get_domains_timeout [Optional[Integer]]
#   Sets the value of the get_domains_timeout field inside the nss
#   and pam sections of the sssd config file.
#   Default value: null
#   Used in: templates/service/nss.erb
#            templates/service/pam.erb
#
# @param krb5_rcache_dir [Optional[String]]
#   Sets the value of the krb5_rcache_dir field inside the sssd
#   section of the sssd config file.
#   Default value: null
#   Used in: templates/sssd.conf.erb
#
# @param memcache_timeout [Optional[Integer]]
#   Sets the value of memcache_timeout in the nss section of the config file
#   Default value: null
#   Used in: templates/service/nss.erb
#
# @param offline_credentials_expiration [Integer]
#   Sets offline_credentials_expiration inside the pam section of config file
#   Default value: 0
#   Used in: templates/service/pam.erb
#
# @param offline_failed_login_attempts [Integer]
#   Sets the value of the offline_failed_login_attempts field inside the pam
#   section of the sssd config file.
#   Default value: 3
#   Used in: templates/service/pam.erb
#
# @param offline_failed_login_delay [Integer]
#   Sets the value of the offline_failed_login_delay field inside the
#   pam section of the sssd config file.
#   Default Value: 5
#   Used in: templates/service/pam.erb
#
# @param override_homedir [Optional[String]]
#   Sets override_homedir in the ad and nss sections of the config file
#   Default value: null
#   Used in: templates/service/nss.erb
#            templates/provider/ad.erb
#
# @param override_shell [Optional[String]]
#   Sets override_shell in the nss section of the config file
#   Default value: null
#   Used in: templates/service/nss.erb
#
# @param override_space [Optional[String]]
#   Sets override_homedir in the sssd section of the config file
#   Default value: null
#   Used in: templates/sssd.conf.erb
#
# @param pam_verbosity [Integer]
#   Sets the value of pam_verbosity in the pam section of the config file.
#   Default value: 1
#   Used in: templates/service/pam.erb
#
# @param pam_id_timeout [Integer]
#   Sets the value of pam_id_timeout in the pam section of the config file.
#   Default value: 5
#   Used in: templates/service/pam.erb
#
# @param pam_pwd_expiration_warning [Integer]
#   Sets pam_pwd_expiration_warning in the pam section of the config file.
#   Default value: 7
#   Used in: templates/service/pam.erb
#
# @param pam_trusted_users [Optional[String]]
#   Sets pam_trusted_users in the pam section of the config file.
#   Default value: null
#   Used in: templates/service/pam.erb
#
# @param pam_public_domains [Optional[String]]
#   Sets pam_public_domains in the pam section of the config file.
#   Default value: null
#   Used in: templates/service/pam.erb
#
# @param reconnection_retries [Integer]
#   Sets the value of reconnection_retries in the nss, pam, and sssd sections
#   of the sssd config file.
#   Default value: 3
#   Used in: templates/service/pam.erb
#            templates/service/nss.erb
#            templates/sssd.conf.erb
#
# @param re_expression [Optional[String]]
#   Sets re_expression in the domain and sssd sections of the config file.
#   Default value: null
#   Used in: templates/sssd.conf.erb
#            templates/domain.erb
#
# @param services [Sssd::Services]
#   Sets the value of services in the sssd section of the config file.
#   Default value: ['nss','pam','ssh','sudo']
#   Used in: templates/sssd.conf.erb
#
# @param ssh_hash_known_hosts [Boolean]
#   Sets the value of ssh_hash_known_hosts in the ssh section of the config
#   Default value: true
#   Used in: templates/service/ssh.erb
#
# @param ssh_known_hosts_timeout [Optional[Integer]]
#   Sets the value of sssh_known_hosts_timeout in the ssh section of config
#   Default value: null
#   Used in: templates/service/ssh.erb
#
# @param sudo_timed [Boolean]
#   Sets the value of sudo_timed in the sudo section of the config file.
#   Default value: false
#   Used in: templates/service/sudo.erb
#
# @param try_inotify [Boolean]
#   Sets the try_inotify field in the sssd section of the conf file
#   Default value: true
#   Used in: templates/service/ssh.conf.erb
#
# @param user [Optional[String]]
#   Sets the value of the user field in the sssd section of the conf file.
#   Default value: null
#   Used in: templates/sssd.conf.erb
#
# @param user_attributes [Optional[String]]
#   Sets the user_attributes field in the nss section of the conf file
#   Default value: null
#   Used in: templates/service/nss.erb
#
# @param vetoed_shells [Optional[String]]
#   Sets the value of the vetoed_shells field in the nss section of sssd conf
#   Default value: null
#   Used in: templates/service/nss.erb
#

class sssd (

  ## These variables control the initial installation and configuration
  ## of the sssd package and its dependencies.
  Optional[String]               $client_package_name,
  Optional[String]               $client_package_version,
  Stdlib::Absolutepath           $conf_file_path,
  Optional[String]               $conf_dir_owner,
  Stdlib::Absolutepath           $conf_dir_path,
  Boolean                        $install_user_tools,
  Optional[String]               $nscd_service_name,
  Optional[String]               $package_name,
  Optional[String]               $package_version,
  Stdlib::Absolutepath           $sssd_service_path,
  Optional[String]               $sssd_service_name,
  Optional[String]               $tools_package_name,
  Optional[String]               $tools_package_version,

  ## These parameters control integration of the sssd module with other SIMP
  ## modules / services.
  Stdlib::Absolutepath           $app_pki_dir,
  Boolean                        $auditd               = simplib::lookup('simp_options::auditd', { 'default_value' => false}),
  Variant[Boolean,Enum['simp']]  $pki                  = simplib::lookup('simp_options::pki', { 'default_value' => false}),
  Stdlib::Absolutepath           $app_pki_cert_source  = simplib::lookup('simp_options::pki::source', { 'default_value' => '/etc/pki/simp/x509'}),

  ## The following parameters are exposed here, but are only used inside of
  ## templates that configure the sections of the sssd configuration file.
  ## Futher information about which parameters are available to each section
  ## of the configuration file can be found inside the manifests that control
  ## the corresponding sections. (ex: manifests/service/pam.pp)

  Array[String]                  $allowed_uids,
  Optional[Integer]              $autofs_negative_timeout,
  Optional[String]               $command,
  Integer                        $config_file_version,
  Optional[Sssd::DebugLevel]     $debug_level,
  Boolean                        $debug_timestamps,
  Boolean                        $debug_microseconds,
  Optional[String]               $default_domain_suffix,
  Optional[String]               $default_shell,
  Optional[String]               $description,
  Array[String]                  $domains,
  Integer                        $entry_negative_timeout,
  Integer                        $entry_cache_nowait_percentage,
  Integer                        $enum_cache_timeout,
  Optional[String]               $fallback_homedir,
  String                         $filter_users,
  Boolean                        $filter_users_in_groups,
  String                         $filter_groups,
  Optional[String]               $full_name_format,
  Optional[Integer]              $get_domains_timeout,
  Optional[String]               $krb5_rcache_dir,
  Optional[Integer]              $memcache_timeout,
  Integer                        $offline_credentials_expiration,
  Integer                        $offline_failed_login_attempts,
  Integer                        $offline_failed_login_delay,
  Optional[String]               $override_homedir,
  Optional[String]               $override_shell,
  Optional[String]               $override_space,
  Integer                        $pam_verbosity,
  Integer                        $pam_id_timeout,
  Integer                        $pam_pwd_expiration_warning,
  Optional[String]               $pam_trusted_users,
  Optional[String]               $pam_public_domains,
  Integer                        $reconnection_retries,
  Optional[String]               $re_expression,
  Sssd::Services                 $services,
  Boolean                        $ssh_hash_known_hosts,
  Optional[Integer]              $ssh_known_hosts_timeout,
  Boolean                        $sudo_timed,
  Boolean                        $try_inotify,
  Optional[String]               $user,
  Optional[String]               $user_attributes,
  Optional[String]               $vetoed_shells,

) {

  include '::sssd::install'
  include '::sssd::service'

  if $auditd {
    include '::auditd'

    auditd::rule { 'sssd':
      content => "-w ${sssd::conf_dir_path}/ -p wa -k CFG_sssd"
    }
  }

  concat { $sssd::conf_file_path:
    owner          => 'root',
    group          => 'root',
    mode           => '0640',
    ensure_newline => true,
    warn           => true,
    notify         => Class['sssd::service']
  }

  concat::fragment { 'sssd_main_config':
    target  => $conf_file_path,
    content => template("${module_name}/sssd.conf.erb")
  }

  if $pki {
    include '::sssd::pki'

    Class['sssd::install'] -> Class['sssd::pki']
    Class['sssd::pki'] ~> Class['sssd::service']
  }

  Class['sssd::install'] ~> Class['sssd::service']
}
