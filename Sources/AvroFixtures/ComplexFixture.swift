//
//  ComplexFixture.swift
//  avro-swift
//
//  Created by Felix Ruppert on 15.11.25.
//

import Avro
import Foundation

public enum ComplexFixture {

	@Schema
	public struct DeepRecord: Codable, Equatable, Sendable {
		let id: Int32
		let data: Data
	}

	@Schema
	public struct MixedItem: Codable, Equatable, Sendable {
		let itemId: String
		let values: [String: Double]
		let nested: [[String: Bool]]
	}

	@Schema
	public struct NestedRecord: Codable, Equatable, Sendable {
		let userId: Int64
		let properties: [String: [String]]
		let scores: [Float]
	}

	@Schema
	public struct Def: Codable, Equatable, Sendable {
		let eventId: String
		let timestamp: Int64
		let metadata: [String: String]
		let tags: [String]
		let metrics: [String: Double]
		let nestedData: NestedRecord
		let arrayOfMaps: [[String: Int32]]
		let deeplyNested: [String: [String: [DeepRecord]]]
		let mixedArray: [MixedItem]
	}

	public static let schema: AvroSchema = .record(
		name: "Def",
		namespace: nil,
		fields: [
			Avro.AvroSchema.Field(
				name: "eventId",
				type: Avro.AvroSchema.string,
			),
			Avro.AvroSchema.Field(
				name: "timestamp",
				type: Avro.AvroSchema.long,
			),
			Avro.AvroSchema.Field(
				name: "metadata",
				type: Avro.AvroSchema.map(values: Avro.AvroSchema.string),
			),
			Avro.AvroSchema.Field(
				name: "tags",
				type: Avro.AvroSchema.array(items: Avro.AvroSchema.string),
			),
			Avro.AvroSchema.Field(
				name: "metrics",
				type: Avro.AvroSchema.map(values: Avro.AvroSchema.double),
			),
			Avro.AvroSchema.Field(
				name: "nestedData",
				type: Avro.AvroSchema.record(
					name: "NestedRecord",
					namespace: nil,
					fields: [
						Avro.AvroSchema.Field(
							name: "userId",
							type: Avro.AvroSchema.long,
						),
						Avro.AvroSchema.Field(
							name: "properties",
							type: Avro.AvroSchema.map(values: Avro.AvroSchema.array(items: Avro.AvroSchema.string)),
						),
						Avro.AvroSchema.Field(
							name: "scores",
							type: Avro.AvroSchema.array(items: Avro.AvroSchema.float),
						)
					]
				),
			),
			Avro.AvroSchema.Field(
				name: "arrayOfMaps",
				type: Avro.AvroSchema.array(items: Avro.AvroSchema.map(values: Avro.AvroSchema.int)),
			),
			Avro.AvroSchema.Field(
				name: "deeplyNested",
				type: Avro.AvroSchema.map(
					values: Avro.AvroSchema.map(
						values: Avro.AvroSchema.array(
							items: Avro.AvroSchema.record(
								name: "DeepRecord",
								namespace: nil,
								fields: [
									Avro.AvroSchema.Field(
										name: "id",
										type: Avro.AvroSchema.int,
									),
									Avro.AvroSchema.Field(
										name: "data",
										type: Avro.AvroSchema.bytes,
									)
								]
							)
						)
					)
				),
			),
			Avro.AvroSchema.Field(
				name: "mixedArray",
				type: Avro.AvroSchema.array(
					items: Avro.AvroSchema.record(
						name: "MixedItem",
						namespace: nil,
						fields: [
							Avro.AvroSchema.Field(
								name: "itemId",
								type: Avro.AvroSchema.string,
							),
							Avro.AvroSchema.Field(
								name: "values",
								type: Avro.AvroSchema.map(values: Avro.AvroSchema.double),
							),
							Avro.AvroSchema.Field(
								name: "nested",
								type: Avro.AvroSchema.array(items: Avro.AvroSchema.map(values: Avro.AvroSchema.boolean)),
							)
						]
					)
				),
			)
		]
	)

	public static let instance = Def(
		eventId: "evt-12345",
		timestamp: 1_700_000_000_000_000,
		metadata: [
			"source": "web",
			"region": "us-west",
			"version": "1.0"
		],
		tags: ["analytics", "user-event", "production"],
		metrics: [
			"duration": 123.45,
			"responseTime": 67.89,
			"errorRate": 0.01
		],
		nestedData: NestedRecord(
			userId: 42,
			properties: [
				"interests": ["tech", "music", "sports"],
				"preferences": ["dark-mode", "notifications"]
			],
			scores: [95.5, 87.3, 92.1]
		),
		arrayOfMaps: [
			["clicks": 10, "views": 100],
			["shares": 5, "likes": 50]
		],
		deeplyNested: [
			"level1": [
				"level2": [
					DeepRecord(id: 1, data: "binary data 1".data(using: .utf8)!),
					DeepRecord(id: 2, data: "binary data 2".data(using: .utf8)!)
				]
			]
		],
		mixedArray: [
			MixedItem(
				itemId: "item-001",
				values: ["price": 99.99, "discount": 0.15],
				nested: [
					["active": true, "verified": false],
					["enabled": true]
				]
			)
		]
	)

	public static let avroSchemaString = """
		  {
			"type": "record",
			"name": "ComplexEvent",
			"namespace": "com.example.avro",
			"doc": "A complex event record with nested structures",
			"fields": [
			  {
				"name": "eventId",
				"type": "string",
				"doc": "Unique event identifier"
			  },
			  {
				"name": "timestamp",
				"type": "long"
				}
			  },
			  {
				"name": "metadata",
				"type": {
				  "type": "map",
				  "values": "string"
				},
				"doc": "Key-value metadata pairs"
			  },
			  {
				"name": "tags",
				"type": {
				  "type": "array",
				  "items": "string"
				}
			  },
			  {
				"name": "metrics",
				"type": {
				  "type": "map",
				  "values": "double"
				}
			  },
			  {
				"name": "nestedData",
				"type": {
				  "type": "record",
				  "name": "NestedRecord",
				  "fields": [
					{
					  "name": "userId",
					  "type": "long"
					},
					{
					  "name": "properties",
					  "type": {
						"type": "map",
						"values": {
						  "type": "array",
						  "items": "string"
						}
					  },
					  "doc": "Map of arrays - complex nested structure"
					},
					{
					  "name": "scores",
					  "type": {
						"type": "array",
						"items": "float"
					  }
					}
				  ]
				}
			  },
			  {
				"name": "arrayOfMaps",
				"type": {
				  "type": "array",
				  "items": {
					"type": "map",
					"values": "int"
				  }
				},
				"doc": "Array containing maps"
			  },
			  {
				"name": "deeplyNested",
				"type": {
				  "type": "map",
				  "values": {
					"type": "map",
					"values": {
					  "type": "array",
					  "items": {
						"type": "record",
						"name": "DeepRecord",
						"fields": [
						  {
							"name": "id",
							"type": "int"
						  },
						  {
							"name": "data",
							"type": "bytes"
						  }
						]
					  }
					}
				  }
				},
				"doc": "Map of maps of arrays of records"
			  },
			  {
				"name": "mixedArray",
				"type": {
				  "type": "array",
				  "items": {
					"type": "record",
					"name": "MixedItem",
					"fields": [
					  {
						"name": "itemId",
						"type": "string"
					  },
					  {
						"name": "values",
						"type": {
						  "type": "map",
						  "values": "double"
						}
					  },
					  {
						"name": "nested",
						"type": {
						  "type": "array",
						  "items": {
							"type": "map",
							"values": "boolean"
						  }
						}
					  }
					]
				  }
				}
			  }
			]
		  }
		"""

	public static let serialized = Data([
		0x12, 0x65, 0x76, 0x74, 0x2d, 0x31, 0x32, 0x33, 0x34, 0x35, 0x80, 0x80, 0xf2, 0x81, 0x83, 0x89, 0x85, 0x06, 0x06, 0x0c,
		0x73, 0x6f, 0x75, 0x72, 0x63, 0x65, 0x06, 0x77, 0x65, 0x62, 0x0c, 0x72, 0x65, 0x67, 0x69, 0x6f, 0x6e, 0x0e, 0x75, 0x73,
		0x2d, 0x77, 0x65, 0x73, 0x74, 0x0e, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x06, 0x31, 0x2e, 0x30, 0x00, 0x06, 0x12,
		0x61, 0x6e, 0x61, 0x6c, 0x79, 0x74, 0x69, 0x63, 0x73, 0x14, 0x75, 0x73, 0x65, 0x72, 0x2d, 0x65, 0x76, 0x65, 0x6e, 0x74,
		0x14, 0x70, 0x72, 0x6f, 0x64, 0x75, 0x63, 0x74, 0x69, 0x6f, 0x6e, 0x00, 0x06, 0x10, 0x64, 0x75, 0x72, 0x61, 0x74, 0x69,
		0x6f, 0x6e, 0xcd, 0xcc, 0xcc, 0xcc, 0xcc, 0xdc, 0x5e, 0x40, 0x18, 0x72, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x54,
		0x69, 0x6d, 0x65, 0x29, 0x5c, 0x8f, 0xc2, 0xf5, 0xf8, 0x50, 0x40, 0x12, 0x65, 0x72, 0x72, 0x6f, 0x72, 0x52, 0x61, 0x74,
		0x65, 0x7b, 0x14, 0xae, 0x47, 0xe1, 0x7a, 0x84, 0x3f, 0x00, 0x54, 0x04, 0x12, 0x69, 0x6e, 0x74, 0x65, 0x72, 0x65, 0x73,
		0x74, 0x73, 0x06, 0x08, 0x74, 0x65, 0x63, 0x68, 0x0a, 0x6d, 0x75, 0x73, 0x69, 0x63, 0x0c, 0x73, 0x70, 0x6f, 0x72, 0x74,
		0x73, 0x00, 0x16, 0x70, 0x72, 0x65, 0x66, 0x65, 0x72, 0x65, 0x6e, 0x63, 0x65, 0x73, 0x04, 0x12, 0x64, 0x61, 0x72, 0x6b,
		0x2d, 0x6d, 0x6f, 0x64, 0x65, 0x1a, 0x6e, 0x6f, 0x74, 0x69, 0x66, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x73, 0x00,
		0x00, 0x06, 0x00, 0x00, 0xbf, 0x42, 0x9a, 0x99, 0xae, 0x42, 0x33, 0x33, 0xb8, 0x42, 0x00, 0x04, 0x04, 0x0c, 0x63, 0x6c,
		0x69, 0x63, 0x6b, 0x73, 0x14, 0x0a, 0x76, 0x69, 0x65, 0x77, 0x73, 0xc8, 0x01, 0x00, 0x04, 0x0c, 0x73, 0x68, 0x61, 0x72,
		0x65, 0x73, 0x0a, 0x0a, 0x6c, 0x69, 0x6b, 0x65, 0x73, 0x64, 0x00, 0x00, 0x02, 0x0c, 0x6c, 0x65, 0x76, 0x65, 0x6c, 0x31,
		0x02, 0x0c, 0x6c, 0x65, 0x76, 0x65, 0x6c, 0x32, 0x04, 0x02, 0x1a, 0x62, 0x69, 0x6e, 0x61, 0x72, 0x79, 0x20, 0x64, 0x61,
		0x74, 0x61, 0x20, 0x31, 0x04, 0x1a, 0x62, 0x69, 0x6e, 0x61, 0x72, 0x79, 0x20, 0x64, 0x61, 0x74, 0x61, 0x20, 0x32, 0x00,
		0x00, 0x00, 0x02, 0x10, 0x69, 0x74, 0x65, 0x6d, 0x2d, 0x30, 0x30, 0x31, 0x04, 0x0a, 0x70, 0x72, 0x69, 0x63, 0x65, 0x8f,
		0xc2, 0xf5, 0x28, 0x5c, 0xff, 0x58, 0x40, 0x10, 0x64, 0x69, 0x73, 0x63, 0x6f, 0x75, 0x6e, 0x74, 0x33, 0x33, 0x33, 0x33,
		0x33, 0x33, 0xc3, 0x3f, 0x00, 0x04, 0x04, 0x0c, 0x61, 0x63, 0x74, 0x69, 0x76, 0x65, 0x01, 0x10, 0x76, 0x65, 0x72, 0x69,
		0x66, 0x69, 0x65, 0x64, 0x00, 0x00, 0x02, 0x0e, 0x65, 0x6e, 0x61, 0x62, 0x6c, 0x65, 0x64, 0x01, 0x00, 0x00, 0x00
	])
}
