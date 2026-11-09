# Helpers for asserting on what sssd::config::entry will manage.
#
# sssd::config::entry edits each setting in place with an ini_setting, so a
# section's "content" is no longer a File resource. These render the settings
# an entry manages the way they appear in the section, which keeps the
# expectations readable.

# The `[section]` header and the `key = value` lines an Sssd::Config::Entry
# manages, in declaration order, followed by a newline. Settings left undef
# are not managed and settings set to 'absent' are removed, so neither is
# rendered.
def entry_content(title)
  entry = catalogue.resource('Sssd::Config::Entry', title)
  raise "Sssd::Config::Entry[#{title}] is not in the catalogue" unless entry

  lines = entry[:settings].reject { |_, value| value.nil? || value == :undef || value == 'absent' }.map do |setting, value|
    "#{setting} = #{value.is_a?(Array) ? value.join(', ') : value}"
  end

  (["[#{entry[:section]}]"] + lines).join("\n") + "\n"
end

# `eq` for a String, `match` for a Regexp
def content_matching(expected)
  expected.is_a?(Regexp) ? match(expected) : eq(expected)
end
