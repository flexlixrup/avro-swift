//
//  AvroUnkeyedDecodingContainer.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

class AvroMapKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
	var codingPath: [CodingKey]
	var itemSchema: AvroSchema
	var reader: AvroReader
	var count: Int?
	var isAtEnd: Bool = false
	var currentIndex: Int = 0
	var remainingInBlock = 0
	var isInitialized = false

	private var keys: [Key] = []
	private var hasScannedKeys = false

	var allKeys: [Key] {
		try? scanAllKeysIfNeeded()
		return keys
	}

	private func scanAllKeysIfNeeded() throws {
		guard !hasScannedKeys else { return }

		let snapshot = AvroReader(data: reader.data, offset: reader.currentOffset)

		var tmpKeys: [Key] = []
		var tmpIsAtEnd = false
		let localReader = snapshot

		var localCount: Int = 0
		while !tmpIsAtEnd {
			let blockCount = try localReader.readLong()
			if blockCount == 0 {
				tmpIsAtEnd = true
				break
			} else if blockCount < 0 {
				fatalError("Negative blocks not implemented")
			} else {
				let n = Int(blockCount)
				localCount += n
				for _ in 0 ..< n {
					let keyString = try localReader.readString()
					if let k = Key(stringValue: keyString) {
						tmpKeys.append(k)
					}
					try localReader.skip(schema: itemSchema)
				}
			}
		}

		self.keys = tmpKeys
		self.count = localCount
		self.hasScannedKeys = true
	}

	func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
		try scanAllKeysIfNeeded()

		if !isInitialized {
			let blockCount = try reader.readLong()
			startOfBlock(withCount: blockCount)
			isInitialized = true
		}
		guard !isAtEnd else {
			throw DecodingError.dataCorrupted(
				.init(
					codingPath: codingPath,
					debugDescription: "Tried to decode a value from an unkeyed container that has already reached its end."
				)
			)
		}

		currentIndex += 1
		remainingInBlock -= 1

		let wireKey = try reader.readString()
		if wireKey != key.stringValue {
			throw DecodingError.keyNotFound(
				key,
				.init(
					codingPath: codingPath,
					debugDescription:
						"Requested key \(key.stringValue) does not match next map entry \(wireKey). Out-of-order decoding is not supported."
				)
			)
		}

		let box = _AvroDecodingBox(schema: itemSchema, reader: reader, codingPath: codingPath)
		let value = try T(from: box)
		if remainingInBlock == 0 {
			startOfBlock(withCount: try reader.readLong())
		}
		return value
	}

	init(reader: AvroReader, schema: AvroSchema, codingPath: [CodingKey]) {
		self.reader = reader
		self.itemSchema = schema
		self.codingPath = codingPath
	}

	func contains(_ key: Key) -> Bool { fatalError() }

	func startOfBlock(withCount blockCount: Int64) {
		if blockCount == 0 {
			isAtEnd = true
		} else if blockCount < 0 {
			fatalError("Negative block sizes not implemented")
		} else {
			remainingInBlock = Int(blockCount)
			if count == nil {
				count = Int(blockCount)
			} else {
				count? += Int(blockCount)
			}
		}
	}

	func decodeNil(forKey key: Key) throws -> Bool {
		true
	}

	func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey>
	where NestedKey: CodingKey {
		fatalError()
	}

	func nestedUnkeyedContainer(forKey key: Key) throws -> any UnkeyedDecodingContainer {
		fatalError()
	}

	func superDecoder() throws -> any Decoder {
		fatalError()
	}

	func superDecoder(forKey key: Key) throws -> any Decoder {
		fatalError()
	}
}
