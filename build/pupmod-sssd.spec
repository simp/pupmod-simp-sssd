Summary: SSSD Puppet Module
Name: pupmod-sssd
Version: 4.1.0
Release: 6
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: pupmod-auditd >= 4.1.0-3
Requires: pupmod-common >= 4.2.0-0
Requires: pupmod-concat >= 4.0.0-0
Requires: puppet >= 3.3.0
Requires: simp_bootstrap >= 4.1.0-2
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Obsoletes: pupmod-sssd-test

Prefix: /etc/puppet/environments/simp/modules

%description
This Puppet module manages the configuration of the System Security Services
Daemon (SSSD).

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/sssd

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/sssd
done

mkdir -p %{buildroot}/usr/share/simp/tests/modules/sssd

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/sssd

%files
%defattr(0640,root,puppet,0750)
%{prefix}/sssd

%post
#!/bin/sh

if [ -d %{prefix}/sssd/plugins ]; then
  /bin/mv %{prefix}/sssd/plugins %{prefix}/sssd/plugins.bak
fi

%postun
# Post uninitall stuff

%changelog
* Thu Apr 02 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-7
- Fixed variable references in some templates.

* Thu Feb 19 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-6
- Migrated to the new 'simp' environment.

* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-4
- Changed puppet-server requirement to puppet

* Thu Nov 06 2014 Chris Tessmer <ctessmer@onyxpoint.com> - 4.1.0-3
- Remove sssd::conf as it is no longer needed and causes duplicate
  concat_fragment error

* Fri Oct 17 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-2
- CVE-2014-3566: Updated cipher suites to help mitigate POODLE.

- The tls_cipher_suite variable is set to HIGH:-SSLv2 because OpenLDAP
  cannot set the SSL provider natively. By default, it will run TLSv1
  but cannot handle TLSv1.2 therefore the SSLv3 ciphers cannot be
  eliminated. Take care to ensure that your clients only connect with
  TLSv1 if possible.

* Sun Jun 22 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-1
- Removed MD5 file checksums for FIPS compliance.

* Mon Apr 14 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-0
- Refactored manifests to pass all lint tests.
- Removed all singleton defines.
- Added spec tests.

* Fri Apr 04 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-0
- Added some validation and removed the 'stock' class. It now resides in the
  'simp' module.
- Collapsed the sssd::conf class into sssd.

* Thu Feb 13 2014 Kendall Moore <kmoore@keywcorp.com> - 4.0.0-1
- Converted all string booleans to native booleans.

* Fri Oct 25 2013 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-0
- Updated all 'source' File parameters to use the modules directory
  for Puppet 3 compatibility.

* Mon Oct 07 2013 Kendall Moore <kmoore@keywcorp.com> 2.0.0-8
- Updated all erb templates to properly scope variables.

* Mon Jan 07 2013 Maintenance
2.0.0-7
- Created a Cucumber test to toggle the sssd flag to true and ensure that the
  sssd service is running and the nscd service is stopped.

* Thu Jun 07 2012 Maintenance
2.0.0-6
- Ensure that Arrays in templates are flattened.
- Call facts as instance variables.
- Moved mit-tests to /usr/share/simp...
- Updated pp files to better meet Puppet's recommended style guide.

* Fri Mar 02 2012 Maintenance
2.0.0-5
- Improved test stubs.

* Mon Dec 26 2011 Maintenance
2.0-4
- Updated the spec file to not require a separate file list.

* Mon Oct 03 2011 Maintenance
2.0-3
- Updates to work around the fact that the latest version of SSSD will silently
  allow expired users to access the system due to bugs in the way it works with
  OpenLDAP.

* Fri Jul 15 2011 Maintenance
2.0-2
- Ensure that the minimum uid for LDAP is set to 501 by default.

* Wed May 25 2011 Maintenance - 2.0.0-1
- Updated to fix a bug where nscd was not getting shut down at boot time and
  sssd was not triggered to start.

* Tue Apr 05 2011 Maintenance - 2.0.0-0
- Initial offering of the SSSD module.
- The use requires the $use_sssd variable to be set to 'true' within scope.
