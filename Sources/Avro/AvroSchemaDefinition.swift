//
//  Schema.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Foundation

/// An Avro Schema.
indirect public enum AvroSchemaDefinition: Equatable, Sendable {
	case null, boolean, int, long, float, double, bytes, string
	// case fixed(name: String, size: Int)
	case `enum`(
		name: String,
		namespace: String? = nil,
		doc: String? = nil,
		aliases: [String]? = nil,
		symbols: [String],
		default: String? = nil
	)
	case array(items: AvroSchemaDefinition)
	case map(values: AvroSchemaDefinition)
	case record(name: String, namespace: String? = nil, doc: String? = nil, aliases: [String]? = nil, fields: [Field])
	case union([AvroSchemaDefinition])
	case logical(type: LogicalType, underlying: AvroSchemaDefinition)
	//
	/// A field of an Avro schema.
	public struct Field: Equatable, Sendable {
		/// The field name.
		public let name: String
		/// The doc of the field.
		public let doc: String? = nil
		/// The datatype.
		public let type: AvroSchemaDefinition
		/// The order of the field.
		public let order: Order = .ignore
		/// Aliases of the field.
		public let aliases: [String]? = nil
		// FIXME: Defaults
		/// Initialize a new field.
		/// - Parameters:
		///   - name: The name of the field.
		///   - type: The type of the field.
		@inlinable
		@inline(__always)
		public init(name: String, type: AvroSchemaDefinition) {
			self.name = name
			self.type = type

		}
	}
	/// The logical type of a field.
	public enum LogicalType: Equatable, Sendable {
		case date
		case timeMillis
		case timestampMillis
		case timeMicros
		case timestampMicros
		case uuid
		case decimal(scale: Int, precision: Int)
	}
	/// The order of the fields.
	public enum Order: Equatable, Sendable {
		case ascending
		case decending
		case ignore
	}
}

extension AvroSchemaDefinition: Codable {
	enum CodingKeys: String, CodingKey {
		case type, name, namespace, doc, aliases, symbols, `default`
		case items, values, fields, logicalType
		case scale, precision
	}

	public init(from decoder: Decoder) throws {
		if let container = try? decoder.singleValueContainer(),
			let typeString = try? container.decode(String.self)
		{
			switch typeString {
				case "null": self = .null
				case "boolean": self = .boolean
				case "int": self = .int
				case "long": self = .long
				case "float": self = .float
				case "double": self = .double
				case "bytes": self = .bytes
				case "string": self = .string
				default:
					throw DecodingError.dataCorruptedError(
						in: container,
						debugDescription: "Unknown primitive type: \(typeString)"
					)
			}
			return
		}

		let container = try decoder.container(keyedBy: CodingKeys.self)
		let type = try container.decode(String.self, forKey: .type)

		switch type {
			case "null": self = .null
			case "boolean": self = .boolean
			case "int": self = .int
			case "long": self = .long
			case "float": self = .float
			case "double": self = .double
			case "bytes": self = .bytes
			case "string": self = .string
			case "array":
				let items = try container.decode(AvroSchemaDefinition.self, forKey: .items)
				self = .array(items: items)
			case "map":
				let values = try container.decode(AvroSchemaDefinition.self, forKey: .values)
				self = .map(values: values)
			case "record":
				let name = try container.decode(String.self, forKey: .name)
				let namespace = try container.decodeIfPresent(String.self, forKey: .namespace)
				let doc = try container.decodeIfPresent(String.self, forKey: .doc)
				let aliases = try container.decodeIfPresent([String].self, forKey: .aliases)
				let fields = try container.decode([Field].self, forKey: .fields)
				self = .record(name: name, namespace: namespace, doc: doc, aliases: aliases, fields: fields)
			case "enum":
				let name = try container.decode(String.self, forKey: .name)
				let namespace = try container.decodeIfPresent(String.self, forKey: .namespace)
				let doc = try container.decodeIfPresent(String.self, forKey: .doc)
				let aliases = try container.decodeIfPresent([String].self, forKey: .aliases)
				let symbols = try container.decode([String].self, forKey: .symbols)
				let defaultValue = try container.decodeIfPresent(String.self, forKey: .default)
				self = .enum(
					name: name,
					namespace: namespace,
					doc: doc,
					aliases: aliases,
					symbols: symbols,
					default: defaultValue
				)
			default:
				throw DecodingError.dataCorruptedError(
					forKey: .type,
					in: container,
					debugDescription: "Unknown type: \(type)"
				)
		}
	}

	public func encode(to encoder: Encoder) throws {
		switch self {
			case .null:
				var container = encoder.singleValueContainer()
				try container.encode("null")
			case .boolean:
				var container = encoder.singleValueContainer()
				try container.encode("boolean")
			case .int:
				var container = encoder.singleValueContainer()
				try container.encode("int")
			case .long:
				var container = encoder.singleValueContainer()
				try container.encode("long")
			case .float:
				var container = encoder.singleValueContainer()
				try container.encode("float")
			case .double:
				var container = encoder.singleValueContainer()
				try container.encode("double")
			case .bytes:
				var container = encoder.singleValueContainer()
				try container.encode("bytes")
			case .string:
				var container = encoder.singleValueContainer()
				try container.encode("string")

			case .array(let items):
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("array", forKey: .type)
				try container.encode(items, forKey: .items)
			case .map(let values):
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("map", forKey: .type)
				try container.encode(values, forKey: .values)
			case .record(let name, let namespace, let doc, let aliases, let fields):
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("record", forKey: .type)
				try container.encode(name, forKey: .name)
				try container.encodeIfPresent(namespace, forKey: .namespace)
				try container.encodeIfPresent(doc, forKey: .doc)
				try container.encodeIfPresent(aliases, forKey: .aliases)
				try container.encode(fields, forKey: .fields)
			case .enum(let name, let namespace, let doc, let aliases, let symbols, let defaultValue):
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode("enum", forKey: .type)
				try container.encode(name, forKey: .name)
				try container.encodeIfPresent(namespace, forKey: .namespace)
				try container.encodeIfPresent(doc, forKey: .doc)
				try container.encodeIfPresent(aliases, forKey: .aliases)
				try container.encode(symbols, forKey: .symbols)
				try container.encodeIfPresent(defaultValue, forKey: .default)
			case .union(let schemas):
				var unkeyedContainer = encoder.unkeyedContainer()
				for schema in schemas {
					try unkeyedContainer.encode(schema)
				}
			case .logical(let logicalType, let underlying):
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode(underlying, forKey: .type)
				switch logicalType {
					case .date:
						try container.encode("date", forKey: .logicalType)
					case .timeMillis:
						try container.encode("time-millis", forKey: .logicalType)
					case .timestampMillis:
						try container.encode("timestamp-millis", forKey: .logicalType)
					case .timeMicros:
						try container.encode("time-micros", forKey: .logicalType)
					case .timestampMicros:
						try container.encode("timestamp-micros", forKey: .logicalType)
					case .uuid:
						try container.encode("uuid", forKey: .logicalType)
					case .decimal(let scale, let precision):
						try container.encode("decimal", forKey: .logicalType)
						try container.encode(scale, forKey: .scale)
						try container.encode(precision, forKey: .precision)
				}
		}
	}

	public func toJSONString(prettyPrinted: Bool = true) throws -> String {
		let encoder = JSONEncoder()
		if prettyPrinted {
			encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		}
		let data = try encoder.encode(self)
		guard let string = String(data: data, encoding: .utf8) else {
			throw AvroError.invalidUTF8
		}
		return string
	}
}

extension AvroSchemaDefinition.Field: Codable {
	enum CodingKeys: String, CodingKey {
		case name, doc, type, order, aliases
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let name = try container.decode(String.self, forKey: .name)
		let type = try container.decode(AvroSchemaDefinition.self, forKey: .type)
		self.init(name: name, type: type)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(name, forKey: .name)
		try container.encodeIfPresent(doc, forKey: .doc)
		try container.encode(type, forKey: .type)
		if order != .ignore {
			try container.encode(order, forKey: .order)
		}
		try container.encodeIfPresent(aliases, forKey: .aliases)
	}
}

extension AvroSchemaDefinition.Order: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let value = try container.decode(String.self)
		switch value {
			case "ascending": self = .ascending
			case "descending": self = .decending
			case "ignore": self = .ignore
			default:
				throw DecodingError.dataCorruptedError(
					in: container,
					debugDescription: "Unknown order: \(value)"
				)
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
			case .ascending: try container.encode("ascending")
			case .decending: try container.encode("descending")
			case .ignore: try container.encode("ignore")
		}
	}
}
