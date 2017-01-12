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

## This is a SIMP module
This module is a component of the
[System Integrity Management Platform](https://github.com/NationalSecurityAgency/SIMP),
a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net/).

Please read our [Contribution Guide](https://simp-project.atlassian.net/wiki/display/SD/Contributing+to+SIMP)
and visit our [developer wiki](https://simp-project.atlassian.net/wiki/display/SD/SIMP+Development+Home).

## Module Description

This module installs, configures and manages SSSD. It is also cross compatible
with `simp/pki` and `simp/auditd`.

It allows connection via krb5, ldap and local authentication.

`simp/sssd` also connects to autofs, nss, pac, pam, ssh, and sudo.

## Setup

### What simp sssd  affects

Files managed by `simp/sssd`:
* /etc/sssd/sssd.conf
* /etc/init.d/sssd
* (Optional) /etc/sssd/pki with `simp/pki` enabled

Services and operations managed or affected:
* sssd (running)
* nscd (stopped)

Packages installed by `simp/pki`:
* sssd (latest by default)

### Setup Requirements

Hiera values to use additional SIMP compontents:

To enable PKI

```yaml
simp_options::pki: true
```

### Beginning with SIMP SSSD

The following will install and manage the service for SSSD, but will include no
providers or affected services

```puppet
include ::sssd
```

or

```yaml
classes:
  - sssd
```

## Usage

### User Providers

#### I want to use local users

```puppet
class sssd::provider::local {'localusers':
  default_shell  => '/bin/bash',
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

Please see sssd::provider::ldap for all available LDAP options

#### I want to use Kerberos

This will provide a basic connection to Kerberos

```puppet
sssd::provider::krb5 {'kerberos':
  krb5_server    => 'my.kerberos.server',
  krb5_realm     => 'mykrbrealm',
  krb5_password  => hiera('use_eyaml'),
}
```

### Services

The following services can be managed by `simp/sssd`:
* autofs
* nss
* pac
* pam
* ssh
* sudo

Please see sssd::service::<class> for more options on configuration

## Reference

### Public Classes

* sssd
* sssd::domain
* sssd::service
* sssd::install
* sssd::install::client
* sssd::provider::krb5
* sssd::provider::ldap
* sssd::provider::local
* sssd::service::autofs
* sssd::service::nss
* sssd::service::pac
* sssd::service::pam
* sssd::service::ssh
* sssd::service::sudo

### Private Classes
* sssd::pki

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
