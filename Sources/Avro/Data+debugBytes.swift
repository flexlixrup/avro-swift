//
//  Data+debugBytes.swift
//  avro-swift
//
//  Created by Felix Ruppert on 14.11.25.
//

import Foundation

extension Data {
	var debugBytes: String {
		self.map { String(format: "0x%02X", $0) }.joined(separator: ", ")
	}
}
