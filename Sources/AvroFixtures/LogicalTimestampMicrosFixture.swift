//
//  Fixtures.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Avro
import Foundation

public enum LogicalTimestampMicrosFixture {

	@Schema
	public struct Def: Codable, Equatable, Sendable {
		let name: String
		@LogicalType(.timestampMicros)
		let timestamp: Date
	}

	public static let schema: AvroSchema = .record(
		name: "TimestampMicrosRecord",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "timestamp", type: .logical(type: .timestampMicros, underlying: .long))
		]
	)

	public static let avroSchemaString = """
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

	public static let instance = Def(name: "Ada", timestamp: Date(timeIntervalSince1970: 1_700_000_000 + 0.000456))
	public static let serialized = Data([0x06, 0x41, 0x64, 0x61, 0x90, 0x87, 0xf2, 0x81, 0x83, 0x89, 0x85, 0x06])

}
