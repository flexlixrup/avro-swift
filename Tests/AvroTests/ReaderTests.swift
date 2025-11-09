//
//  ReaderTests.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Foundation
import Testing

@testable import Avro

@Suite("Avro Reader Tests")
struct ReaderTests {

	@Test("Read Bool")
	func readBool() throws {
		let data: Data = .init([1, 0])
		let reader = AvroReader(data: data)

		let resultTrue: Bool = try reader.readBoolean()
		#expect(resultTrue)
		let resultFalse: Bool = try reader.readBoolean()
		#expect(!resultFalse)
	}

	@Test("Read Int")
	func readInt() throws {
		let data = Data([0x7f, 0x80, 0x01])
		let reader = AvroReader(data: data)

		let resultNeg = try reader.readInt()
		#expect(resultNeg == -64)
		let resultPos = try reader.readInt()
		#expect(resultPos == 64)
	}

	@Test("Read long")
	func readLong() throws {
		let data = Data([40, 24])
		let reader = AvroReader(data: data)
		let result1 = try reader.readLong()
		#expect(result1 == 20)
		let result2 = try reader.readLong()
		#expect(result2 == 12)
	}

	@Test("Read float")
	func readFloat() throws {
		let data = Data([0x00, 0x00, 0x91, 0x41, 0x46, 0xb6, 0x4f, 0xc1])
		let reader = AvroReader(data: data)
		let result1: Float = try reader.readFloat()
		#expect(result1 == 18.125)
		let result2: Float = try reader.readFloat()
		#expect(result2 == -12.982)
	}

	@Test("Read double")
	func readDouble() throws {
		let data = Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x32, 0x40, 0x10, 0x58, 0x39, 0xb4, 0xc8, 0xf6, 0x29, 0xc0])
		let reader = AvroReader(data: data)
		let result1: Double = try reader.readDouble()
		#expect(result1 == 18.125)
		let result2: Double = try reader.readDouble()
		#expect(result2 == -12.982)
	}

	@Test("Read bytes")
	func readBytes() throws {
		let data = Data([6, 1, 2, 3])
		let reader = AvroReader(data: data)
		let result = try reader.readBytes()
		#expect(result == Data([1, 2, 3]))
	}

	@Test("Read String")
	func readString() throws {
		let data = Data([6, 0x66, 0x6f, 0x6f])
		let reader = AvroReader(data: data)
		let result = try reader.readString()
		#expect(result == "foo")
	}
}
