//
//  AvroDecoder.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Foundation

/// A decoder to decode a `Data` object into a struct or class annotated with ``Schema()``.
public final class AvroDecoder {
	let schema: AvroSchema

	/// Initilaize a new Decoder.
	/// - Parameter schema: The schema to initialize with.
	public init(schema: AvroSchema) {
		self.schema = schema
	}

	/// Decode into a type.
	/// - Parameters:
	///   - type: The type to decode into.
	///   - data: The data to decode from.
	/// - Returns: The decoded type instance.
	/// - Throws: The decoder error.
	public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
		let reader = AvroReader(data: data)
		let box = _AvroDecodingBox(schema: schema, reader: reader, codingPath: [])
		return try T(from: box)
	}
}

final class _AvroDecodingBox: Decoder {
	var codingPath: [CodingKey]
	var userInfo: [CodingUserInfoKey: Any] = [:]
	var schema: AvroSchema
	var reader: AvroReader

	init(schema: AvroSchema, reader: AvroReader, codingPath: [CodingKey]) {
		self.schema = schema
		self.reader = reader
		self.codingPath = codingPath
	}

	func container<Key>(keyedBy: Key.Type) -> KeyedDecodingContainer<Key> {
		guard case .record(_, _, _, _, let fields) = schema else {
			fatalError("Schema is not a record")
		}
		let container = AvroKeyedDecodingContainer<Key>(fields: fields, reader: &reader, codingPath: [])

		return .init(container)
	}
	func unkeyedContainer() -> UnkeyedDecodingContainer {
		fatalError("Not implemented")
	}
	func singleValueContainer() -> SingleValueDecodingContainer {
		AvroSingleValueDecodingContainer(schema: schema, reader: &reader, codingPath: [])
	}
}
