[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/sssd.svg)](https://forge.puppetlabs.com/simp/sssd)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/sssd.svg)](https://forge.puppetlabs.com/simp/sssd)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-sssd.svg)](https://travis-ci.org/simp/pupmod-simp-sssd)

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

This module installs and manages SSSD. It allows you to set configuration
options in sssd.conf through puppet / hiera.

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

Files managed by `simp/sssd`:
* /etc/sssd/sssd.conf
* /etc/init.d/sssd
* (Optional) /etc/sssd/pki with `simp/pki` enabled

Services and operations managed or affected:
* sssd (running)
* nscd (stopped)

Packages installed:
* sssd (latest by Default)
* sssd-tools (optionally, latest by Default)
* sssd-dbus (optionally, if ifp is included in sssd::services)

## Usage

### Beginning with SIMP SSSD

The following will install and manage the service for SSSD.
It will configure the services defined in sssd::services
(by default nss, pam, ssh and sudo.)  If the host is joined to an
IPA domain it will  configure SSSD for the IPA domain.  Otherwise
the module does not create sssd domains or providers automatically.
If the host is EL6 or EL7 the module will fail if you do not create
a sssd domain.

``` puppet
include ::sssd
```
or

``` yaml
classes:
  - sssd
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
add the domain name to the array of domains in hiera:

In hiera:

``` yaml
sssd::domains: ['ldapusers', 'LOCAL']
```

Create a manifest:

``` puppet
sssd::domain { 'ldapusers':
  id_provider => 'ldap',
  auth_provider => 'krb5',
  access_provider => 'krb5',
  ...
}

sssd::domain { 'LOCAL':
  id_provider => 'local',
  ...
}
```

To include configuration options for the providers of the SSSD domain, you must
instantiate the provider type with the same name as the domain it applies to.
For example, to set options for the  ldap and krb5 providers for the ``ldapusers``
domain defined above use the following:

``` puppet
sssd::provider::ldap { 'ldapusers':
  ldap_access_filter => 'memberOf=cn=allowedusers,ou=Groups,dc=example,dc=com',
  ldap_chpass_uri    => empty,
  ldap_access_order  => 'expire',
  ...etc
}

sssd::provider::krb5 { 'ldapusers':
  krb5_server    => 'my.kerberos.server',
  krb5_realm     => 'mykrbrealm',
  krb5_password  => lookup('use_eyaml'),
  ...etc
}
```

#### More examples
##### I want to use local users

```puppet
sssd::domain { 'localusers':
  id_provider => 'local',
  ...
}
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
#### I want to use IPA users

The `sssd` class, by default, configures SSSD for an IPA domain,
when the host is joined to an IPA domain.  If you want to manage this
configuration yourself, set `sssd::auto_add_ipa_domain` to false.
Then, configure the domain and `ipa` provider as follows

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

### Using Services

The following services can be managed by `simp/sssd`.

* autofs
* ifp
* nss
* pac
* pam
* ssh
* sudo

Adding a service to the array of services in sssd::services will
configure it using the defaults from its module, sssd::service::*\{service name\}* .
Use hiera to override the defaults.

``` yaml
  sssd::services: [ 'nss', 'pam', 'autofs']
```

The settings for the services have been known to change from one version of sssd
to the next.  To overcome this problem, a parameter, ``custom_options``  has been
added.  It accepts a hash of options for the service.  It will ignore the other
parameters in the service and use only these so you must add all options
that differ from the system defaults.

``` yaml
  sssd::service::nss::custom_options:
    description: 'The nss section of the config file'
    filter_users:  'root'
    filter_groups: 'root'
    reconnection_retries:  3
    mymissingparam: 'value'
```

## Limitations

This module is only designed to work in RHEL or CentOS 6 and 7. Any other
operating systems have not been tested and results cannot be guaranteed.

# Development

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).
