//
//  ArrayFixture.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Avro
import Foundation

public enum ArrayFixture {
	@Schema
	public struct Def: Codable, Equatable, Sendable {
		let strings: [String]
	}

	public static let schema: AvroSchema = .record(
		name: "ArrayRecord",
		fields: [
			.init(name: "strings", type: .array(items: .string))
		]
	)

	public static let avroSchemaString = """
		{	
		  "type": "record",
		  "name": "ArrayRecord",
		  "fields": [
			  {
				  "name": "strings",
				  "type": {
					  "type": "array",
					  "items": "string"
				  }
			  }
			]
			}
		"""

	public static let instance = Def(strings: ["apple", "banana", "cherry"])

	public static let serialized = Data([
		0x06, 0x0a, 0x61, 0x70, 0x70, 0x6c, 0x65, 0x0c, 0x62, 0x61, 0x6e, 0x61, 0x6e, 0x61, 0x0c, 0x63, 0x68, 0x65, 0x72, 0x72,
		0x79, 0x00
	])

}
