//
//  MapFixture.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Avro
import Foundation

public enum MapFixture {
	@Schema
	public struct Def: Codable, Equatable, Sendable {
		let stringToInt: [String: Int]
	}

	public static let schema: AvroSchema = .record(
		name: "MapRecord",
		namespace: "test",
		doc: "A record with a map field",
		aliases: ["MapType"],
		fields: [
			.init(name: "stringToInt", type: .map(values: .int))
		]
	)

	public static let avroSchemaString = """
		  {
			  "type": "record",
			  "name": "MapRecord",
			  "fields": [
				  {
					  "name": "stringToInt",
					  "type": {
						  "type": "map",
						  "values": "int"
					  }
				  }
			  ]
		  }
		"""

	public static let instance = Def(stringToInt: ["apple": 1, "banana": 2, "cherry": 3])

	public static let serialized = Data([
		0x06, 0x0a, 0x61, 0x70, 0x70, 0x6c, 0x65, 0x02, 0x0c, 0x62, 0x61, 0x6e, 0x61, 0x6e, 0x61, 0x04, 0x0c, 0x63, 0x68, 0x65,
		0x72, 0x72, 0x79, 0x06, 0x00
	])
}
