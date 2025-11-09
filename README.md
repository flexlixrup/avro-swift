# avro-swift

avro-swift is a native Swift library build to serialize and deserialize [Apache Avro™](https://avro.apache.org) data.

## Quick start

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

The full documentation is provided via DocC on [Swift Package Manager](https://swiftpackageindex.com/flexlixrup/avro-swift).

## Add to your project

To integrate `avro-swift` into your project using Swift Package Manager, follow these steps:

1. Open your project in Xcode.
2. Select `File` > `Swift Packages` > `Add Package Dependency...`.
3. Enter the package repository URL: `https://github.com/flexlixrup/avro-swift`.
4. Choose the latest release or specify a version range.
5. Add the package to your target.

Alternatively, you can add the following dependency to your `Package.swift` file:

```swift
dependencies: [
	.package(url: "https://github.com/flexlixrup/avro-swift", from: "0.0.1")
]
```

Then, include `Pulsar` as a dependency in your target:

```swift
.target(
	name: "YourTargetName",
	dependencies: [
		"Avro"
	]),
```

## Contributing

> [!WARNING]
> This package uses [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) to detect the semantic versioning. Commits not following this format will not be accepted.

If you would like to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Commit your changes (`git commit -am 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Create a new Pull Request.

