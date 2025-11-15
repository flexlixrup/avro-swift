//
//  Schema.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

/// An Avro Schema.
indirect public enum AvroSchema: Equatable, Sendable {
	case null, boolean, int, long, float, double, bytes, string
	// case fixed(name: String, size: Int)
	// case `enum`(name: String, symbols: [String])
	case array(items: AvroSchema)
	case map(values: AvroSchema)
	case record(name: String, namespace: String? = nil, doc: String? = nil, aliases: [String]? = nil, fields: [Field])
	// case union([AvroSchema])
	case logical(type: LogicalType, underlying: AvroSchema)
	//
	/// A field of an Avro schema.
	public struct Field: Equatable, Sendable {
		let name: String
		let doc: String? = nil
		let type: AvroSchema
		let order: Order = .ignore
		let aliases: [String]? = nil
		// FIXME: Defaults
		/// Initialize a new field.
		/// - Parameters:
		///   - name: The name of the field.
		///   - type: The type of the field.
		public init(name: String, type: AvroSchema) {
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
