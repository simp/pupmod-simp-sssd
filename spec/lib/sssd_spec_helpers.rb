# Helpers for asserting on what sssd::config::entry will manage.
#
# sssd::config::entry edits each setting in place with an ini_setting, so a
# section's "content" is no longer a File resource. These render the
# ini_setting resources an entry declares the way they appear in the section,
# which keeps the expectations readable while still testing what reaches the
# node.

# The ini_setting resources an Sssd::Config::Entry contains, in declaration
# order.
def entry_ini_settings(title)
  entry = catalogue.resource('Sssd::Config::Entry', title)
  raise "Sssd::Config::Entry[#{title}] is not in the catalogue" unless entry

  catalogue.adjacent(entry, direction: :out).select { |r| r.type == 'Ini_setting' }
end

# The `[section]` header and the `key = value` lines an Sssd::Config::Entry
# writes, in declaration order, followed by a newline. Settings it removes
# ('absent') are not rendered.
def entry_content(title)
  entry = catalogue.resource('Sssd::Config::Entry', title)
  settings = entry_ini_settings(title)

  sections = settings.map { |r| r[:section] }.uniq
  raise "Sssd::Config::Entry[#{title}] edits sections #{sections} instead of [#{entry[:section]}]" unless (sections - [entry[:section]]).empty?

  lines = settings.select { |r| r[:ensure] == 'present' }.map { |r| "#{r[:setting]} = #{r[:value]}" }

  (["[#{entry[:section]}]"] + lines).join("\n") + "\n"
end

# `eq` for a String, `match` for a Regexp
def content_matching(expected)
  expected.is_a?(Regexp) ? match(expected) : eq(expected)
end
