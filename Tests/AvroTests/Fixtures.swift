//
//  Fixtures.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import Avro
import Foundation

@Schema
struct User: Codable, Equatable {

	let id: Int64
	let name: String
	let email: String
}

@Schema
struct Person: Codable, Equatable {
	let name: String

	@LogicalType(.date)
	let dateOfBirth: Date
}

@Schema
struct Address: Codable, Equatable {
	let street: String
	let city: String
	let zip: Int32
}

@Schema
struct UserWithAddress: Codable, Equatable {
	let id: Int64
	let name: String
	let email: String
	let address: Address
}

struct Schemas {
	static let userAddressSchema: AvroSchema = .record(
		name: "User",
		fields: [
			.init(name: "id", type: .long),
			.init(name: "name", type: .string),
			.init(name: "email", type: .string),
			.init(
				name: "address",
				type: .record(
					name: "Address",
					fields: [
						.init(name: "street", type: .string),
						.init(name: "city", type: .string),
						.init(name: "zip", type: .int)
					]
				)
			)
		]
	)

	static let userSchema: AvroSchema = .record(
		name: "User",
		fields: [
			.init(name: "id", type: .long),
			.init(name: "name", type: .string),
			.init(name: "email", type: .string)
		]
	)

	static let logicalTypes: AvroSchema = .record(
		name: "LogicalTypes",
		fields: [
			.init(name: "dateCreated", type: .logical(type: .date, underlying: .int))
		]
	)
}
