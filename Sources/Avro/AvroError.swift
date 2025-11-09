//
//  AvroError.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

enum AvroError: Error {
	case endOfData
	case integerOverflow
	case negativeLength
	case invalidUTF8
}
