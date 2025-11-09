//
//  EncodingTests.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Foundation
import Testing

@testable import Avro

@Suite("Primitive Encoding Tests")
struct PrimitiveEncodingTests {

	@Test("String schema encoding")
	func stringSchemaEncoding() throws {
		let schema: AvroSchema = .string
		let value = "foo"
		let avroData = try AvroEncoder(schema: schema).encode(value)
		#expect(avroData == Data([6, 0x66, 0x6f, 0x6f]))
	}
}

@Suite("Record Encoding Tests")
struct RecordEncodingTests {

	@Test("Record primitives")
	func recordPrimitives() throws {

		let user = User(id: 42, name: "Ada", email: "ada@example.com")
		let avroData = try AvroEncoder(schema: User.avroSchema).encode(user)
		let expected = Data([
			0x54, 0x06, 0x41, 0x64, 0x61, 0x1e, 0x61, 0x64, 0x61, 0x40, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x2e, 0x63,
			0x6f, 0x6d
		])
		#expect(avroData == expected)
	}

	@Test("Nested record")
	func nestedRecord() throws {

		let value = UserWithAddress(
			id: 42,
			name: "Ada",
			email: "ada@example.com",
			address: Address(
				street: "1 Hacker Way",
				city: "Berlin",
				zip: 10115
			)
		)

		let avroData = try AvroEncoder(schema: UserWithAddress.avroSchema).encode(value)
		let expected = Data([
			0x54, 0x06, 0x41, 0x64, 0x61, 0x1e, 0x61, 0x64, 0x61, 0x40, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x2e, 0x63,
			0x6f, 0x6d, 0x18, 0x31, 0x20, 0x48, 0x61, 0x63, 0x6b, 0x65, 0x72, 0x20, 0x57, 0x61, 0x79, 0x0c, 0x42, 0x65, 0x72,
			0x6c, 0x69, 0x6e, 0x86, 0x9e, 0x01
		])

		#expect(avroData == expected)
	}

	@Test("Logical Type date")
	func logicalTypeDate() throws {
		let value = Person(name: "Ada", dateOfBirth: Date(timeIntervalSince1970: 364 * 86_400))
		let avroData = try AvroEncoder(schema: Person.avroSchema).encode(value)
		let expected = Data([0x06, 0x41, 0x64, 0x61, 0xd8, 0x05])

		#expect(avroData == expected)
	}
}
