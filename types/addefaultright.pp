#  List of valid types for AD Provider setting ad_gpo_default_right
type Sssd::ADDefaultRight = Enum[
  'interactive',
  'remote_interactive',
  'network',
  'batch',
  'service',
  'permit',
  'deny'
]
