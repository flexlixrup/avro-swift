//
//  LogicalDateFixture.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Avro
import Foundation

public enum LogicalDateFixture {

	@Schema
	public struct Def: Codable, Equatable, Sendable {
		let name: String
		@LogicalType(.date)
		let dateOfBirth: Date
	}

	public static let schema: AvroSchema = .record(
		name: "Person",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "dateOfBirth", type: .logical(type: .date, underlying: .int))
		]
	)

	public static let avroSchemaString = """
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

	public static let instance = Def(name: "Ada", dateOfBirth: Date(timeIntervalSince1970: 364 * 86_400))
	public static let serialized = Data([0x06, 0x41, 0x64, 0x61, 0xd8, 0x05])

}
