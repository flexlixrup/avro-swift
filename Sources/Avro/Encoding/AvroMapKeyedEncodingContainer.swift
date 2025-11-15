//
//  AvroKeyedEncodingContainer.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

class AvroMapKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
	var codingPath: [CodingKey]
	var writer: AvroWriter
	var count: Int = 0
	var itemSchema: AvroSchema
	var tempWriter = AvroWriter()
	private var finalized = false

	init(field: AvroSchema, writer: inout AvroWriter, codingPath: [CodingKey]) {
		self.writer = writer
		self.codingPath = codingPath
		self.itemSchema = field
	}

	func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
		let box = _AvroEncodingBox(schema: itemSchema, codingPath: codingPath, userInfo: [:], writer: &tempWriter)
		tempWriter.writeString(key.stringValue)
		try value.encode(to: box)
		count += 1

	}

	func finalize() {
		guard !finalized else { return }
		writer.writeLong(Int64(count)) // Length
		writer.writeRawBlock(tempWriter.data.map { UInt8($0) })
		writer.writeLong(0) // Termination
		finalized = true
	}

	deinit {
		if !finalized {
			assertionFailure("UnkeyedEncodingContainer was discarded before finalize() was called")
		}
	}

	func encodeNil(forKey key: Key) throws { try encode(Optional<Int>.none, forKey: key) }

	func contains(_ key: Key) -> Bool { fatalError() }

	func nestedContainer<NestedKey>(keyedBy: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
		fatalError()
	}
	func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer { fatalError() }
	func superEncoder() -> Encoder { fatalError() }
	func superEncoder(forKey key: Key) -> Encoder { fatalError() }
}
