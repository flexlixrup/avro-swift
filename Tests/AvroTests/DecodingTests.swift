//
//  DecodingTests.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import AvroFixtures
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
}

@Suite("Record Decoding Tests")
struct RecordDecodingTests {

	@Test("Record primitives")
	func recordPrimitives() throws {
		let data = FlatRecordFixture.serialized
		let user = FlatRecordFixture.instance
		let schema = FlatRecordFixture.Def.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(FlatRecordFixture.Def.self, from: data)
		#expect(decodedAvro == user)
	}

	@Test("Nested record")
	func nestedRecord() throws {
		let data = NestedRecordFixture.serialized

		let user = NestedRecordFixture.instance

		let schema = NestedRecordFixture.Def.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(NestedRecordFixture.Def.self, from: data)
		#expect(decodedAvro == user)
	}

	@Test("Logical Type Date")
	func logicalTypeDate() throws {
		let data = LogicalDateFixture.serialized

		let person = LogicalDateFixture.instance

		let schema = LogicalDateFixture.Def.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(LogicalDateFixture.Def.self, from: data)
		#expect(decodedAvro == person)

	}

	@Test("Logical Type time-millis", .disabled("Logical Type not implemented"))
	func logicalTypeTimeMillis() throws {
		let data = LogicalTimeMillisFixture.serialized

		let person = LogicalTimeMillisFixture.instance

		let schema = LogicalTimeMillisFixture.Def.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(LogicalTimeMillisFixture.Def.self, from: data)
		#expect(decodedAvro == person)

	}

	@Test("Logical Type timestamp-millis", .disabled("Logical Type not implemented"))
	func logicalTypeTimestampMillis() throws {
		let data = LogicalTimestampMillisFixture.serialized

		let person = LogicalTimestampMillisFixture.instance

		let schema = LogicalTimestampMillisFixture.Def.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(LogicalTimestampMillisFixture.Def.self, from: data)
		#expect(decodedAvro == person)

	}

	@Test("Logical Type time-micros", .disabled("Logical Type not implemented"))
	func logicalTypeTimeMicros() throws {
		let data = LogicalTimeMicrosFixture.serialized

		let person = LogicalTimeMicrosFixture.instance

		let schema = LogicalTimeMicrosFixture.Def.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(LogicalTimeMicrosFixture.Def.self, from: data)
		#expect(decodedAvro == person)

	}

	@Test("Logical Type timestamp-micros", .disabled("Logical Type not implemented"))
	func logicalTypeTimestampMicros() throws {
		let data = LogicalTimestampMicrosFixture.serialized

		let person = LogicalTimestampMicrosFixture.instance

		let schema = LogicalTimestampMicrosFixture.Def.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(LogicalTimestampMicrosFixture.Def.self, from: data)
		#expect(decodedAvro == person)

	}

	@Test("Logical Type uuid", .disabled("Logical Type not implemented"))
	func logicalTypeUUID() throws {
		let data = LogicalUUIDFixture.serialized

		let person = LogicalUUIDFixture.instance

		let schema = LogicalUUIDFixture.Def.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(LogicalUUIDFixture.Def.self, from: data)
		#expect(decodedAvro == person)

	}

	@Test("Logical Type decimal", .disabled("Logical Type not implemented"))
	func logicalTypeDecimal() throws {
		let data = LogicalDecimalFixture.serialized

		let person = LogicalDecimalFixture.instance

		let schema = LogicalDecimalFixture.Def.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(LogicalDecimalFixture.Def.self, from: data)
		#expect(decodedAvro == person)
	}

	@Test("Array record")
	func arrayOfStringsDecode() throws {
		let data = ArrayFixture.serialized

		let value = ArrayFixture.instance

		let schema = ArrayFixture.Def.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(ArrayFixture.Def.self, from: data)
		#expect(decodedAvro == value)
	}

	@Test("Double Array record")
	func doubleArrayDecode() throws {
		let data = DoubleArrayFixture.serialized

		let value = DoubleArrayFixture.instance

		let schema = DoubleArrayFixture.Def.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(DoubleArrayFixture.Def.self, from: data)
		#expect(decodedAvro == value)
	}

	@Test("Map record")
	func mapRecord() throws {
		let data = MapFixture.serialized
		let value = MapFixture.instance
		let schema = MapFixture.Def.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(MapFixture.Def.self, from: data)
		#expect(decodedAvro == value)
	}

	@Test("Complex record")
	func complexRecord() throws {
		let data = ComplexFixture.serialized
		let value = ComplexFixture.instance
		let schema = ComplexFixture.Def.avroSchema
		let decodedAvro = try AvroDecoder(schema: schema).decode(ComplexFixture.Def.self, from: data)
		#expect(decodedAvro == value)

	}
}
