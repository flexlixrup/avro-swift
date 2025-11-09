//
//  AvroKeyedEncodingContainer.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

struct AvroKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
	var codingPath: [CodingKey]
	var fields: [AvroSchema.Field]
	var writer: AvroWriter
	var allKeys: [Key] { fields.compactMap { Key(stringValue: $0.name) } }

	init(fields: [AvroSchema.Field], writer: inout AvroWriter, codingPath: [CodingKey]) {
		self.fields = fields
		self.writer = writer
		self.codingPath = codingPath
	}

	mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
		guard let field = fields.first(where: { $0.name == key.stringValue }) else {
			throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "Unknown field \(key)"))
		}
		let box = _AvroEncodingBox(schema: field.type, codingPath: codingPath + [key], userInfo: [:], writer: &writer)
		try value.encode(to: box)

	}

	mutating func encodeNil(forKey key: Key) throws { try encode(Optional<Int>.none, forKey: key) }

	func contains(_ key: Key) -> Bool { fields.contains { $0.name == key.stringValue } }

	mutating func nestedContainer<NestedKey>(keyedBy: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
		fatalError()
	}
	mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer { fatalError() }
	mutating func superEncoder() -> Encoder { fatalError() }
	mutating func superEncoder(forKey key: Key) -> Encoder { fatalError() }
}
