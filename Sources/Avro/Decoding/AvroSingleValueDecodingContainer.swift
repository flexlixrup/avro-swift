//
//  AvroSingleValueDecodingContainer.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

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
		switch schema {
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
			default:
				fatalError("Unsupported schema for single value decoding: \(schema)")
		}
	}

}
