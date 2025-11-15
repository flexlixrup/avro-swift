//
//  LogicalTimestampMillisFixture.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Avro
import Foundation

public enum LogicalTimestampMillisFixture {

	@Schema
	public struct Def: Codable, Equatable, Sendable {
		let name: String
		@LogicalType(.timestampMillis)
		let timestamp: Date
	}

	public static let schema: AvroSchema = .record(
		name: "TimestampRecord",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "timestamp", type: .logical(type: .timestampMillis, underlying: .long))
		]
	)

	public static let avroSchemaString = """
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

	public static let instance = Def(name: "Ada", timestamp: Date(timeIntervalSince1970: 1_700_000_000))
	public static let serialized = Data([0x06, 0x41, 0x64, 0x61, 0x80, 0xa0, 0xab, 0xfe, 0xf9, 0x62])

}
