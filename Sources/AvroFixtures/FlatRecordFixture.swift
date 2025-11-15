//
//  FlatRecordFixture.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Avro
import Foundation

public enum FlatRecordFixture {
	@Schema
	public struct Def: Codable, Equatable, Sendable {

		let id: Int64
		let name: String
		let email: String
	}

	public static let schema: AvroSchema = .record(
		name: "User",
		fields: [
			.init(name: "id", type: .long),
			.init(name: "name", type: .string),
			.init(name: "email", type: .string)
		]
	)

	public static let avroSchemaString = """
		  {
			"type": "record",
		 "name": "User",
		 "fields": [
		   {
			 "name": "id",
			 "type": "long"
		   },
		   {
			 "name": "name",
			 "type": "name"
		   },
		   {
			 "name": "email",
			 "type": "string"
		   }
		 ]
		}
		"""
	public static let instance = Def(id: 42, name: "Ada", email: "ada@example.com")
	public static let serialized = Data([
		0x54, 0x06, 0x41, 0x64, 0x61, 0x1e, 0x61, 0x64, 0x61, 0x40, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x2e, 0x63,
		0x6f, 0x6d
	])

}
