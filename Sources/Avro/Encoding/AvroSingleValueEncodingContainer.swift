//
//  AvroSingleValueEncodingContainer.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Foundation

struct AvroSingleValueEncodingContainer: SingleValueEncodingContainer {
	var schema: AvroSchema
	var writer: AvroWriter
	var codingPath: [any CodingKey]

	init(schema: AvroSchema, writer: inout AvroWriter, codingPath: [any CodingKey]) {
		self.schema = schema
		self.writer = writer
		self.codingPath = codingPath
	}

	mutating func encode<T>(_ value: T) throws where T: Encodable {
		switch schema {
			case .null:
				try encodeNil()
			case .boolean:
				writer.writeBoolean(value as! Bool)
			case .int:
				writer.writeInt(value as! Int32)
			case .long:
				writer.writeLong(value as! Int64)
			case .float:
				writer.writeFloat(value as! Float)
			case .double:
				writer.writeDouble(value as! Double)
			case .bytes:
				writer.writeBytes(value as! Data)
			case .string:
				writer.writeString(value as! String)
			case .logical(let logicalType, _):
				try encodeLogical(value, as: logicalType)

			default:
				fatalError("Unsupported schema for single value encoding: \(schema)")
		}
	}

	private func encodeLogical<T: Encodable>(_ v: T, as lt: AvroSchema.LogicalType) throws {
		let referenceOffset: TimeInterval = 978307200.0

		let timestamp: TimeInterval

		if let d = v as? Date {
			timestamp = d.timeIntervalSince1970
		} else if let secondsSince2001 = v as? Double {
			timestamp = secondsSince2001 + referenceOffset
		} else {
			throw EncodingError.invalidValue(
				v,
				EncodingError.Context(
					codingPath: codingPath,
					debugDescription: "Cannot encode value as Date or Double timestamp"
				)
			)
		}

		switch lt {
			case .date:
				let days = Int64(floor(timestamp / 86400.0))
				writer.writeInt(Int32(truncatingIfNeeded: days))
				return

			case .timestampMillis:
				let millis = Int64(timestamp * 1000.0)
				writer.writeLong(millis)
				return

			case .timestampMicros:
				let micros = Int64(timestamp * 1_000_000.0)
				writer.writeLong(micros)
				return

			case .timeMillis:
				let millisInDay = Int32(timestamp.truncatingRemainder(dividingBy: 86400.0) * 1000.0)
				writer.writeInt(millisInDay)
				return

			case .timeMicros:
				let microsInDay = Int64(timestamp.truncatingRemainder(dividingBy: 86400.0) * 1_000_000.0)
				writer.writeLong(microsInDay)
				return

			case .uuid:
				fatalError("UUID logical type not implemented")

			case .decimal(_, _):
				fatalError("Decimal logical type not implemented")
		}
	}

	mutating func encodeNil() throws {
		return
	}

}
