//
//  LogicalTypeAttribute.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// A macro to annotate declarations with their logical value.
public struct LogicalTypeAttribute: PeerMacro {
	public static func expansion(
		of node: AttributeSyntax,
		providingPeersOf declaration: some DeclSyntaxProtocol,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		[]
	}
}
