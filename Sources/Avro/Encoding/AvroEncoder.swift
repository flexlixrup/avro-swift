//
//  AvroEncoder.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Foundation

/// An encoder to encode a ``Schema()`` object into `Data`.
public final class AvroEncoder {
	var schema: AvroSchema

	/// Initialize a new encoder.
	/// - Parameter schema: The schema to use for encoding.
	public init(schema: AvroSchema) {
		self.schema = schema
	}

	/// Encode an object.
	/// - Parameter value: The object to encode.
	/// - Returns: The encoded object.
	/// - Throws: The encoding error.
	public func encode<T: Encodable>(_ value: T) throws -> Data {
		var writer = AvroWriter()
		let box = _AvroEncodingBox(schema: schema, codingPath: [], userInfo: [:], writer: &writer)
		try value.encode(to: box)
		return writer.data
	}
}

final class _AvroEncodingBox: Encoder {
	var codingPath: [any CodingKey]
	var userInfo: [CodingUserInfoKey: Any] = [:]
	var writer: AvroWriter
	var schema: AvroSchema

	init(schema: AvroSchema, codingPath: [any CodingKey], userInfo: [CodingUserInfoKey: Any], writer: inout AvroWriter) {
		self.codingPath = codingPath
		self.userInfo = userInfo
		self.writer = writer
		self.schema = schema
	}

	func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
		guard case .record(_, _, _, _, let fields) = schema else {
			fatalError("Schema is not a record")
		}
		let container = AvroKeyedEncodingContainer<Key>(fields: fields, writer: &writer, codingPath: codingPath)
		return .init(container)
	}

	func unkeyedContainer() -> UnkeyedEncodingContainer {
		guard case .array(let items) = schema else {
			preconditionFailure("Expected array for unkeyed container")
		}
		return AvroUnkeyedEncodingContainer(codingPath: codingPath, itemSchema: items, writer: writer)
	}

	func singleValueContainer() -> any SingleValueEncodingContainer {
		AvroSingleValueEncodingContainer(schema: schema, writer: &writer, codingPath: codingPath)

	}

}
