//
//  AvroReader.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Foundation

class AvroReader {
	private let data: Data
	private var offset: Int = 0

	init(data: Data) {
		self.data = data
	}

	private func readByte() throws -> UInt8 {
		guard offset < data.count else { throw AvroError.endOfData }
		let byte = data[offset]
		offset += 1
		return byte
	}

	private func readBytes(count: Int) throws -> Data {
		guard offset + count <= data.count else { throw AvroError.endOfData }
		let slice = data[offset ..< offset + count]
		offset += count
		return slice
	}

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

	func readLong() throws -> Int64 {
		let u = try readVarUInt()
		return zigZagDecodeLong(u)
	}

	func readFloat() throws -> Float {
		let bytes = try readBytes(count: 4)
		return bytes.withUnsafeBytes { ptr in
			Float(bitPattern: ptr.load(as: UInt32.self).littleEndian)
		}
	}

	func readDouble() throws -> Double {
		let bytes = try readBytes(count: 8)
		return bytes.withUnsafeBytes { ptr in
			Double(bitPattern: ptr.load(as: UInt64.self).littleEndian)
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
}
