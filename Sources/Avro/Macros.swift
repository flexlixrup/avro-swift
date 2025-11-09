@attached(member, names: arbitrary)
public macro Schema() = #externalMacro(module: "AvroMacros", type: "GenerateAvroSchema")

@attached(peer)
public macro LogicalType(_ name: AvroSchema.LogicalType) = #externalMacro(module: "AvroMacros", type: "LogicalTypeAttribute")
