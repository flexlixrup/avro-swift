//
//  DecodingTests.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Foundation
import Testing

@testable import Avro

@Suite("Primitive Decoding Tests")
struct PrimitiveDecodingTestss {

	@Test("String schema decoding")
	func stringSchemaDecoding() throws {
		let data = Data([6, 0x66, 0x6f, 0x6f])
		let schema: AvroSchema = .string
		let decodedAvro = try AvroDecoder(schema: schema).decode(String.self, from: data)
		#expect(decodedAvro == "foo")
	}

	@Test("Record primitives")
	func recordPrimitives() throws {
		let data = Data([
			0x54, 0x06, 0x41, 0x64, 0x61, 0x1e, 0x61, 0x64, 0x61, 0x40, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x2e, 0x63,
			0x6f, 0x6d
		])
		let user = User(id: 42, name: "Ada", email: "ada@example.com")
		let schema = User.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(User.self, from: data)
		#expect(decodedAvro == user)
	}

	@Test("Nested record")
	func nestedRecord() throws {
		let data = Data([
			0x54, 0x06, 0x41, 0x64, 0x61, 0x1e, 0x61, 0x64, 0x61, 0x40, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x2e, 0x63,
			0x6f, 0x6d, 0x18, 0x31, 0x20, 0x48, 0x61, 0x63, 0x6b, 0x65, 0x72, 0x20, 0x57, 0x61, 0x79, 0x0c, 0x42, 0x65, 0x72,
			0x6c, 0x69, 0x6e, 0x86, 0x9e, 0x01
		])

		let user = UserWithAddress(
			id: 42,
			name: "Ada",
			email: "ada@example.com",
			address: Address(
				street: "1 Hacker Way",
				city: "Berlin",
				zip: 10115
			)
		)

		let schema = UserWithAddress.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(UserWithAddress.self, from: data)
		#expect(decodedAvro == user)
	}
}
