# @summary The name of a section in an ``sssd.conf``-style file
#
# Covers the plain sections (``sssd``, ``nss``, ``pam``, ...) as well as the
# path-style sections that SSSD uses for domains and rules
# (``domain/EXAMPLE.COM``, ``certmap/EXAMPLE.COM/rule1``,
# ``prompting/2fa/sshd``, ...).
#
# The brackets that delimit the section header in the file itself are added by
# the renderer and are not part of the name.
type Sssd::IniSectionName = Pattern[/\A[a-z][a-z0-9_]*(\/[^\[\]\n\/]+){0,2}\z/]
