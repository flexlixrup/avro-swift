import Foundation
import Testing

@testable import Avro

@Suite("Avro Writer Tests")
struct AvroWriterTests {

	@Test("Write Bool")
	func writeBool() {
		let writer = AvroWriter()
		writer.writeBoolean(true)
		writer.writeBoolean(false)
		#expect(writer.data == Data([1, 0]))
	}

	@Test("Write Int")
	func writeInt() {
		let writer = AvroWriter()
		writer.writeInt(-64)
		writer.writeInt(64)
		#expect(writer.data == Data([0x7f, 0x80, 0x01]))
	}

	@Test("Write Long")
	func writeLong() {
		let writer = AvroWriter()
		writer.writeLong(20)
		writer.writeLong(12)
		#expect(writer.data == Data([40, 24]))
	}

	@Test("Write Float")
	func writeFloat() {
		let writer = AvroWriter()
		writer.writeFloat(18.125)
		writer.writeFloat(-12.982)
		#expect(writer.data == Data([0x00, 0x00, 0x91, 0x41, 0x46, 0xb6, 0x4f, 0xc1]))
	}

	@Test("Write Double")
	func writeDouble() {
		let writer = AvroWriter()
		writer.writeDouble(18.125)
		writer.writeDouble(-12.982)
		#expect(
			writer.data == Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x32, 0x40, 0x10, 0x58, 0x39, 0xb4, 0xc8, 0xf6, 0x29, 0xc0])
		)
	}

	@Test("Write Bytes")
	func writeBytes() {
		let writer = AvroWriter()
		writer.writeBytes(Data([1, 2, 3]))
		#expect(writer.data == Data([6, 1, 2, 3]))
	}

	@Test("Write String")
	func writeString() {
		let writer = AvroWriter()
		writer.writeString("foo")
		#expect(writer.data == Data([6, 0x66, 0x6f, 0x6f]))
	}

}
