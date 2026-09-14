# Render structured configuration data as ``sssd.conf``-style INI content.
#
# Sections and settings are emitted in Hash insertion order, so the output is
# deterministic.  Settings with an ``undef`` value are omitted, and ``Array``
# values are rendered as comma-separated lists.
#
# A section with no settings left to render is omitted entirely, so an empty
# Hash -- or one whose every setting is ``undef`` -- does not leave a bare
# ``[section]`` header behind.
#
# The returned String has no trailing newline; callers add one if the
# destination needs it.
#
# @param settings
#   The sections to render
#
# @return [String]
#
# @example
#   sssd::to_ini({ 'nss' => { 'filter_users' => ['root','named'] } })
#
#   # => "[nss]\nfilter_users = root, named"
#
function sssd::to_ini (
  Sssd::IniSettings $settings,
) >> String {
  $settings.reduce([]) |$memo, $section| {
    $_lines = $section[1].filter |$_setting, $_value| {
      $_value =~ NotUndef
    }.map |$_setting, $_value| {
      $_rendered = $_value ? {
        Array   => $_value.join(', '),
        default => String($_value),
      }

      "${_setting} = ${_rendered}"
    }

    empty($_lines) ? {
      true    => $memo,
      default => $memo + ["[${section[0]}]"] + $_lines,
    }
  }.join("\n")
}
