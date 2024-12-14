#
# Return the version of sssd installed on the system.
#
Facter.add('sssd_version') do
  sssd = Facter::Core::Execution.which('sssd')
  confine { sssd }

  setcode do
    `sssd --version`.strip
  end
end
