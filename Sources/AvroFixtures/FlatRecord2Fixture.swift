//
//  FlatRecord2Fixture.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Avro
import Foundation

public enum FlatRecord2Fixture {
	@Schema
	public struct Def: Codable, Equatable, Sendable {
		let street: String
		let city: String
		let zip: Int32
	}

	public static let schema: AvroSchema = .record(
		name: "Address",
		fields: [
			.init(name: "street", type: .string),
			.init(name: "city", type: .string),
			.init(name: "zip", type: .int)
		]
	)

	public static let avroSchemaString = """
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

	public static let instance = Def(street: "1 Infinite Loop", city: "Cupertino", zip: 95014)

	public static let serialized = Data([
		0x1e, 0x31, 0x20, 0x49, 0x6e, 0x66, 0x69, 0x6e, 0x69, 0x74, 0x65, 0x20, 0x4c, 0x6f, 0x6f, 0x70, 0x12, 0x43, 0x75, 0x70,
		0x65, 0x72, 0x74, 0x69, 0x6e, 0x6f, 0xcc, 0xcc, 0x0b
	])
}
