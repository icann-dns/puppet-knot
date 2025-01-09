# @summary Define a zonemd_generate in Knot DNS
type Knot::Zonemd_generate = Enum[
  none,
  zonemd-sha384,
  zonemd-sha512,
  remove,
]
