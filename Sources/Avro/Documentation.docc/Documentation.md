# ``Avro``

avro-swift is a native Swift library build to serialize and deserialize Apache Avro™ data.

## Overview

The library encodes and decoded `Codable` structs and classes according to the [Apache Avro™](https://avro.apache.org) spec.
It makes use of macros to auto-generate avro-schemas from these objects. With a schema at hand, you can decode from `Data` and encode to `Data`.

Example:

```swift
import Avro

@Schema
struct User: Codable {
	let name: String
	let age: Int
	@LogicalType(.date) let dob: Date
	let username: String
	let address: Address
}

@Schema
struct Address: Codable {
	let street: String
}

let user = User(name: "John Doe", age: 22, dob: Date(), username: "johndoe", address: Address(street: "John Doe Street"))
let decodedAvro = try AvroEncoder(schema: User.avroSchema).encode(user)
let roundTrip = try AvroDecoder(schema: User.avroSchema).decode(User.self, from: decodedAvro)
```


## Topics

### Schema

- ``AvroSchema``
