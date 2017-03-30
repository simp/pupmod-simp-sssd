[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html) [![Build Status](https://travis-ci.org/simp/pupmod-simp-sssd.svg)](https://travis-ci.org/simp/pupmod-simp-sssd) [![SIMP compatibility](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)](https://img.shields.io/badge/SIMP%20compatibility-4.2.*%2F5.1.*-orange.svg)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - A Puppet module for managing sssd](#module-description)
3. [Setup - The basics of getting started with pupmod-simp-sssd](#setup)
    * [What pupmod-simp-sssd affects](#what-simp-sssd-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with pupmod-simp-sssd](#beginning-with-simp-sssd)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


## Overview
This module installs and manages SSSD. It allows you to set config options in sssd.conf through puppet / hiera.

## This is a SIMP module
This module is a component of the
[System Integrity Management Platform](https://github.com/NationalSecurityAgency/SIMP),
a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net/).

Please read our [Contribution Guide](https://simp-project.atlassian.net/wiki/display/SD/Contributing+to+SIMP)
and visit our [developer wiki](https://simp-project.atlassian.net/wiki/display/SD/SIMP+Development+Home).


This module is optimally designed for use within a larger SIMP ecosystem, but it
can be used independently:
* When included within the SIMP ecosystem, security compliance settings will be
managed from the Puppet server.
* In the future, all SIMP-managed security subsystems will be disabled by
default and must be explicitly opted into by administrators.  Please review
*simp/simp_options* for details.

## Module Description

This module installs, configures and manages SSSD. It is also cross compatible
with `simp/pki` and `simp/auditd`.

It allows connection via krb5, ldap and local authentication.

`simp/sssd` also connects to autofs, nss, pac, pam, ssh, and sudo.

## Setup

### What simp sssd affects

Files managed by `simp/sssd`:
* /etc/sssd/sssd.conf
* /etc/init.d/sssd
* (Optional) /etc/sssd/pki with `simp/pki` enabled

Services and operations managed or affected:
* sssd (running)
* nscd (stopped)

Packages installed by `simp/pki`:
* sssd (latest by Default)

## Usage

### Beginning with SIMP SSSD

The following will install and manage the service for SSSD with the Default settings,
but will include no additional providers or affected services.

```puppet
include ::sssd
```

or

```yaml
classes:
  - sssd
```

To enable integration with the existing SIMP PKI module, set the
value of the PKI SIMP option to true:

```yaml
simp_options::pki: true
```

### Using Providers and Services

To include configuration options for the providers of the SSSD module, you must
instantiate individual defined Types contained within this module on your systems.
Similarly, include configuration options for services by including instances of the
service subclasses on the system.

See the examples for specific services and providers.

### Providers
#### I want to use local users

```puppet
sssd::provider::local { 'localusers':
  Default_shell  => '/bin/bash',
  base_directory => '/home',
  create_homedir => true,
  remove_homedir => true,
  homedir_umask  => '0037',
  skel_dir       => '/etc/skel/user',
  mail_dir       => '/etc/mailbox',
  userdel_cmd    => '/bin/userdel',
}
```

#### I want to use LDAP users

Instatiating the LDAP provdier will automatically set
access_provider = 'ldap', and you can pass configuration
options to the declaration of the defined tyep. The options below
are only useful as example syntax, you may need to check
[the sssd man page](https://linux.die.net/man/5/sssd-ldap) or the code
for sssd::provider::ldap for a full list of options and examples
that you can pass to the ldap section of the sssd config file.

```puppet
sssd::provider::ldap { 'ldapusers':
  ldap_access_filter => 'memberOf=cn=allowedusers,ou=Groups,dc=example,dc=com',
  ldap_chpass_uri    => empty,
  ldap_access_order  => 'expire',
  ...etc
}
```

#### I want to use Kerberos

This will provide a basic connection to Kerberos

```puppet
sssd::provider::krb5 { 'kerberos':
  krb5_server    => 'my.kerberos.server',
  krb5_realm     => 'mykrbrealm',
  krb5_password  => lookup('use_eyaml'),
}
```

### Services

The following services can be managed by `simp/sssd`. You use
these services in the same way that you use the providers described above,
but as there can only be one instance of each service on a system these
services are presented as Puppet subclasses rather than as Types.

* autofs
* nss
* pac
* pam
* ssh
* sudo

Please see sssd::service::<class> for more options on configuration,
some example usage syntax is below:

#### I want to configure the nss service

You can pass values to the keys of the [nss] section of the config file
by including the nss service subclass, and passing values to the corresponding keys:

```puppet
class { 'sssd::service::nss':
  description          => 'The nss section of the config file',
  filter_users         => 'root',
  filter_groups        => 'root',
  reconnection_retries => 3,
  ...
}
```

## Reference

### Classes

#### Public Classes

* sssd
* sssd::install
* sssd::install::client
* sssd::service
* sssd::service::autofs
* sssd::service::nss
* sssd::service::pac
* sssd::service::pam
* sssd::service::ssh
* sssd::service::sudo

#### Private Classes

* sssd::pki

#### Defined Types

* sssd::domain
* sssd::provider::ad
* sssd::provider::krb5
* sssd::provider::ldap
* sssd::provider::local

## Parameters

Many of the parameters and variables below have a one-to-one correspondance to the keys in the sssd man pages. Because of this, we strongly suggest searching the man pages in the event of confusion or ambiguity regarding any one parameter.


### sssd

##### `domains`:
  This key is a mandatory array of domains that will be included in your sssd.conf file. Each of these domains can have an instance of each of the provider defined Types, which must reference the domain that they belong to by name. This list cannot be empty, you must choose at least 1 domain for SSSD to manage.
  * Valid Options: Array[String]
  * Default Value: N/A

##### `debug_level`:
  Sets the debug verbosity for the main section of the config file.
  * Valid Options: String
  * Default Value: undef,

##### `debug_timestamps`:
  Enable or disable timestamps in debug file for this section of the config file.
  * Valid Options: Boolean
  * Default Value: true,

##### `debug_microseconds`:
  Enable or disable microseconds in the debug timestamps for this section of the config file.
  * Valid Options: Boolean
  * Default Value: false,

##### `description`:
  A brief description of this section of the config file.
  * Valid Options: String
  * Default Value: undef,

##### `config_file_version`:
  * Valid Options: Integer
  * Default Value: 2,

##### `services`:
  A list of the services that SSSD will integrate with. Each entry here corresponds to one section of the config file at sssd.conf. Each of the services that you include here will be managed by the corresponding sssd::service::service_name subclass.
  * Valid Options: Sssd::Services
  * Default Value: ['nss','pam','ssh','sudo'],

##### `reconnection_retries`:
  Number of times services should attempt to reconnect in the event of a Data Provider crash or restart before they give up
  * Valid Options: Integer
  * Default Value: 3,

##### `re_expression`:
  Default regular expression that describes how to parse the string containing user name and domain into these components.
  * Valid Options: String
  * Default Value: undef,

##### `full_name_format`:
  The Default format that describes how to translate a (name, domain) tuple into a fully qualified name.
  * Valid Options: String
  * Default Value: undef,

##### `try_inotify`:
  Determines if inotify should be used to query resolv.conf
  * Valid Options: Boolean
  * Default Value: true,

##### `krb5_rcache_dir`:
  Directory where krb5 files should be cached.
  * Valid Options: String
  * Default Value: undef,

##### `user`:
  * Valid Options: String
  * Default Value: undef,

##### `Default_domain_suffix`:
  Used as the default domain for instances where none is provided
  * Valid Options: String
  * Default Value: undef,

##### `override_space`:
  * Valid Options: String
  * Default Value: undef,

##### `auditd`:
  This is a special SIMP level key, which determines automatically if the simp/auditd module is installed on your system. If it is, this module will enable some Defaults to ensure the two modules interact cleanly together
  * Valid Options: BooleanS
  * Default Value: simplib::lookup('simp_options::auditd', { 'Default_value' => false}),

##### `pki`:
  This is a special SIMP level key, which determines automatically if the simp/pki module is installed on your system. If it is, this module will enable some Defaults to ensure the two modules interact cleanly together
  * Type Options: Boolean,'simp'
  * Default Value: simplib::lookup('simp_options::pki', { 'Default_value' => false}),

##### `app_pki_cert_source`:
  If the PKI module is enabled, this attempts to automatically detect the location on your system where certs are stored by Default.
  * Valid Options: Stdlib::Absolutepath
  * Default Value: simplib::lookup('simp_options::pki::source', { 'Default_value' => '/etc/pki/simp/x509'}),

##### `app_pki_dir`:
  Default PKI dir if the above lookup fails to find a set directory.
  * Valid Options: Stdlib::Absolutepath
  * Default Value: '/etc/pki/simp_apps/sssd/x509'



### sssd::install

##### `install_user_tools`:
  If true, install the sssd-tools package in addition to the sssd package.
	* Valid Options: Boolean
	* Default: True



### sssd::service::autofs

##### `description`:
  A brief description of this section of the config file.
  * Valid Options: String
  * Default Value: undef

##### `debug_level`:
  Level of verbosity of debug of this section of the config file.
  * Valid Options: [Sssd::DebugLevel]
  * Default Value: undef

##### `debug_timestamps`:
  Determines if the log file for this section of the config file will use timestamps
  * Valid Options: Boolean
  * Default Value: true

##### `debug_microseconds`:
  Determines if the log file will use microseconds in timestamps
  * Valid Options: Boolean
  * Default Value: false

##### `autofs_negative_timeout`:
  Specifies for how many seconds should the autofs responder negative cache hits (that is, queries for invalid map entries, like nonexistent ones) before asking the back end again.
	* Valid Options: Integer
	* Default Value: undef



### sssd::service::nss

##### `description`:
  A brief description of this section of the config file.
  * Valid Options: String
  * Default Value: undef

##### `debug_level`:
  Level of verbosity of debug of this section of the config file.
  * Valid Options: [Sssd::DebugLevel]
  * Default Value: undef

##### `debug_timestamps`:
  Determines if the log file for this section of the config file will use timestamps
  * Valid Options: Boolean
  * Default Value: true

##### `debug_microseconds`:
  Determines if the log file will use microseconds in timestamps
  * Valid Options: Boolean
  * Default Value: false

##### `reconnection_retries`:
  The number of times the service will attempt to reconnect in the event of timeout.
  * Valid Options: Integer
  * Default Value: 3

##### `fd_limit`:
  This option specifies the maximum number of file descriptors that may be opened at one time by this SSSD process.
  * Valid Options: Integer
  * Default Value: undef

##### `command`:
  * Valid Options: String
  * Default Value: undef,

##### `enum_cache_timeout`:
  How many seconds should nss_sss cache enumerations
  * Valid Options: Integer
  * Default Value: 120

##### `entry_cache_nowait_percentage`:
  The entry cache can be set to automatically update entries in the background if they are requested beyond a percentage of the entry_cache_timeout value for the domain.
  * Valid Options: Integer
  * Default Value: 0

##### `entry_negative_timeout`:
  Specifies for how many seconds nss_sss should cache negative cache hits
  * Valid Options: Integer
  * Default Value: 15

##### `filter_users`:
  Exclude certain users from being fetched from the sss NSS database.
  * Valid Options: String
  * Default Value: 'root'

##### `filter_groups`:
  Exclude certain groups from being fetched from the sss NSS database.
  * Valid Options: String
  * Default Value: 'root'

##### `filter_users_in_groups`:
  If you want filtered user still be group members set this option to false.
  * Valid Options: Boolean
  * Default Value: true

##### `override_homedir`:
  Override the user's home directory
  * Valid Options: String
  * Default Value: undef

##### `fallback_homedir`:
  Set a Default template for a user's home directory if one is not specified explicitly by the domain's data provider.
  * Valid Options: String
  * Default Value: undef

##### `override_shell`:
  Override the login shell for all users. This option can be specified globally in the [nss] section or per-domain.
  * Valid Options: String
  * Default Value: undef

##### `vetoed_shells`:
  Replace any instance of these shells with the shell_fallback
  * Valid Options: String
  * Default Value: undef

##### `Default_shell`:
  The default shell to use if the provider does not return one during lookup. This option supersedes any other shell options if it takes effect.
  * Valid Options: String
  * Default Value: undef

##### `get_domains_timeout`:
  Specifies time in seconds for which the list of subdomains will be considered valid.
  * Valid Options: Integer
  * Default Value: undef

##### `memcache_timeout`:
  Specifies time in seconds for which records in the in-memory cache will be valid
  * Valid Options: Integer
  * Default Value: undef

##### `user_attributes`:
  * Valid Options: String
  * Default Value: undef



### sssd::service::pac

##### `description`:
  a brief description of this section of the config file.
  * Valid Options: Optional[String]
  * Default value: undef

##### `debug_level`:
  level of verbosity of debug of this section of the config file.
  * Valid Options: Optional[Sssd::Debuglevel]
  * Default value: undef

##### `debug_timestamps`:
  determines if the log file for this section of the config file will use timestamps
  * Valid Options: Boolean
  * Default value: true

##### `debug_microseconds`:
  determines if the log file will use microseconds in timestamps
  * Valid Options: Boolean
  * Default value: false

##### `allowed_uids`:
  Specifies the comma-separated list of UID values or user names that are allowed to access the PAC responder. User names are resolved to UIDs at startup.
	* Valid Options: ArrayString
	* Default Value: []



### sssd::service::pam

##### `description`:
  a brief description of this section of the config file.
  * Valid Options: Optional[String]
  * Default value: undef

##### `debug_level`:
  level of verbosity of debug of this section of the config file.
  * Valid Options: Optional[Sssd::Debuglevel]
  * Default value: undef

##### `debug_timestamps`:
  determines if the log file for this section of the config file will use timestamps
  * Valid Options: Boolean
  * Default value: true

##### `debug_microseconds`:
  determines if the log file will use microseconds in timestamps
  * Valid Options: Boolean
  * Default value: false

##### `reconnection_retries`:
  The number of times the service will attempt to reconnect in the event of timeout.
  * Valid Options: Integer
  * Default Value: 3

##### `command`:
  * Valid Options: String
  * Default Value: undef

##### `offline_credentials_expiration`:
  If the authentication provider is offline, how long should we allow cached logins (in days since the last successful online login).
  * Valid Options: Integer
  * Default Value: 0

##### `offline_failed_login_attempts`:
  If the authentication provider is offline, how many failed login attempts are allowed.
  * Valid Options: Integer
  * Default Value: 3

##### `offline_failed_login_delay`:
  The time in minutes which has to pass after offline_failed_login_attempts has been reached before a new login attempt is possible.
  * Valid Options: Integer
  * Default Value: 5

##### `pam_verbosity`:
  Controls what kind of messages are shown to the user during authentication. The higher the number, the more messages displayed.
  * Valid Options: Integer
  * Default Value: 1

##### `pam_id_timeout`:
  For any PAM request while SSSD is online, the SSSD will attempt to immediately update the cached identity information for the user in order to ensure that authentication takes place with the latest information.
  * Valid Options: Integer
  * Default Value: 5

##### `pam_pwd_expiration_warning`:
  Display a warning N days before the password expires.
  * Valid Options: Integer
  * Default Value: 7

##### `get_domains_timeout`:
  Specifies time in seconds for which the list of subdomains will be considered valid.
  * Valid Options: Integer
  * Default Value: undef

##### `pam_trusted_users`:
  List of numerical UIDs or user names that are trusted
  * Valid Options: String
  * Default Value: undef

##### `pam_public_domains`:
  List of domains accessible for untrusted users
  * Valid Options: String
  * Default Value: unde



### sssd::service::ssh

##### `description`:
  a brief description of this section of the config file.
  * Valid Options: Optional[String]
  * Default value: undef

##### `debug_level`:
  level of verbosity of debug of this section of the config file.
  * Valid Options: Optional[Sssd::Debuglevel]
  * Default value: undef

##### `debug_timestamps`:
  determines if the log file for this section of the config file will use timestamps
  * Valid Options: Boolean
  * Default value: true

##### `debug_microseconds`:
  determines if the log file will use microseconds in timestamps
  * Valid Options: Boolean
  * Default value: false

##### `ssh_hash_known_hosts`:
  Whether or not to hash host names and addresses in the managed known_hosts file.
  * Valid Options: Boolean
  * Default Value: true

##### `ssh_known_hosts_timeout`:
  How many seconds to keep a host in the managed known_hosts file after its host keys were requested.
  * Valid Options: Integer
  * Default Value: undef



### sssd::service::sudo

##### `description`:
  a brief description of this section of the config file.
  * Valid Options: Optional[String]
  * Default value: undef

##### `debug_level`:
  level of verbosity of debug of this section of the config file.
  * Valid Options: Optional[Sssd::Debuglevel]
  * Default value: undef

##### `debug_timestamps`:
  determines if the log file for this section of the config file will use timestamps
  * Valid Options: Boolean
  * Default value: true

##### `debug_microseconds`:
  determines if the log file will use microseconds in timestamps
  * Valid Options: Boolean
  * Default value: false

##### `sudo_timed`:
  Whether or not to evaluate the sudoNotBefore and sudoNotAfter attributes that implement time-dependent sudoers entries.
  * Valid Options: Boolean
	* Default Value: false


## Defined Type Variables

### sssd::domain


##### `id_provider`:
  Indicates the id of this domain that providers will reference.
  * Valid Options: Sssd::IdProvider
  * Default Value:

##### `description`:
  a brief description of this section of the config file.
  * Valid Options: Optional[String]
  * Default value: undef

##### `debug_level`:
  level of verbosity of debug of this section of the config file.
  * Valid Options: Optional[Sssd::Debuglevel]
  * Default value: undef

##### `debug_timestamps`:
  determines if the log file for this section of the config file will use timestamps
  * Valid Options: Boolean
  * Default value: true

##### `debug_microseconds`:
  determines if the log file will use microseconds in timestamps
  * Valid Options: Boolean
  * Default value: false

##### `min_id`:
  UID and GID limits for the domain. If a domain contains an entry that is outside these limits, it is ignored.
  * Valid Options: Integer
  * Default Value: $facts['uid_min']

##### `max_id`:
  UID and GID limits for the domain. If a domain contains an entry that is outside these limits, it is ignored.
  * Valid Options: Integer
  * Default Value: 0

##### `enumerate`:
  Determines if a domain can be enumerated.
  * Valid Options: Boolean
  * Default Value: false

##### `subdomain_enumerate`:
  Same as enumerate, for subdomains
  * Valid Options: Boolean
  * Default Value: false

##### `force_timeout`:
  If a service is not responding to ping checks (see the "timeout" option), it is first sent the SIGTERM signal that instructs it to quit gracefully. If the service does not terminate after "force_timeout" seconds, the monitor will forcibly shut it down by sending a SIGKILL signal.
  * Valid Options: Integer
  * Default Value: undef

##### `entry_cache_timeout`:
  How many seconds should nss_sss consider entries valid before asking the backend again
  * Valid Options: Integer
  * Default Value: undef

##### `entry_cache_user_timeout`:
  How many seconds should nss_sss consider user entries valid before asking the backend again
  * Valid Options: Integer
  * Default Value: undef

##### `entry_cache_group_timeout`:
  How many seconds should nss_sss consider user entries valid before asking the backend again
  * Valid Options: Integer
  * Default Value: undef

##### `entry_cache_netgroup_timeout`:
  How many seconds should nss_sss consider user entries valid before asking the backend again
  * Valid Options: Integer
  * Default Value: undef

##### `entry_cache_service_timeout`:
  How many seconds should nss_sss consider user entries valid before asking the backend again
  * Valid Options: Integer
  * Default Value: undef

##### `entry_cache_sudo_timeout`:
  How many seconds should nss_sss consider user entries valid before asking the backend again
  * Valid Options: Integer
  * Default Value: undef

##### `entry_cache_autofs_timeout`:
  How many seconds should nss_sss consider user entries valid before asking the backend again
  * Valid Options: Integer
  * Default Value: undef

##### `entry_cache_ssh_host_timeout`:
  How many seconds should nss_sss consider user entries valid before asking the backend again
  * Valid Options: Integer
  * Default Value: undef

##### `refresh_expired_interval`:
  Time between refresh expired intervals
  * Valid Options: Integer
  * Default Value: undef

##### `cache_credentials`:
  Determines if user credentials are also cached in the local LDB cache
  * Valid Options: Boolean
  * Default Value: false

##### `account_cache_expiration`:
  Number of days entries are left in cache after last successful login before being removed during a cleanup of the cache. 0 means keep forever.
  * Valid Options: Integer
  * Default Value: 0

##### `pwd_expiration_warning`:
  Display a warning N days before the password expires.
  * Valid Options: Integer
  * Default Value: undef

##### `use_fully_qualified_names`:
  Use the full name and domain (as formatted by the domain's full_name_format) as the user's login name reported to NSS.
  * Valid Options: Boolean
  * Default Value: false

##### `ignore_group_members`:
  * Valid Options: Boolean
  * Default Value: true

##### `access_provider`:
  The access control provider used for the domain. There are two built-in access providers (in addition to any included in installed backends)
  * Valid Options: [Sssd::AccessProvider]
  * Default Value: undef

##### `auth_provider`:
  The authentication provider used for the domain.
  * Valid Options: [Sssd::AuthProvider]
  * Default Value: undef

##### `chpass_provider`:
  The provider which should handle change password operations for the domain
  * Valid Options: [Sssd::ChpassProvider]
  * Default Value: undef

##### `sudo_provider`:
  The SUDO provider used for the domain.
  * Valid Options: 'ldap', 'ipa','ad','none'
  * Default Value: undef

##### `selinux_provider`:
  The provider which should handle loading of selinux settings. Note that this provider will be called right after access provider ends.
  * Valid Options: 'ipa', 'none'
  * Default Value: undef

##### `subdomains_provider`:
  The provider which should handle fetching of subdomains. This value should be always the same as id_provider.
  * Valid Options: 'ipa', 'ad','none'
  * Default Value: undef

##### `autofs_provider`:
  The autofs provider used for the domain. Supported autofs providers are:
  * Valid Options: 'ldap', 'ipa','none'
  * Default Value: undef

##### `hostid_provider`:
  The provider used for retrieving host identity information.
  * Valid Options: 'ipa', 'none'
  * Default Value: undef

##### `re_expression`:
  Regular expression for this domain that describes how to parse the string containing user name and domain into these components.
  * Valid Options: String
  * Default Value: undef

##### `full_name_format`:
  The default format that describes how to translate a (name, domain) tuple into a fully qualified name.
  * Valid Options: String
  * Default Value: undef

##### `lookup_family_order`:
  Provides the ability to select preferred address family to use when performing DNS lookups.
  * Valid Options: String
  * Default Value: undef

##### `dns_resolver_timeout`:
  Defines the amount of time (in seconds) to wait for a reply from the DNS resolver before assuming that it is unreachable. If this timeout is reached, the domain will continue to operate in offline mode.
  * Valid Options: Integer
  * Default Value: 5

##### `dns_discovery_domain`:
  If service discovery is used in the back end, specifies the domain part of the service discovery DNS query.
  * Valid Options: String
  * Default Value: undef

##### `override_gid`:
  Override the primary GID value with the one specified.
  * Valid Options: String
  * Default Value: undef

##### `case_sensitive`:
  Treat user and group names as case sensitive
  * Valid Options: Boolean,'preserving'
  * Default Value: true

##### `proxy_fast_alias`:
  When a user or group is looked up by name in the proxy provider, a second lookup by ID is performed to "canonicalize" the name in case the requested name was an alias. Setting this option to true would cause the SSSD to perform the ID lookup from cache for performance reasons.
  * Valid Options: Boolean
  * Default Value: false

##### `realmd_tags`:
  * Valid Options: String
  * Default Value: undef

##### `proxy_pam_target`:
  The proxy target PAM proxies to.
  * Valid Options: String
  * Default Value: undef

##### `proxy_lib_name`:
  The name of the NSS library to use in proxy domains. The NSS functions searched for in the library are in the form of _nss_$(libName)_$(function), for example _nss_files_getpwent.
	* Valid Options: String
  * Default Value: undef



### sssd::provider::ad

For each variable listed below that begins with `ad_`, please reference the SSSD-ad man pages at [this location](https://linux.die.net/man/5/sssd-ad)


##### `ad_domain`:
  Specifies the name of the Active Directory domain. This is optional. If not provided, the configuration domain name is used.
  * Valid Options: String
  * Default Value: undef

##### `ad_enabled_domains`:
  * Valid Options: Array[String]
  * Default Value: undef

##### `ad_servers`:
  The comma-separated list of IP addresses or hostnames of the AD servers to which SSSD should connect in order of preference.
  * Valid Options: [Simplib::Hostname], ['_srv_']
  * Default Value: undef

##### `ad_backup_servers`:
  The comma-separated list of IP addresses or hostnames of the AD servers to which SSSD should connect in order of preference.
  * Valid Options: Array[Simplib::Hostname]
  * Default Value: undef

##### `ad_hostname`:
  May be set on machines where the hostname(5) does not reflect the fully qualified name used in the Active Directory domain to identify this host.
  * Valid Options: [Simplib::Hostname]
  * Default Value: undef

##### `ad_enable_dns_sites`:
  * Valid Options: Boolean
  * Default Value: undef

##### `ad_access_filters`:
  * Valid Options: Array[String]
  * Default Value: undef

##### `ad_site`:
  * Valid Options: String
  * Default Value: undef

##### `ad_enable_gc`:
  * Valid Options: Boolean
  * Default Value: undef

##### `ad_gpo_access_control`:
  * Valid Options: 'disabled','enforcing','permissive'
  * Default Value: undef

##### `ad_gpo_cache_timeout`:
  * Valid Options: [Integer[1]]
  * Default Value: undef

##### `ad_gpo_map_interactive`:
  * Valid Options: Array[String]
  * Default Value: undef

##### `ad_gpo_map_remote_interactive`:
  * Valid Options: Array[String]
  * Default Value: undef

##### `ad_gpo_map_network`:
  * Valid Options: Array[String]
  * Default Value: undef

##### `ad_gpo_map_batch`:
  * Valid Options: Array[String]
  * Default Value: undef

##### `ad_gpo_map_service`:
  * Valid Options: Array[String]
  * Default Value: undef

##### `ad_gpo_map_permit`:
  * Valid Options: Array[String]
  * Default Value: undef

##### `ad_gpo_map_deny`:
  * Valid Options: Array[String]
  * Default Value: undef

##### `ad_gpo_default_right`:
  * Valid Options: 'interactive','remote
  * Default Value: undef

##### `ad_maximum_machine_account_password_age`:
  * Valid Options: Integer[0]
  * Default Value: undef

##### `ad_machine_account_password_renewal_opts`:
  * Valid Options: Pattern['^\d+:\d+$']
  * Default Value: undef

##### `dyndns_update`:
  This option tells SSSD to automatically update the DNS server built into FreeIPA v2 with the IP address of this client. The update is secured using GSS-TSIG. The IP address of the IPA LDAP connection is used for the updates, if it is not otherwise specified by using the “dyndns_iface” option.
  * Valid Options: Boolean
  * Default Value: true

##### `dyndns_ttl`:
  The TTL to apply to the client DNS record when updating it. If dyndns_update is false this has no effect. This will override the TTL serverside if set by an administrator.
  * Valid Options: Integer
  * Default Value: undef

##### `dyndns_ifaces`:
  Applicable only when dyndns_update is true. Choose the interface whose IP address should be used for dynamic DNS updates.
  * Valid Options: Array[String]
  * Default Value: undef

##### `dyndns_refresh_interval`:
  How often should the back end perform periodic DNS update in addition to the automatic update performed when the back end goes online. This option is optional and applicable only when dyndns_update is true.
  * Valid Options: Integer
  * Default Value: undef

##### `dyndns_update_ptr`:
  Whether the PTR record should also be explicitly updated when updating the client's DNS records. Applicable only when dyndns_update is true.
  * Valid Options: Boolean
  * Default Value: undef

##### `dyndns_force_tcp`:
  Whether the nsupdate utility should default to using TCP for communicating with the DNS server.
  * Valid Options: Boolean
  * Default Value: undef

##### `dyndns_server`:
  Hostname of the dyndns server
  * Valid Options: [Simplib::Hostname]
  * Default Value: undef

##### `override_homedir`:
  Override the user's home directory. You can either provide an absolute value or a template
  * Valid Options: String
  * Default Value: undef

##### `homedir_substring`:
  * Valid Options: [Stdlib::Absolutepath]
  * Default Value: undef

##### `krb5_use_enterprise_principal`:
  * Valid Options: Boolean
  * Default Value: undef

##### `krb5_confd_path`:
  * Valid Options: 'none', Stdlib::Absolutepath
  * Default Value: undef

##### `ldap_id_mapping`:
  Set the id_mapping value for this section
  * Valid Options: Boolean
  * Default Value: true

##### `ldap_idmap_range_min`:
  Specifies the lower bound of the range of POSIX IDs to use for mapping Active Directory user and group SIDs.
  * Valid Options: [Integer[0]]
  * Default Value: undef

##### `ldap_idmap_range_max`:
  Specifies the upper bound of the range of POSIX IDs to use for mapping Active Directory user and group SIDs.
  * Valid Options: [Integer[1]]
  * Default Value: undef

##### `ldap_idmap_range_size`:
  Specifies the number of IDs available for each slice.
  * Valid Options: [Integer[1]]
  * Default Value: undef

##### `ldap_idmap_default_domain_sid`:
  Specify the domain SID of the default domain.
  * Valid Options: String
  * Default Value: undef

##### `ldap_idmap_default_domain`:
  Specify the name of the default domain.
  * Valid Options: String
  * Default Value: undef

##### `ldap_idmap_autorid_compat`:
  Changes the behavior of the ID-mapping algorithm to behave more similarly to winbind's "idmap_autorid" algorithm.
  * Valid Options: Boolean
  * Default Value: undef

##### `ldap_idmap_helper_table_size`:
   Valid Options: [Integer[1]]
  * Default Value: undef



### sssd::provider::local

##### `debug_level`:
  level of verbosity of debug of this section of the config file.
  * Valid Options: Optional[Sssd::Debuglevel]
  * Default value: undef

##### `debug_timestamps`:
  determines if the log file for this section of the config file will use timestamps
  * Valid Options: Boolean
  * Default value: true

##### `debug_microseconds`:
  determines if the log file will use microseconds in timestamps
  * Valid Options: Boolean
  * Default value: false

##### `default_shell`:
  The default shell for users created with SSSD userspace tools.
  * Valid Options: Optional[String]
  * Default Value: undef

##### `base_directory`:
  The tools append the login name to base_directory and use that as the home directory.
  * Valid Options: Optional[Stdlib::Absolutepath]
  * Default Value: undef

##### `create_homedir`:
  Indicate if a home directory should be created by default for new users. Can be overridden on command line.
  * Valid Options: Boolean
  * Default Value: true

##### `remove_homedir`:
  Indicate if a home directory should be removed by default for deleted users. Can be overridden on command line.
  * Valid Options: Boolean
  * Default Value: true

##### `homedir_umask`:
  Used to specify the default permissions on a newly created home directory.
  * Valid Options: Optional[Simplib::Umask]
  * Default Value: undef

##### `skel_dir`:
  The skeleton directory, which contains files and directories to be copied in the user's home directory, when the home directory is created
  * Valid Options: Optional[Stdlib::Absolutepath]
  * Default Value: undef

##### `mail_dir`:
  The mail spool directory. This is needed to manipulate the mailbox when its corresponding user account is modified or deleted.
  * Valid Options: Optional[Stdlib::Absolutepath]
  * Default Value: undef

##### `userdel_cmd`:
  The command that is run after a user is removed. The command us passed the username of the user being removed as the first and only parameter. The return code of the command is not taken into account.
  * Valid Options: Optional[String]
  * Default Value: undef



### sssd::provider::krb5

For each variable listed below that begins with `krb5_`, please reference the SSSD-krb5 man pages at [this location](https://linux.die.net/man/5/sssd-krb5)


##### `debug_level`:
  level of verbosity of debug of this section of the config file.
  * Valid Options: Optional[Sssd::Debuglevel]
  * Default value: undef

##### `debug_timestamps`:
  determines if the log file for this section of the config file will use timestamps
  * Valid Options: Boolean
  * Default value: true

##### `debug_microseconds`:
  determines if the log file will use microseconds in timestamps
  * Valid Options: Boolean
  * Default value: false

##### `krb5_server`:
  * Valid Options: Simplib::Host
  * Default Value:

##### `krb5_realm`:
  * Valid Options: String
  * Default Value:

##### `krb5_kpasswd`:
  * Valid Options: Optional[String]
  * Default Value: undef,

##### `krb5_ccachedir`:
  * Valid Options: Optional[Stdlib::Absolutepath]
  * Default Value: undef,

##### `krb5_ccname_template`:
  * Valid Options: Optional[Stdlib::Absolutepath]
  * Default Value: undef,

##### `krb5_auth_timeout`:
  * Valid Options: Integer
  * Default Value: 15,

##### `krb5_validate`:
  * Valid Options: Boolean
  * Default Value: false,

##### `krb5_keytab`:
  * Valid Options: Optional[Stdlib::Absolutepath]
  * Default Value: undef,

##### `krb5_store_password_if_offline`:
  * Valid Options: Boolean
  * Default Value: false,

##### `krb5_renewable_lifetime`:
  * Valid Options: Optional[String]
  * Default Value: undef,

##### `krb5_lifetime`:
  * Valid Options: Optional[String]
  * Default Value: undef,

##### `krb5_renew_interval`:
  * Valid Options: Integer
  * Default Value: 0,

##### `krb5_use_fast`:
  * Valid Options: 'never','try','demand'
  * Default Value: undef



### sssd::provider::ldap

For each variable listed below that begins with `krb5_`, please reference the SSSD-krb5 man pages at [this location](https://linux.die.net/man/5/sssd-krb5)
For each variable listed below that begins with `ldap_`, please reference the SSSD-ldap man pages at [this location](https://linux.die.net/man/5/sssd-ldap)

Defaults for these variables can be found in the sssd::provider::ldap manifest


##### `debug_level`:
  level of verbosity of debug of this section of the config file.
  * Valid Options: Optional[Sssd::Debuglevel]
  * Default value: undef

##### `debug_timestamps`:
  determines if the log file for this section of the config file will use timestamps
  * Valid Options: Boolean
  * Default value: true

##### `debug_microseconds`:
  determines if the log file will use microseconds in timestamps
  * Valid Options: Boolean
  * Default value: false

##### `ldap_uri`
##### `ldap_backup_uri`
##### `ldap_chpass_uri`
##### `ldap_chpass_backup_uri`
##### `ldap_chpass_update_last_change`
##### `ldap_search_base`
##### `ldap_schema`
##### `ldap_default_bind_dn`
##### `ldap_default_authtok_type`
##### `ldap_default_authtok`
##### `ldap_user_object_class`
##### `ldap_user_name`
##### `ldap_user_uid_number`
##### `ldap_user_gid_number`
##### `ldap_user_gecos`
##### `ldap_user_home_directory`
##### `ldap_user_shell`
##### `ldap_user_uuid`
##### `ldap_user_objectsid`
##### `ldap_user_modify_timestamp`
##### `ldap_user_shadow_last_change`
##### `ldap_user_shadow_min`
##### `ldap_user_shadow_max`
##### `ldap_user_shadow_warning`
##### `ldap_user_shadow_inactive`
##### `ldap_user_shadow_expire`
##### `ldap_user_krb_last_pwd_change`
##### `ldap_user_krb_password_expiration`
##### `ldap_user_ad_account_expires`
##### `ldap_user_ad_user_account_control`
##### `ldap_ns_account_lock`
##### `ldap_user_nds_login_disabled`
##### `ldap_user_nds_login_expiration_time`
##### `ldap_user_nds_login_allowed_time_map`
##### `ldap_user_principal`
##### `ldap_user_extra_attrs`
##### `ldap_user_ssh_public_key`
##### `ldap_force_upper_case_realm`
##### `ldap_enumeration_refresh_timeout`
##### `ldap_purge_cache_timeout`
##### `ldap_user_fullname`
##### `ldap_user_member_of`
##### `ldap_user_authorized_service`
##### `ldap_user_authorized_host`
##### `ldap_group_object_class`
##### `ldap_group_name`
##### `ldap_group_gid_number`
##### `ldap_group_member`
##### `ldap_group_uuid`
##### `ldap_group_objectsid`
##### `ldap_group_modify_timestamp`
##### `ldap_group_type`
##### `ldap_group_nesting_level`
##### `ldap_groups_use_matching_rule_in_chain`
##### `ldap_initgroups_use_matching_rule_in_chain`
##### `ldap_use_tokengroups`
##### `ldap_netgroup_object_class`
##### `ldap_netgroup_name`
##### `ldap_netgroup_member`
##### `ldap_netgroup_triple`
##### `ldap_netgroup_uuid`
##### `ldap_netgroup_modify_timestamp`
##### `ldap_service_name`
##### `ldap_service_port`
##### `ldap_service_proto`
##### `ldap_service_search_base`
##### `ldap_search_timeout`
##### `ldap_enumeration_search_timeout`
##### `ldap_network_timeout`
##### `ldap_opt_timeout`
##### `ldap_connection_expire_timeout`
##### `ldap_page_size`
##### `ldap_disable_paging`
##### `ldap_disable_range_retrieval`
##### `ldap_sasl_minssf`
##### `ldap_deref_threshold`
##### `ldap_tls_reqcert`
##### `app_pki_ca_dir`
##### `app_pki_key`
##### `app_pki_cert`
##### `ldap_tls_cipher_suite`
##### `ldap_id_use_start_tls`
##### `ldap_id_mapping`
##### `ldap_min_id`
##### `ldap_max_id`
##### `ldap_sasl_mech`
##### `ldap_sasl_authid`
##### `ldap_sasl_realm`
##### `ldap_sasl_canonicalize`
##### `ldap_krb5_keytab`
##### `ldap_krb5_init_creds`
##### `ldap_krb5_ticket_lifetime`
##### `krb5_server`
##### `krb5_backup_server`
##### `krb5_realm`
##### `krb5_canonicalize`
##### `krb5_use_kdcinfo`
##### `ldap_pwd_policy`
##### `ldap_referrals`
##### `ldap_dns_service_name`
##### `ldap_chpass_dns_service_name`
##### `ldap_access_filter`
##### `ldap_account_expire_policy`
##### `ldap_access_order`
##### `ldap_pwdlockout_dn`
##### `ldap_deref`
##### `ldap_sudorule_object_class`
##### `ldap_sudorule_name`
##### `ldap_sudorule_command`
##### `ldap_sudorule_host`
##### `ldap_sudorule_user`
##### `ldap_sudorule_option`
##### `ldap_sudorule_runasuser`
##### `ldap_sudorule_runasgroup`
##### `ldap_sudorule_notbefore`
##### `ldap_sudorule_notafter`
##### `ldap_sudorule_order`
##### `ldap_sudo_full_refresh_interval`
##### `ldap_sudo_smart_refresh_interval`
##### `ldap_sudo_use_host_filter`
##### `ldap_sudo_hostnames`
##### `ldap_sudo_ip`
##### `ldap_sudo_include_netgroups`
##### `ldap_sudo_include_regexp`
##### `ldap_autofs_map_master_name`
##### `ldap_autofs_map_object_class`
##### `ldap_autofs_map_name`
##### `ldap_autofs_entry_object_class`
##### `ldap_autofs_entry_key`
##### `ldap_autofs_entry_value`

 Be careful with the following options!

##### `ldap_netgroup_search_base`
##### `ldap_user_search_base`
##### `ldap_group_search_base`
##### `ldap_sudo_search_base`
##### `ldap_autofs_search_base`

Advanced Configuration - Read the man page

##### `ldap_idmap_range_min`
##### `ldap_idmap_range_max`
##### `ldap_idmap_range_size`
##### `ldap_idmap_default_domain_sid`
##### `ldap_idmap_default_domain`
##### `ldap_idmap_autorid_compat`

## Limitations

This module is only designed to work in RHEL or CentOS 6 and 7. Any other
operating systems have not been tested and results cannot be guaranteed.

# Development

Please see the
[SIMP Contribution Guidelines](https://simp-project.atlassian.net/wiki/display/SD/Contributing+to+SIMP).

General developer documentation can be found on
[Confluence](https://simp-project.atlassian.net/wiki/display/SD/SIMP+Development+Home).
Visit the project homepage on [GitHub](https://simp-project.com),
chat with us on our [HipChat](https://simp-project.hipchat.com/),
and look at our issues on  [JIRA](https://simp-project.atlassian.net/).
