//
//  AvroWriter.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Foundation

class AvroWriter {
	private(set) var data: Data = Data()

	@inline(__always)
	private func zigZagEncode(_ value: Int64) -> UInt64 {
		UInt64(bitPattern: (value << 1) ^ (value >> 63))
	}

	@inline(__always)
	private func zigZagEncode(_ value: Int32) -> UInt32 {
		UInt32(bitPattern: (value << 1) ^ (value >> 31))
	}

	func writeBoolean(_ value: Bool) {
		data.append(value ? 1 : 0)
	}

	func writeRaw(_ value: UInt8) {
		data.append(value)
	}

	func writeRawBlock(_ value: [UInt8]) {
		data.append(contentsOf: value)
	}

	func writeInt(_ value: Int32) {
		let zz = UInt64(zigZagEncode(value))
		writeVarUInt(zz)
	}

	@inlinable
	@inline(__always)
	func writeLong(_ value: Int64) {
		let zz = zigZagEncode(value)
		writeVarUInt(zz)
	}

	func writeFloat(_ value: Float) {
		var le = value.bitPattern.littleEndian // UInt32
		withUnsafeBytes(of: &le) { bytes in
			data.append(contentsOf: bytes)
		}
	}

	func writeDouble(_ value: Double) {
		var le = value.bitPattern.littleEndian // UInt64
		withUnsafeBytes(of: &le) { bytes in
			data.append(contentsOf: bytes)
		}
	}

	func writeBytes(_ value: Data) {
		writeLong(Int64(value.count))
		data.append(value)
	}

	func writeString(_ value: String) {
		let utf8Bytes = value.data(using: .utf8)!
		writeLong(Int64(utf8Bytes.count))
		data.append(utf8Bytes)
	}

	func writeVarUInt(_ value: UInt64) {
		var v = value
		while (v & ~0x7F) != 0 {
			data.append(UInt8((v & 0x7F) | 0x80))
			v >>= 7
		}
		data.append(UInt8(v & 0x7F))
	}
}
