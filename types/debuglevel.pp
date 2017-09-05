# Integer[0-9] or 2 byte Hexidecimal (ex. 0x0201)
type Sssd::DebugLevel = Variant[Integer[0,9],Pattern[/0x\h{4}$/]]
