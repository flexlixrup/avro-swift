//
//  Fixtures.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Avro
import Foundation

enum FlatRecordFixture {
	@Schema
	struct Def: Codable, Equatable {

		let id: Int64
		let name: String
		let email: String
	}

	static let schema: AvroSchema = .record(
		name: "User",
		fields: [
			.init(name: "id", type: .long),
			.init(name: "name", type: .string),
			.init(name: "email", type: .string)
		]
	)

	static let avroSchemaString = """
		  {
			"type": "record",
		 "name": "User",
		 "fields": [
		   {
			 "name": "id",
			 "type": "long"
		   },
		   {
			 "name": "name",
			 "type": "name"
		   },
		   {
			 "name": "email",
			 "type": "string"
		   }
		 ]
		}
		"""
	static let instance = Def(id: 42, name: "Ada", email: "ada@example.com")
	static let serialized = Data([
		0x54, 0x06, 0x41, 0x64, 0x61, 0x1e, 0x61, 0x64, 0x61, 0x40, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x2e, 0x63,
		0x6f, 0x6d
	])

}

enum LogicalDateFixture {

	@Schema
	struct Def: Codable, Equatable {
		let name: String
		@LogicalType(.date)
		let dateOfBirth: Date
	}

	static let schema: AvroSchema = .record(
		name: "Person",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "dateOfBirth", type: .logical(type: .date, underlying: .int))
		]
	)

	static let avroSchemaString = """
		  {
			"type": "record",
		 "name": "Person",
		 "fields": [
		   {
			 "name": "name",
			 "type": "string"
		   },
		   {
			 "name": "dateOfBirth",
			 "type": "int",
			 "logicalType": "date"
		   }
		 ]
		}
		"""

	static let instance = Def(name: "Ada", dateOfBirth: Date(timeIntervalSince1970: 364 * 86_400))
	static let serialized = Data([0x06, 0x41, 0x64, 0x61, 0xd8, 0x05])

}

enum LogicalTimeMillisFixture {

	@Schema
	struct Def: Codable, Equatable {
		let name: String
		@LogicalType(.timeMillis)
		let timeOfDay: Int
	}

	static let schema: AvroSchema = .record(
		name: "TimeOfDay",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "timeOfDay", type: .logical(type: .timeMillis, underlying: .int))
		]
	)

	static let avroSchemaString = """
			{
				"type": "record",
		 "name": "TimeOfDay",
		 "fields": [
			 {
				 "name": "name",
				 "type": "string"
			 },
			 {
				 "name": "timeOfDay",
				 "type": "int",
				 "logicalType": "time-millis"
			 }
		 ]
		}
		"""

	static let instance = Def(name: "Ada", timeOfDay: 12)
	static let serialized = Data([0x06, 0x41, 0x64, 0x61, 0x18])

}

enum LogicalTimestampMillisFixture {

	@Schema
	struct Def: Codable, Equatable {
		let name: String
		@LogicalType(.timestampMillis)
		let timestamp: Date
	}

	static let schema: AvroSchema = .record(
		name: "TimestampRecord",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "timestamp", type: .logical(type: .timestampMillis, underlying: .long))
		]
	)

	static let avroSchemaString = """
			{
				"type": "record",
		 "name": "TimestampRecord",
		 "fields": [
			 {
				 "name": "name",
				 "type": "string"
			 },
			 {
				 "name": "timestamp",
				 "type": "long",
				 "logicalType": "timestamp-millis"
			 }
		 ]
		}
		"""

	static let instance = Def(name: "Ada", timestamp: Date(timeIntervalSince1970: 1_700_000_000))
	static let serialized = Data([0x06, 0x41, 0x64, 0x61, 0x80, 0xa0, 0xab, 0xfe, 0xf9, 0x62])

}

enum LogicalTimeMicrosFixture {

	@Schema
	struct Def: Codable, Equatable {
		let name: String
		@LogicalType(.timeMicros)
		let timeOfDay: Int64
	}

	static let schema: AvroSchema = .record(
		name: "TimeOfDayMicros",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "timeOfDay", type: .logical(type: .timeMicros, underlying: .long))
		]
	)

	static let avroSchemaString = """
			{
				"type": "record",
		 "name": "TimeOfDayMicros",
		 "fields": [
			 {
				 "name": "name",
				 "type": "string"
			 },
			 {
				 "name": "timeOfDay",
				 "type": "long",
				 "logicalType": "time-micros"
			 }
		 ]
		}
		"""

	static let instance = Def(name: "Ada", timeOfDay: 123)
	static let serialized = Data([0x06, 0x41, 0x64, 0x61, 0xf6, 0x01])

}

enum LogicalTimestampMicrosFixture {

	@Schema
	struct Def: Codable, Equatable {
		let name: String
		@LogicalType(.timestampMicros)
		let timestamp: Date
	}

	static let schema: AvroSchema = .record(
		name: "TimestampMicrosRecord",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "timestamp", type: .logical(type: .timestampMicros, underlying: .long))
		]
	)

	static let avroSchemaString = """
			{
				"type": "record",
		 "name": "TimestampMicrosRecord",
		 "fields": [
			 {
				 "name": "name",
				 "type": "string"
			 },
			 {
				 "name": "timestamp",
				 "type": "long",
				 "logicalType": "timestamp-micros"
			 }
		 ]
		}
		"""

	static let instance = Def(name: "Ada", timestamp: Date(timeIntervalSince1970: 1_700_000_000 + 0.000456))
	static let serialized = Data([0x06, 0x41, 0x64, 0x61, 0x90, 0x87, 0xf2, 0x81, 0x83, 0x89, 0x85, 0x06])

}

enum LogicalUUIDFixture {

	@Schema
	struct Def: Codable, Equatable {
		let name: String
		@LogicalType(.uuid)
		let id: UUID
	}

	static let schema: AvroSchema = .record(
		name: "UUIDRecord",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "id", type: .logical(type: .uuid, underlying: .string))
		]
	)

	static let avroSchemaString = """
			{
				"type": "record",
		 "name": "UUIDRecord",
		 "fields": [
			 {
				 "name": "name",
				 "type": "string"
			 },
			 {
				 "name": "id",
				 "type": "string",
				 "logicalType": "uuid"
			 }
		 ]
		}
		"""

	static let instance = Def(name: "Ada", id: UUID(uuidString: "01234567-89AB-CDEF-0123-456789ABCDEF")!)
	static let serialized = Data([
		0x06, 0x41, 0x64, 0x61, 0x48, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x2d, 0x38, 0x39, 0x41, 0x42, 0x2d, 0x43,
		0x44, 0x45, 0x46, 0x2d, 0x30, 0x31, 0x32, 0x33, 0x2d, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45,
		0x46
	])

}

enum LogicalDecimalFixture {

	@Schema
	struct Def: Codable, Equatable {
		let name: String
		@LogicalType(.decimal(scale: 2, precision: 9))
		let amount: Decimal
	}

	static let schema: AvroSchema = .record(
		name: "DecimalRecord",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "amount", type: .logical(type: .decimal(scale: 2, precision: 9), underlying: .bytes))
		]
	)

	static let avroSchemaString = """
			{
				"type": "record",
		 "name": "DecimalRecord",
		 "fields": [
			 {
				 "name": "name",
				 "type": "string"
			 },
			 {
				 "name": "amount",
				 "type": "bytes",
				 "logicalType": "decimal",
				 "precision": 9,
				 "scale": 2
			 }
		 ]
		}
		"""

	static let instance = Def(name: "Ada", amount: Decimal(string: "1234.56")!)
	static let serialized = Data([0x06, 0x41, 0x64, 0x61, 0x06, 0x01, 0xe2, 0x40])

}

enum FlatRecord2Fixture {
	@Schema
	struct Def: Codable, Equatable {
		let street: String
		let city: String
		let zip: Int32
	}

	static let schema: AvroSchema = .record(
		name: "Address",
		fields: [
			.init(name: "street", type: .string),
			.init(name: "city", type: .string),
			.init(name: "zip", type: .int)
		]
	)

	static let avroSchemaString = """
		  {
			"type": "record",
		 "name": "Address",
		 "fields": [
		   {
		 	 "name": "street",
		 	 "type": "string"
		   },
		   {
		 	 "name": "city",
		 	 "type": "string"
		   },
		   {
		 	 "name": "zip",
		 	 "type": "int"
		   }
		 ]
		}
		"""

	static let instance = Def(street: "1 Infinite Loop", city: "Cupertino", zip: 95014)

	static let serialized = Data([
		0x1e, 0x31, 0x20, 0x49, 0x6e, 0x66, 0x69, 0x6e, 0x69, 0x74, 0x65, 0x20, 0x4c, 0x6f, 0x6f, 0x70, 0x12, 0x43, 0x75, 0x70,
		0x65, 0x72, 0x74, 0x69, 0x6e, 0x6f, 0xcc, 0xcc, 0x0b
	])
}

enum NestedRecordFixture {
	@Schema
	struct Def: Codable, Equatable {
		let id: Int64
		let name: String
		let email: String
		let address: FlatRecord2Fixture.Def
	}

	static let schema: AvroSchema = .record(
		name: "User",
		fields: [
			.init(name: "id", type: .long),
			.init(name: "name", type: .string),
			.init(name: "email", type: .string),
			.init(
				name: "address",
				type: .record(
					name: "Address",
					fields: [
						.init(name: "street", type: .string),
						.init(name: "city", type: .string),
						.init(name: "zip", type: .int)
					]
				)
			)
		]
	)

	static let avroSchemaString = """
		  {
			"type": "record",
		 "name": "User",
		 "fields": [
		   { "name": "id", "type": "long" },
		   { "name": "name", "type": "string" },
		   { "name": "email", "type": "string" },
		   {
		     "name": "address",
		     "type": {
		       "type": "record",
		       "name": "Address",
		       "fields": [
		         { "name": "street", "type": "string" },
		         { "name": "city", "type": "string" },
		         { "name": "zip", "type": "int" }
		       ]
		     }
		   }
		 ]
		}
		"""

	static let instance = Def(
		id: 42,
		name: "Ada",
		email: "ada@example.com",
		address: FlatRecord2Fixture.Def(street: "1 Hacker Way", city: "Berlin", zip: 10115)
	)
	static let serialized = Data([
		0x54, 0x06, 0x41, 0x64, 0x61, 0x1e, 0x61, 0x64, 0x61, 0x40, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x2e, 0x63,
		0x6f, 0x6d, 0x18, 0x31, 0x20, 0x48, 0x61, 0x63, 0x6b, 0x65, 0x72, 0x20, 0x57, 0x61, 0x79, 0x0c, 0x42, 0x65, 0x72,
		0x6c, 0x69, 0x6e, 0x86, 0x9e, 0x01
	])
}
