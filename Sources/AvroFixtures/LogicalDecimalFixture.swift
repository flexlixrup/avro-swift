//
//  LogicalDecimalFixture.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Avro
import Foundation

public enum LogicalDecimalFixture {

	@Schema
	public struct Def: Codable, Equatable, Sendable {
		let name: String
		@LogicalType(.decimal(scale: 2, precision: 9))
		let amount: Decimal
	}

	public static let schema: AvroSchema = .record(
		name: "DecimalRecord",
		fields: [
			.init(name: "name", type: .string),
			.init(name: "amount", type: .logical(type: .decimal(scale: 2, precision: 9), underlying: .bytes))
		]
	)

	public static let avroSchemaString = """
			{
				"type": "record",
		 "name": "DecimalRecord",
		 "fields": [
			 {
				 "name": "name",
				 "type": "string"
			 },
			 {
				 "name": "amount",
				 "type": "bytes",
				 "logicalType": "decimal",
				 "precision": 9,
				 "scale": 2
			 }
		 ]
		}
		"""

	public static let instance = Def(name: "Ada", amount: Decimal(string: "1234.56")!)
	public static let serialized = Data([0x06, 0x41, 0x64, 0x61, 0x06, 0x01, 0xe2, 0x40])

}
