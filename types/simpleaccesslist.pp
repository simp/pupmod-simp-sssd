# @summary A `simple` access provider list: the names, or `absent` to remove
#   the setting
type Sssd::SimpleAccessList = Variant[Array[Sssd::IniListItem], Enum['absent']]
