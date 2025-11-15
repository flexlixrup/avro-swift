//
//  EncodingTests.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import AvroFixtures
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

		let user = FlatRecordFixture.instance
		let avroData = try AvroEncoder(schema: FlatRecordFixture.Def.avroSchema).encode(user)

		#expect(avroData == FlatRecordFixture.serialized)
	}

	@Test("Nested record")
	func nestedRecord() throws {

		let value = NestedRecordFixture.instance

		let avroData = try AvroEncoder(schema: NestedRecordFixture.Def.avroSchema).encode(value)
		let expected = NestedRecordFixture.serialized

		#expect(avroData == expected)
	}

	@Test("Logical Type date")
	func logicalTypeDate() throws {
		let value = LogicalDateFixture.instance
		let avroData = try AvroEncoder(schema: LogicalDateFixture.Def.avroSchema).encode(value)
		let expected = LogicalDateFixture.serialized

		#expect(avroData == expected)
	}

	@Test("Logical Type time-millis", .disabled("Logical Type not implemented"))
	func logicalTypeTimeMillisEncode() throws {
		let value = LogicalTimeMillisFixture.instance
		let avroData = try AvroEncoder(schema: LogicalTimeMillisFixture.Def.avroSchema).encode(value)
		let expected = LogicalTimeMillisFixture.serialized

		#expect(avroData == expected)
	}

	@Test("Logical Type timestamp-millis", .disabled("Logical Type not implemented"))
	func logicalTypeTimestampMillisEncode() throws {
		let value = LogicalTimestampMillisFixture.instance
		let avroData = try AvroEncoder(schema: LogicalTimestampMillisFixture.Def.avroSchema).encode(value)
		let expected = LogicalTimestampMillisFixture.serialized

		#expect(avroData == expected)
	}

	@Test("Logical Type time-micros", .disabled("Logical Type not implemented"))
	func logicalTypeTimeMicrosEncode() throws {
		let value = LogicalTimeMicrosFixture.instance
		let avroData = try AvroEncoder(schema: LogicalTimeMicrosFixture.Def.avroSchema).encode(value)
		let expected = LogicalTimeMicrosFixture.serialized

		#expect(avroData == expected)
	}

	@Test("Logical Type timestamp-micros", .disabled("Logical Type not implemented"))
	func logicalTypeTimestampMicrosEncode() throws {
		let value = LogicalTimestampMicrosFixture.instance
		let avroData = try AvroEncoder(schema: LogicalTimestampMicrosFixture.Def.avroSchema).encode(value)
		let expected = LogicalTimestampMicrosFixture.serialized

		#expect(avroData == expected)
	}

	@Test("Logical Type uuid", .disabled("Logical Type not implemented"))
	func logicalTypeUUIDEncode() throws {
		let value = LogicalUUIDFixture.instance
		let avroData = try AvroEncoder(schema: LogicalUUIDFixture.Def.avroSchema).encode(value)
		let expected = LogicalUUIDFixture.serialized

		#expect(avroData == expected)
	}

	@Test("Logical Type decimal", .disabled("Logical Type not implemented"))
	func logicalTypeDecimalEncode() throws {
		let value = LogicalDecimalFixture.instance
		let avroData = try AvroEncoder(schema: LogicalDecimalFixture.Def.avroSchema).encode(value)
		let expected = LogicalDecimalFixture.serialized

		#expect(avroData == expected)
	}

	@Test("Array record")
	func arrayOfStringsEncode() throws {
		let value = ArrayFixture.instance
		let avroData = try AvroEncoder(schema: ArrayFixture.Def.avroSchema).encode(value)
		let expected = ArrayFixture.serialized
		#expect(avroData == expected)
	}

	@Test("Double Array record")
	func doubleArrayEncode() throws {
		let value = DoubleArrayFixture.instance
		let avroData = try AvroEncoder(schema: DoubleArrayFixture.Def.avroSchema).encode(value)
		let expected = DoubleArrayFixture.serialized
		#expect(avroData == expected)
	}

	@Test("Map record")
	func mapEncode() throws {
		let value = MapFixture.instance
		let avroData = try AvroEncoder(schema: MapFixture.Def.avroSchema).encode(value)
		let expected = MapFixture.serialized
		#expect(avroData.sorted() == expected.sorted())
	}

	@Test("Complex Record")
	func complexRecord() throws {
		let value = ComplexFixture.instance
		let avroData = try AvroEncoder(schema: ComplexFixture.Def.avroSchema).encode(value)
		let expected = ComplexFixture.serialized
		#expect(avroData.sorted() == expected.sorted())
	}
}
