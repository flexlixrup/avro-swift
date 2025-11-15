//
//  NestedRecordFixture.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Avro
import Foundation

public enum NestedRecordFixture {
	@Schema
	public struct Def: Codable, Equatable, Sendable {
		let id: Int64
		let name: String
		let email: String
		let address: FlatRecord2Fixture.Def
	}

	public static let schema: AvroSchema = .record(
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

	public static let avroSchemaString = """
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

	public static let instance = Def(
		id: 42,
		name: "Ada",
		email: "ada@example.com",
		address: FlatRecord2Fixture.Def(street: "1 Hacker Way", city: "Berlin", zip: 10115)
	)
	public static let serialized = Data([
		0x54, 0x06, 0x41, 0x64, 0x61, 0x1e, 0x61, 0x64, 0x61, 0x40, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x2e, 0x63,
		0x6f, 0x6d, 0x18, 0x31, 0x20, 0x48, 0x61, 0x63, 0x6b, 0x65, 0x72, 0x20, 0x57, 0x61, 0x79, 0x0c, 0x42, 0x65, 0x72,
		0x6c, 0x69, 0x6e, 0x86, 0x9e, 0x01
	])
}
