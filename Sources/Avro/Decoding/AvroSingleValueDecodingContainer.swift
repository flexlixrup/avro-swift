//
//  AvroSingleValueDecodingContainer.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Foundation

struct AvroSingleValueDecodingContainer: SingleValueDecodingContainer {
	var schema: AvroSchema
	var reader: AvroReader
	var codingPath: [any CodingKey]

	init(schema: AvroSchema, reader: inout AvroReader, codingPath: [any CodingKey]) {
		self.schema = schema
		self.reader = reader
		self.codingPath = codingPath
	}

	func decodeNil() -> Bool {
		true
	}

	func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
		print(type)
		return switch schema {
			case .null:
				decodeNil() as! T
			case .boolean:
				try reader.readBoolean() as! T
			case .int:
				try reader.readInt() as! T
			case .long:
				try reader.readLong() as! T
			case .float:
				try reader.readFloat() as! T
			case .double:
				try reader.readDouble() as! T
			case .bytes:
				try reader.readBytes() as! T
			case .string:
				try reader.readString() as! T
			case .logical(let logicalType, _):
				try decodeLogical(as: logicalType)
			default:
				fatalError("Unsupported schema for single value decoding: \(schema)")
		}
	}

	private func decodeLogical<T>(as lt: AvroSchema.LogicalType) throws -> T {
		let referenceOffset: Double = -978307200.0

		switch lt {

			case .date:
				return try Double(reader.readInt()) * 86400 + referenceOffset as! T
			case .timeMillis:
				fatalError("Time millis logical type not implemented")
			case .timestampMillis:
				fatalError("Timestamp millis logical type not implemented")
			case .timeMicros:
				fatalError("Time micros logical type not implemented")
			case .timestampMicros:
				fatalError("UUID logical type not implemented")
			case .uuid:
				fatalError("UUID logical type not implemented")
			case .decimal(_, _):
				fatalError("Decimal logical type not implemented")
		}
	}

}
