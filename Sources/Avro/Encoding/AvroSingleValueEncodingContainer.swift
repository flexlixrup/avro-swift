//
//  AvroSingleValueEncodingContainer.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Foundation

struct AvroSingleValueEncodingContainer: SingleValueEncodingContainer {
	var schema: AvroSchemaDefinition
	var writer: AvroWriter
	var codingPath: [any CodingKey]

	init(schema: AvroSchemaDefinition, writer: inout AvroWriter, codingPath: [any CodingKey]) {
		self.schema = schema
		self.writer = writer
		self.codingPath = codingPath
	}

	mutating func encode<T>(_ value: T) throws where T: Encodable {
		func typeMismatch(_ expected: String) -> EncodingError {
			EncodingError.invalidValue(
				value,
				EncodingError.Context(
					codingPath: codingPath,
					debugDescription: "Expected \(expected)"
				)
			)
		}
		switch schema {
			case .null:
				try encodeNil()
			case .boolean:
				guard let v = value as? Bool else { throw typeMismatch("Bool") }
				writer.writeBoolean(v)
			case .int:
				if let v = value as? Int {
					writer.writeInt(Int32(v))
				} else if let v = value as? Int32 {
					writer.writeInt(v)
				} else {
					throw typeMismatch("Int or Int32")
				}
			case .long:
				guard let v = value as? Int64 else { throw typeMismatch("Int64") }
				writer.writeLong(v)
			case .float:
				guard let v = value as? Float else { throw typeMismatch("Float") }
				writer.writeFloat(v)
			case .double:
				guard let v = value as? Double else { throw typeMismatch("Double") }
				writer.writeDouble(v)
			case .bytes:
				guard let v = value as? Data else { throw typeMismatch("Data") }
				writer.writeBytes(v)
			case .string:
				guard let v = value as? String else { throw typeMismatch("String") }
				writer.writeString(v)
			case .logical(let logicalType, _):
				try encodeLogical(value, as: logicalType)
			case .enum(_, _, _, _, let symbols, _):
				guard let s = value as? String else { throw typeMismatch("String (enum symbol)") }
				guard let i = symbols.firstIndex(of: s) else { throw typeMismatch("enum symbol") }
				writer.writeInt(Int32(i))
			case .union(let unionSchema):
				try encodeUnion(value, schemas: unionSchema)
			default:
				fatalError("Unsupported schema for single value encoding: \(schema)")
		}
	}

	private mutating func encodeUnion<T: Encodable>(_ value: T, schemas: [AvroSchemaDefinition]) throws {
		guard let (index, matchedSchema) = try resolveUnionSchema(for: value, with: schemas) else {
			throw EncodingError.invalidValue(
				value,
				EncodingError.Context(
					codingPath: codingPath,
					debugDescription: "Value type does not match any schema in union: \(schemas)"
				)
			)
		}

		writer.writeInt(Int32(index))

		let box = _AvroEncodingBox(schema: matchedSchema, codingPath: codingPath, userInfo: [:], writer: &writer)
		try value.encode(to: box)
	}

	private func resolveUnionSchema<T: Encodable>(
		for value: T,
		with possibleSchemas: [AvroSchemaDefinition]
	) throws -> (index: Int, schema: AvroSchemaDefinition)? {
		for (index, schema) in possibleSchemas.enumerated() where try canEncode(value, withSchema: schema) {
			return (index, schema)
		}
		return nil
	}

	private func canEncode<T: Encodable>(_ value: T, withSchema schema: AvroSchemaDefinition) throws -> Bool {
		switch schema {
			case .null:
				return false
			case .boolean:
				return value is Bool

			case .int:
				return value is Int || value is Int32

			case .long:
				return value is Int64

			case .float:
				return value is Float

			case .double:
				return value is Double

			case .bytes:
				return value is Data || value is [UInt8]

			case .string:
				return value is String

			case .array:
				let mirror = Mirror(reflecting: value)
				return mirror.displayStyle == .collection

			case .map:
				let mirror = Mirror(reflecting: value)
				return mirror.displayStyle == .dictionary

			case .record(let name, _, _, _, _):
				let typeName = String(describing: type(of: value))
				return typeName.contains(name)

			case .enum(_, _, _, _, let symbols, _):
				guard let stringValue = value as? String else { return false }
				return symbols.contains(stringValue)

			case .logical(let logicalType, _):
				return canEncodeLogical(value, as: logicalType)

			case .union:
				return false
		}
	}

	private func canEncodeLogical<T: Encodable>(_ value: T, as logicalType: AvroSchemaDefinition.LogicalType) -> Bool {
		switch logicalType {
			case .date:
				return value is Date || value is Double

			case .timeMillis:
				return value is Int || value is Int32

			case .timeMicros:
				return value is Int || value is Int64

			case .timestampMillis, .timestampMicros:
				return value is Date || value is Int64

			case .uuid:
				return value is UUID || value is String

			case .decimal:
				return value is Decimal
		}
	}

	private func encodeLogical<T: Encodable>(_ v: T, as lt: AvroSchemaDefinition.LogicalType) throws {

		switch lt {
			case .date:
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
				let days = Int64(floor(timestamp / 86400.0))
				writer.writeInt(Int32(truncatingIfNeeded: days))
				return

			case .timestampMillis:
				guard let v = v as? Double else {
					fatalError("\(type(of: v)) Not understood for logical type .timestampMillis")
				}
				let date = Date(timeIntervalSinceReferenceDate: v);
				writer.writeLong(Int64(date.timeIntervalSince1970 * 1000));

			case .timestampMicros:
				fatalError("Timestamp micros logical type not implemented")

			case .timeMillis:
				if let value = v as? Int {
					writer.writeInt(Int32(value))
				} else if let value = v as? Int32 {
					writer.writeInt(value)
				} else {
					throw EncodingError.invalidValue(
						v,
						EncodingError.Context(codingPath: codingPath, debugDescription: "Can only encode Int or Int32")
					)
				}

			case .timeMicros:
				if let value = v as? Int {
					writer.writeLong(Int64(value))
				} else if let value = v as? Int64 {
					writer.writeLong(value)
				} else {
					throw EncodingError.invalidValue(
						v,
						EncodingError.Context(codingPath: codingPath, debugDescription: "Can only encode Int or Int32")
					)
				}

			case .uuid:
				if let value = v as? UUID {
					writer.writeString(value.uuidString)
				} else if let value = v as? String {
					let uuidCheck = UUID(uuidString: value)
					guard uuidCheck != nil else {
						throw EncodingError.invalidValue(
							v,
							EncodingError.Context(codingPath: codingPath, debugDescription: "Invalid UUID string")
						)
					}
					writer.writeString(value)
				} else {
					throw EncodingError.invalidValue(
						v,
						EncodingError.Context(codingPath: codingPath, debugDescription: "Can only encode UUID or String")
					)
				}

			case .decimal(_, _):
				fatalError("Decimal logical type not implemented")
		}
	}

	mutating func encodeNil() throws {
		switch schema {
			case .union(let unionSchema):
				guard let nullIndex = unionSchema.firstIndex(of: .null) else {
					throw EncodingError.invalidValue(
						nil as Int64? as Any,
						EncodingError.Context(codingPath: codingPath, debugDescription: "Null value not found in type union")
					)
				}
				writer.writeLong(Int64(nullIndex))
			default:
				return

		}
	}

}
