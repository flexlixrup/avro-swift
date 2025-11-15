//
//  LogicalTimeMillisFixture.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Avro
import Foundation

public enum LogicalTimeMillisFixture {

	@Schema
	public struct Def: Codable, Equatable, Sendable {
		let name: String
		@LogicalType(.timeMillis)
		let timeOfDay: Int
	}

	public static let schema: AvroSchema = .record(
		name: "TimeOfDay",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "timeOfDay", type: .logical(type: .timeMillis, underlying: .int))
		]
	)

	public static let avroSchemaString = """
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

	public static let instance = Def(name: "Ada", timeOfDay: 12)
	public static let serialized = Data([0x06, 0x41, 0x64, 0x61, 0x18])

}
