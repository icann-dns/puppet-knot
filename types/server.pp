type Knot::Server = Struct[{
  address4          => Optional[Variant[Tea::Ipv4, Tea::Ipv4_cidr]],
  address6          => Optional[Variant[Tea::Ipv6, Tea::Ipv6_cidr]],
  fetch_tsig_name   => Optional[String],
  provide_tsig_name => Optional[String],
}]
