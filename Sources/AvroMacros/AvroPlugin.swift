//
//  AvroPlugin.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct AvroPlugin: CompilerPlugin {
	let providingMacros: [Macro.Type] = [
		GenerateAvroSchema.self,
		LogicalTypeAttribute.self
	]
}
