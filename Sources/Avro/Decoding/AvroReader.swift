//
//  AvroReader.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Foundation

class AvroReader {
	let data: Data
	private var offset: Int = 0

	var currentOffset: Int {
		offset
	}

	init(data: Data) {
		self.data = data
	}

	init(data: Data, offset: Int) {
		self.data = data
		self.offset = offset
	}

	@inline(__always)
	private func readByte() throws -> UInt8 {
		guard offset < data.count else { throw AvroError.endOfData }
		let byte = data[offset]
		offset += 1
		return byte
	}

	@inline(__always)
	private func readBytes(count: Int) throws -> Data {
		guard offset + count <= data.count else { throw AvroError.endOfData }
		let slice = data[offset ..< offset + count]
		offset += count
		return Data(slice) // FIXME: https://github.com/swiftlang/swift-foundation/issues/1601
	}

	@inline(__always)
	private func readVarUInt() throws -> UInt64 {
		var shift: UInt64 = 0
		var result: UInt64 = 0

		while true {
			let byte = try readByte()
			result |= UInt64(byte & 0x7F) << shift
			if (byte & 0x80) == 0 {
				break
			}
			shift += 7
			if shift > 63 {
				throw AvroError.integerOverflow
			}
		}
		return result
	}

	@inline(__always)
	private func zigZagDecodeInt(_ n: UInt32) -> Int32 {
		let shifted = Int32(bitPattern: n >> 1)
		let negMask = Int32(n & 1)
		return shifted ^ -negMask
	}

	@inline(__always)
	private func zigZagDecodeLong(_ n: UInt64) -> Int64 {
		let shifted = Int64(bitPattern: n >> 1)
		let negMask = Int64(n & 1)
		return shifted ^ -negMask
	}

	func readBoolean() throws -> Bool {
		let byte = try readByte()
		return byte != 0
	}

	func readInt() throws -> Int32 {
		let u = try readVarUInt()
		return zigZagDecodeInt(UInt32(u))
	}

	@inline(__always)
	@inlinable
	func readLong() throws -> Int64 {
		let u = try readVarUInt()
		return zigZagDecodeLong(u)
	}

	func readFloat() throws -> Float {
		let bytes = try readBytes(count: 4)
		return bytes.withUnsafeBytes { ptr in
			Float(bitPattern: ptr.loadUnaligned(as: UInt32.self).littleEndian)
		}
	}

	func readDouble() throws -> Double {
		let bytes = try readBytes(count: 8)
		return bytes.withUnsafeBytes { ptr in
			Double(bitPattern: ptr.loadUnaligned(as: UInt64.self).littleEndian)
		}
	}

	func readBytes() throws -> Data {
		let length = try readLong()
		guard length >= 0 else { throw AvroError.negativeLength }
		return try readBytes(count: Int(length))
	}

	func readString() throws -> String {
		let bytes = try readBytes()
		guard let str = String(data: bytes, encoding: .utf8) else {
			throw AvroError.invalidUTF8
		}
		return str
	}

	func skip(schema: AvroSchema) throws {
		switch schema {
			case .null:
				break
			case .boolean:
				_ = try readByte()
			case .int:
				_ = try readInt()
			case .long:
				_ = try readLong()
			case .float:
				_ = try readBytes(count: 4)
			case .double:
				_ = try readBytes(count: 8)
			case .bytes:
				_ = try readBytes()
			case .string:
				_ = try readString()
			case .array(let items):
				var isAtEnd = false
				while !isAtEnd {
					let blockCount = try readLong()
					if blockCount == 0 {
						isAtEnd = true
					} else if blockCount < 0 {
						_ = try readLong()
						let count = Int(-blockCount)
						for _ in 0 ..< count {
							try skip(schema: items)
						}
					} else {
						let count = Int(blockCount)
						for _ in 0 ..< count {
							try skip(schema: items)
						}
					}
				}
			case .map(let values):
				var isAtEnd = false
				while !isAtEnd {
					let blockCount = try readLong()
					if blockCount == 0 {
						isAtEnd = true
					} else if blockCount < 0 {
						_ = try readLong()
						let count = Int(-blockCount)
						for _ in 0 ..< count {
							_ = try readString()
							try skip(schema: values)
						}
					} else {
						let count = Int(blockCount)
						for _ in 0 ..< count {
							_ = try readString()
							try skip(schema: values)
						}
					}
				}
			case .record(_, _, _, _, let fields):
				for field in fields {
					try skip(schema: field.type)
				}
			case .logical(_, let underlying):
				try skip(schema: underlying)
		}
	}
}
