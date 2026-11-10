[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/sssd.svg)](https://forge.puppetlabs.com/simp/sssd)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/sssd.svg)](https://forge.puppetlabs.com/simp/sssd)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-sssd.svg)](https://travis-ci.org/simp/pupmod-simp-sssd)

#### Table of Contents

<!-- vim-markdown-toc GFM -->

  * [Overview](#overview)
  * [Breaking changes in 11.0.0](#breaking-changes-in-1100)
    * [What a bare include no longer does](#what-a-bare-include-no-longer-does)
    * [Restoring the earlier behavior](#restoring-the-earlier-behavior)
    * [Other changes](#other-changes)
  * [> Use an older version of the module if you need lower version support](#-use-an-older-version-of-the-module-if-you-need-lower-version-support)
  * [This is a SIMP module](#this-is-a-simp-module)
  * [Module Description](#module-description)
  * [Setup](#setup)
    * [What simp sssd affects](#what-simp-sssd-affects)
  * [Usage](#usage)
    * [Beginning with SIMP SSSD](#beginning-with-simp-sssd)
    * [Creating Domains and Providers](#creating-domains-and-providers)
      * [More examples](#more-examples)
        * [Enabling Local Users](#enabling-local-users)
        * [Using LDAP (Generic)](#using-ldap-generic)
        * [Using FreeIPA or Red Hat Directory Server](#using-freeipa-or-red-hat-directory-server)
        * [Using Active Directory](#using-active-directory)
          * [Restricting Access with the simple Access Provider](#restricting-access-with-the-simple-access-provider)
    * [Using Services](#using-services)
    * [Applying changes when the service is unmanaged](#applying-changes-when-the-service-is-unmanaged)
* [Development](#development)

<!-- vim-markdown-toc -->

## Overview

This module installs and manages SSSD. It allows you to set configuration
options in sssd.conf through puppet / hiera.

A bare `include sssd` installs the SSSD packages and does nothing else. Every
other behavior is opt-in, and each setting is edited in place, so settings the
module isn't asked to manage are left exactly as they are.

----------------------------------------------------------------------
> WARNING
>
> This module only supports `sssd` > 1.16.0
>
> Use an older version of the module if you need lower version support
----------------------------------------------------------------------

See [REFERENCE.md](./REFERENCE.md) for full API details

## Breaking changes in 11.0.0

### What a bare include no longer does

Before 11.0.0, `include sssd` took over the host's SSSD configuration and
daemon. It now declares only the `sssd`, `sssd-dbus`, `sssd-client` and
`sssd-tools` packages. In particular, it no longer:

* writes `/etc/sssd/sssd.conf` as a whole file, or always writes
  `debug_timestamps` and `debug_microseconds` into `[sssd]`;
* writes the `[nss]`, `[pam]`, `[ssh]` and `[sudo]` responder sections, or
  lists `nss`, `pam` and `ssh` in `services`: `sssd::services_entries` is
  empty, and every `sssd::service::*` parameter defaults to `undef`;
* manages `Service['sssd']` (`sssd::service::ensure` and `enable`), or
  enables `sssd-sudo.socket` (`sssd::service::sudo::socket_enable`);
* manages the `/etc/sssd` and `/etc/sssd/conf.d` directory modes
  (`sssd::config::sssd_config_dir_mode`);
* deletes `*_puppet_*.conf` snippets it no longer manages
  (`sssd::tidy_puppet_snippets`);
* declares the EL10 `LOCAL` proxy domain (`sssd::config::manage_base_domain`);
* configures the IPA domain on an IPA-joined host (`sssd::auto_add_ipa_domain`);
* adds the EL8/9 `sssd-sudo.service` drop-in
  (`sssd::service::sudo::manage_group_dropin_file`);
* writes the EL8/9-only `config_file_version`, `reconnection_retries`,
  `enable_files_domain` and `ssh_hash_known_hosts` settings.

Every section the module manages, `[sssd]` included, is now edited one setting
at a time with `ini_setting` (from `puppetlabs/inifile`, a new dependency).
Each parameter that maps to a setting has three states:

| Value | Effect |
|---|---|
| `undef` (the default) | the setting is left alone |
| a value | the setting is written |
| `'absent'` | the setting is removed |

The `services` and `domains` lists are edited one entry at a time through the
new `sssd::services_entries` and `sssd::domains_entries` Hashes, merged with
`deep`, so one Hiera layer can add or remove an entry (`ensure: absent`)
without restating the rest. The `sssd::services` and `sssd::domains` Arrays
are deprecated; while one is set (even to `[]`) it is used instead of its
Hash, as it replaced the module's default list before.

Unlike 10.x, removing an entry from one of these Arrays no longer removes it
from the line: the entry is just no longer managed, so a domain dropped this
way stays listed, and active. Remove it explicitly instead, with a `--<name>`
entry in `sssd::domains`, or by moving to the Hash and setting it `absent`:

```yaml
sssd::domains_entries:
  OLD_DOMAIN:
    ensure: absent
```

The deprecated `sssd::services` also keeps its 10.x meaning for `sudo`: listing
it there means the responder is socket-activated, so `sudo` is removed from
the `services` line rather than added. Hosts upgraded from 10.x keep the
`sssd-sudo.socket` it enabled; set `sssd::service::sudo::socket_enable` (or
enforce `simp:defaults`) to keep managing it.

The lines are edited one entry at a time, which has two other effects:

* An entry is matched exactly, including case: with `domains = example.com` on
  disk, an `Example.com` entry is added next to it, and an `EXAMPLE.COM` entry
  set to `absent` removes nothing. Use the spelling the line already has.
* An entry the line doesn't have yet is inserted after the entry declared
  before it, so the declared order, which is SSSD's domain lookup order, is
  kept. Entries already on the line keep their place, though: the module
  doesn't reorder a line it didn't write. To change the order, remove the
  entries (`absent`) and add them back, or set SSSD's
  `domain_resolution_order` with `sssd::custom_settings` (which makes SSSD
  print fully-qualified names).

The module now edits `sssd.conf` alongside the other tools that write to it
(such as `ipa-client-install` and `realm join`) rather than owning the whole
file, so sections those tools add stay, even under the `simp:defaults`
profile.

Because nothing is rendered as a whole file any more, upgrading leaves every
existing file in `/etc/sssd` in place, and a setting a later run stops
managing keeps its value.

### Restoring the earlier behavior

There are two ways to get the earlier behavior back.

1. **Enforce the `simp:defaults` profile.** The module ships a
   `simp:defaults` compliance_engine profile
   (`SIMP/compliance_profiles/`) that sets every parameter above back to its
   earlier value, per OS release. With the
   [compliance_engine](https://github.com/simp/rubygem-simp-compliance_engine)
   Hiera backend in your hierarchy, one key restores it:

   ```yaml
   compliance_engine::enforcement:
     - simp:defaults
   ```

   This is a drop-in restoration of the earlier behavior, including its
   destructive parts: it manages the service, and deletes `*_puppet_*.conf`
   snippets the catalog doesn't manage. Site Hiera outranks the profile, so
   to keep the earlier behavior but leave the stale snippets alone, add:

   ```yaml
   sssd::tidy_puppet_snippets: false
   ```

2. **Set the parameters you want.** For example, to manage the service and
   configure the `nss` and `pam` responders:

   ```yaml
   sssd::service::ensure: running
   sssd::service::enable: true
   sssd::services_entries:
     nss: {}
     pam: {}
   sssd::service::nss::filter_users: root
   sssd::service::pam::offline_failed_login_attempts: 3
   ```

Every `sssd::service::*` class is included, listed or not, so a responder
setting takes effect on its own; listing a responder in `services` is what
starts it. `sssd::service::sudo::socket_enable` and `manage_group_dropin_file`
are the exception: `true` is ignored while sudo is turned off in the services
list (`sudo: {ensure: absent}`, or a deprecated `sssd::services` without it),
so the profile doesn't start a responder a site dropped.

### Other changes

* `sssd::custom_config` is written to its own file,
  `/etc/sssd/conf.d/99999_puppet_custom_raw.conf` (`'absent'` removes it),
  which sorts after
  `99999_puppet_custom.conf` and so still wins over `sssd::custom_settings`.
  On a host upgraded from 10.x, `99999_puppet_custom.conf` keeps the raw
  content it was given before until you remove it, or until
  `sssd::tidy_puppet_snippets` does (when nothing else writes to it). If you
  also set `sssd::custom_settings`, which still writes to that file, the tidy
  never removes it, and SSSD keeps reading the old raw lines even after you
  change or remove `custom_config`. Delete the file once after upgrading;
  the next run writes the `custom_settings` back into it.
* `custom_options` on a `sssd::service::*` class still replaces the
  parameter-driven settings, but only those settings are managed: other
  settings in the section are no longer removed.
* `sssd::service::pam::pam_cert_auth => false` now writes
  `pam_cert_auth = False`, rather than leaving the setting out.
* `sssd::service::sudo::manage_group_dropin_file => false` now removes the
  drop-in; leave it `undef` to leave the drop-in alone.
* While `sssd::service::sudo::socket_enable` enables `sssd-sudo.socket`,
  `sudo` is removed from the `services` line, where tools such as
  `ipa-client-install` often put it, since the socket refuses to start while
  it is listed. Without the socket, a `sudo` entry is edited like any other.
* Every `sssd::service::*` class is now included, so declaring one
  resource-style (`class { 'sssd::service::ifp': ... }`) after `include sssd`
  fails with a duplicate declaration. Set its parameters in Hiera (preferred),
  or declare the class before `include sssd`.
* The `simple_allow_*` and `simple_deny_*` parameters of `sssd::domain` are
  left alone when a declaration drops them, so an allow list stays in force.
  Set one to `'absent'` to remove it.
* The `LOCAL` domain declared by `sssd::config::manage_base_domain` is no
  longer listed automatically; list it in `sssd::domains_entries`, as the
  `simp:defaults` profile does on EL10.
* The `[domain/...]` sections written by `sssd::domain` and the
  `sssd::provider::*` defines are edited in place too, so a setting a
  declaration no longer passes is left alone rather than removed. Their
  parameters keep their defaults: declaring one is itself the opt-in.

## This is a SIMP module

This module is a component of the [System Integrity Management Platform](https://simp-project.com),
a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net/).

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

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

Packages installed by a bare `include sssd`:
* sssd and sssd-dbus
* sssd-client (`sssd::install::install_client`)
* sssd-tools (`sssd::install::install_user_tools`)

Only when the corresponding parameters are set:
* individual settings in /etc/sssd/sssd.conf and in snippets in
  /etc/sssd/conf.d, along with the ownership and permissions SSSD requires of
  those files
* the /etc/sssd and /etc/sssd/conf.d directory modes
* the sssd service and the sssd-sudo.socket unit
* /etc/pki/simp_apps/sssd/x509 with `simp/pki` enabled

## Usage

### Beginning with SIMP SSSD

The following installs the SSSD packages, and nothing else until you set
parameters (or enforce the `simp:defaults` profile, see
[Restoring the earlier behavior](#restoring-the-earlier-behavior)):

```puppet
include sssd
```

To enable integration with the existing SIMP PKI module, set the
value of the PKI SIMP option to true:

This will use the simp pki certificate distribution mechanism and set the
pki values accordingly in the ldap provider.

```yaml
simp_options::pki: true
```

To enable integration with the simp auditd module, set the
value of AUDITD SIMP option to true:

```yaml
simp_options::auditd: true
```

### Creating Domains and Providers

To create an SSSD domain you must instantiate a sssd::domain defined type and
add the domain name to the domains in hiera:

In hiera:

```yaml
sssd::domains_entries:
  ldapusers: {}
  LOCAL: {}
```

Create a manifest:

```puppet
sssd::domain { 'ldapusers':
  id_provider     => 'ldap',
  auth_provider   => 'krb5',
  access_provider => 'krb5',
  ...etc
}

sssd::domain { 'LOCAL':
  id_provider => 'local',
  ...etc
}
```

To include configuration options for the providers of the SSSD domain, you must
instantiate the provider type with the same name as the domain it applies to.
For example, to set options for the  ldap and krb5 providers for the ``ldapusers``
domain defined above use the following:

```puppet
sssd::provider::ldap { 'ldapusers':
  ldap_access_filter => 'memberOf=cn=allowedusers,ou=Groups,dc=example,dc=com',
  ldap_chpass_uri    => empty,
  ldap_access_order  => 'expire',
  ...etc
}

sssd::provider::krb5 { 'ldapusers':
  krb5_server   => 'my.kerberos.server',
  krb5_realm    => 'mykrbrealm',
  krb5_password => lookup('use_eyaml'),
  ...etc
}
```

#### More examples

##### Enabling Local Users

Using the `LOCAL` provider is supported for EL6 but has been deprecated by the
vendor and is not recommended for use so is not documented here.

On EL8 and EL9, SSSD provides an implicit files domain:

```yaml
---
sssd::enable_files_domain: true
```

SSSD 2.10 (EL10) removed it. There, declare a `LOCAL` proxy domain for the
local files instead, and list it in `domains`:

```yaml
---
sssd::config::manage_base_domain: true
sssd::domains_entries:
  LOCAL: {}
```

More information can be found in `sssd-files(5)` and `sssd-proxy(5)`.

##### Using LDAP (Generic)

This should work with any general LDAP server, OpenLDAP, 389DS, etc...

```puppet
sssd::domain { 'my_ldap':
  description       => 'LDAP Users',
  id_provider       => 'ldap',
  auth_provider     => 'ldap',
  chpass_provider   => 'ldap',
  access_provider   => 'ldap',
  sudo_provider     => 'ldap',
  autofs_provider   => 'ldap',
  min_id            => 500,
  cache_credentials => true
}

sssd::provider::ldap { 'my_ldap':
  ldap_default_authtok_type => 'password',
  ldap_user_gecos           => 'dn'
}
```

##### Using FreeIPA or Red Hat Directory Server

With `sssd::auto_add_ipa_domain: true` (set by the `simp:defaults` profile),
the `sssd` class configures SSSD for the IPA domain the host is joined to.
To manage this configuration yourself, leave it `false` and configure the
domain and `ipa` provider as follows

```puppet
sssd::domain { 'my.domain':
  description       => "IPA Domain my.domain",
  id_provider       => 'ipa',
  auth_provider     => 'ipa',
  chpass_provider   => 'ipa',
  access_provider   => 'ipa',
  sudo_provider     => 'ipa',
  autofs_provider   => 'ipa',
}

sssd::provider::ipa { 'my.domain':
  ipa_domain => 'my.domain'
  ipa_server => [ 'ipaserver.my.domain' ]
}
```

##### Using Active Directory

For `sssd` to properly function with AD, you will need to join the system to the
domain in whatever method suits your environment. There are several modules
containing relevant tasks but this is technically outside of the realm of `sssd`
so not included here.

```puppet
$_my_ad_domain = 'test.domain'

# You may need to adjust these parameters for your exact environment but these
# should work for general use.

sssd::domain { $_my_ad_domain:
  access_provider           => 'ad',
  cache_credentials         => true,
  id_provider               => 'ad',
  realmd_tags               => 'manages-system joined-with-samba',
  case_sensitive            => true,
  max_id                    => 0,
  ignore_group_members      => true,
  use_fully_qualified_names => true
}

sssd::provider::ad { $_my_ad_domain:
  ad_domain                      => $_my_ad_domain,
  ad_servers                     => ["ad.${_my_ad_domain}"],
  ldap_id_mapping                => true,
  ldap_schema                    => 'ad',
  krb5_realm                     => upcase($_my_ad_domain),
  dyndns_update                  => true,
  default_shell                  => '/bin/bash',
  fallback_homedir               => '/home/%u@%d',
  krb5_store_password_if_offline => true
}
```

###### Restricting Access with the `simple` Access Provider

The example above uses `access_provider => 'ad'`, which evaluates the
GPO-based access control rules published by the domain.  To instead allow only
specific AD groups to log in, switch that domain to the `simple` access
provider and list the groups in `simple_allow_groups`.

This *amends* the `sssd::domain` resource declared above rather than adding a
second one — declaring both as written would fail with `Duplicate declaration:
Sssd::Domain[test.domain]`.  Change these lines:

```diff
 sssd::domain { $_my_ad_domain:
-  access_provider           => 'ad',
+  access_provider           => 'simple',
+  simple_allow_groups       => ['linux-admins', 'linux-users'],
   cache_credentials         => true,
   id_provider               => 'ad',
```

`simple_allow_users`, `simple_deny_users` and `simple_deny_groups` work the
same way; each renders as the comma-separated list that `sssd-simple(5)`
expects, is left alone when unset or set to an empty list, and is removed when
set to `'absent'`.  Dropping one from a declaration leaves it in force, so set
it to `'absent'` to revoke access.  `sssd.conf`
provides no way to quote or escape a comma, so a user or group name containing
one cannot be expressed here and is rejected at compile time.  See
`sssd-simple(5)` for how the allow and deny lists interact.

Any domain option the define does not expose as a parameter can still be
supplied through `custom_options`.  On `sssd::domain` that hash is **added
to** the options generated by the other parameters, so it never discards
anything else the domain sets.  A value of `'absent'` removes that option.

> NOTE
>
> `custom_options` on the `sssd::service::*` classes works the other way
> around: there the hash *replaces* the parameter-driven configuration.  See
> [Using Services](#using-services).

### Using Services

The following services can be managed by `simp/sssd`.

* autofs
* ifp
* nss
* pac
* pam
* ssh
* sudo

Adding a service to `sssd::services_entries` lists it in the `services`
setting.  Each service's class, `sssd::service::`*\{service name\}*, is
included whether or not it is listed, and manages the settings whose
parameters you set in hiera.  Declare these classes through Hiera (or
before `include sssd`), since `sssd` includes every one of them.  While
`sssd::service::sudo::socket_enable` enables `sssd-sudo.socket`, `sudo` is
removed from `services`, because the socket won't start while it is listed;
without the socket, a listed `sudo` responder is started by sssd.

```yaml
  sssd::services_entries:
    nss: {}
    pam: {}
    autofs: {}
    ssh:
      ensure: absent
  sssd::service::autofs::autofs_negative_timeout: 15
```

The settings for the services have been known to change from one version of sssd
to the next.  To overcome this problem, a parameter, ``custom_options``  has been
added.  It accepts a hash of options for the service.  It will ignore the other
parameters in the service and manage only these settings.

```yaml
  sssd::service::nss::custom_options:
    description: 'The nss section of the config file'
    filter_users:  'root'
    filter_groups: 'root'
    reconnection_retries:  3
    mymissingparam: 'value'
```

> NOTE
>
> `custom_options` on `sssd::domain` behaves differently: there the hash is
> *added to* the options generated by the other parameters instead of
> replacing them.  See [Restricting Access with the simple Access
> Provider](#restricting-access-with-the-simple-access-provider).

### Applying changes when the service is unmanaged

The `sssd` service is only managed when `sssd::service::ensure` or
`sssd::service::enable` is set.  Otherwise configuration changes are written
to disk, but a running `sssd` doesn't read them until it is restarted:

```sh
sssctl config-check && systemctl restart sssd
```

# Development

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).
