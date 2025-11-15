//
//  DoubleArrayFixture.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Avro
import Foundation

public enum DoubleArrayFixture {
	@Schema
	public struct Def: Codable, Equatable, Sendable {
		let strings: [String]
		let ints: [Int]
	}

	public static let schema: AvroSchema = .record(
		name: "DoubleArrayRecord",
		doc: "A record with two fields, both of which are arrays",
		fields: [
			.init(name: "strings", type: .array(items: .string)),
			.init(name: "ints", type: .array(items: .int))
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
				  },
				  {
					  "name": "ints",
					  "type": {
						  "type": "array",
						  "items": "int"
					  } 
				  }    
			  ]
		  }
		"""

	public static let instance = Def(strings: ["apple", "banana", "cherry"], ints: [1, 2, 3])

	public static let serialized = Data([
		0x06, 0x0a, 0x61, 0x70, 0x70, 0x6c, 0x65, 0x0c, 0x62, 0x61, 0x6e, 0x61, 0x6e, 0x61, 0x0c, 0x63, 0x68, 0x65, 0x72,
		0x72, 0x79, 0x00, 0x06, 0x02, 0x04, 0x06, 0x00
	])

}
