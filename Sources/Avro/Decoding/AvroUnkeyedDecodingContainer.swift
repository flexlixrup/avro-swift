//
//  AvroUnkeyedDecodingContainer.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Foundation

class AvroUnkeyedDecodingContainer: UnkeyedDecodingContainer {
	var codingPath: [CodingKey]
	var itemSchema: AvroSchema
	var reader: AvroReader
	var count: Int?
	private var _isAtEnd: Bool = false
	var isAtEnd: Bool {
		if isBytes {
			if let data = bytesData {
				return currentIndex >= data.count
			}
			return false
		}
		return _isAtEnd
	}
	var currentIndex: Int = 0
	var remainingInBlock = 0
	var isInitialized = false
	var isBytes: Bool
	var bytesData: Data?

	init(reader: AvroReader, schema: AvroSchema, codingPath: [CodingKey], isBytes: Bool = false) {
		self.reader = reader
		self.itemSchema = schema
		self.codingPath = codingPath
		self.isBytes = isBytes
	}

	func startOfBlock(withCount blockCount: Int64) {
		if blockCount == 0 {
			_isAtEnd = true
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

	func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
		guard !isBytes else {
			if bytesData == nil {
				bytesData = try reader.readBytes()
				count = bytesData?.count ?? 0
			}

			guard let data = bytesData else {
				throw DecodingError.dataCorrupted(
					.init(
						codingPath: codingPath,
						debugDescription: "Bytes data is nil"
					)
				)
			}

			guard currentIndex < data.count else {
				throw DecodingError.dataCorrupted(
					.init(
						codingPath: codingPath,
						debugDescription:
							"Tried to decode a value from bytes that has already reached its end. Index: \(currentIndex), Count: \(data.count)"
					)
				)
			}

			let byte = data[currentIndex]
			currentIndex += 1

			guard let value = byte as? T else {
				throw DecodingError.typeMismatch(
					T.self,
					.init(
						codingPath: codingPath,
						debugDescription: "Expected UInt8 but got \(Swift.type(of: byte))"
					)
				)
			}
			return value
		}
		if !isInitialized {
			let blockCount = try reader.readLong()
			startOfBlock(withCount: blockCount)
			isInitialized = true
		}
		guard !isAtEnd else {
			throw DecodingError.dataCorrupted(
				.init(
					codingPath: codingPath,
					debugDescription:
						"Tried to decode a value from an unkeyed container that has already reached its end."
				)
			)
		}
		currentIndex += 1
		remainingInBlock -= 1
		let box = _AvroDecodingBox(schema: itemSchema, reader: reader, codingPath: codingPath)
		let value = try T(from: box)
		if remainingInBlock == 0 {
			startOfBlock(withCount: try reader.readLong())
		}
		return value
	}

	func decodeNil() throws -> Bool {
		fatalError()
	}
	func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey>
	where NestedKey: CodingKey {
		fatalError()
	}
	func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
		fatalError()
	}
	func superDecoder() throws -> any Decoder {
		fatalError()
	}
}
