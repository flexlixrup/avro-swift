//
//  LogicalTimeMicrosFixture.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Avro
import Foundation

public enum LogicalTimeMicrosFixture {

	@Schema
	public struct Def: Codable, Equatable, Sendable {
		let name: String
		@LogicalType(.timeMicros)
		let timeOfDay: Int64
	}

	public static let schema: AvroSchema = .record(
		name: "TimeOfDayMicros",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "timeOfDay", type: .logical(type: .timeMicros, underlying: .long))
		]
	)

	public static let avroSchemaString = """
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

	public static let instance = Def(name: "Ada", timeOfDay: 123)
	public static let serialized = Data([0x06, 0x41, 0x64, 0x61, 0xf6, 0x01])

}
