//
//  LogicalUUIDFixture.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Avro
import Foundation

public enum LogicalUUIDFixture {

	@Schema
	public struct Def: Codable, Equatable, Sendable {
		let name: String
		@LogicalType(.uuid)
		let id: UUID
	}

	public static let schema: AvroSchema = .record(
		name: "UUIDRecord",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "id", type: .logical(type: .uuid, underlying: .string))
		]
	)

	public static let avroSchemaString = """
			{
				"type": "record",
		 "name": "UUIDRecord",
		 "fields": [
			 {
				 "name": "name",
				 "type": "string"
			 },
			 {
				 "name": "id",
				 "type": "string",
				 "logicalType": "uuid"
			 }
		 ]
		}
		"""

	public static let instance = Def(name: "Ada", id: UUID(uuidString: "01234567-89AB-CDEF-0123-456789ABCDEF")!)
	public static let serialized = Data([
		0x06, 0x41, 0x64, 0x61, 0x48, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x2d, 0x38, 0x39, 0x41, 0x42, 0x2d, 0x43,
		0x44, 0x45, 0x46, 0x2d, 0x30, 0x31, 0x32, 0x33, 0x2d, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45,
		0x46
	])

}
