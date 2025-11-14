//
//  AvroUnkeyedEncodingContainer.swift
//  avro-swift
//
//  Created by Felix Ruppert on 13.11.25.
//

class AvroUnkeyedEncodingContainer: UnkeyedEncodingContainer {
	var codingPath: [CodingKey]
	var count: Int = 0
	var itemSchema: AvroSchema
	var writer: AvroWriter
	var tempWriter = AvroWriter()

	init(codingPath: [CodingKey], itemSchema: AvroSchema, writer: AvroWriter) {
		self.codingPath = codingPath
		self.itemSchema = itemSchema
		self.writer = writer
	}

	func encode<T>(_ value: T) throws where T: Encodable {
		let box = _AvroEncodingBox(schema: itemSchema, codingPath: codingPath, userInfo: [:], writer: &tempWriter)
		try value.encode(to: box)
		count += 1
	}

	deinit {
		writer.writeLong(Int64(count)) // Length
		writer.writeRawBlock(tempWriter.data.map { UInt8($0) })
		writer.writeLong(0) // Termination
	}

	func encodeNil() throws { fatalError() }
	func nestedContainer<NestedKey>(keyedBy: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> { fatalError() }
	func nestedUnkeyedContainer() -> UnkeyedEncodingContainer { fatalError() }
	func superEncoder() -> Encoder { fatalError() }
}
