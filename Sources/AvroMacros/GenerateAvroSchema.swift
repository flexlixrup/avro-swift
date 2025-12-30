import Foundation
//
//  AvroMacros.swift
//  avro-swift
//
//  Created by Felix Ruppert on 09.11.25.
//
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// A macro to automatically generate an Avro Schema for an object.
public struct GenerateAvroSchema: MemberMacro, ExtensionMacro {
	public static func expansion(
		of attribute: AttributeSyntax,
		providingMembersOf declaration: some DeclGroupSyntax,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		guard let structDecl = declaration.as(StructDeclSyntax.self) else { return [] }

		let structName = structDecl.name.text

		var fieldEntries: [String] = []

		for member in structDecl.memberBlock.members {
			guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }

			for binding in varDecl.bindings {
				guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
				let propName = pattern.identifier.text
				guard let typeSyntax = binding.typeAnnotation?.type else { continue }
				let rawType = typeSyntax.description.trimmingCharacters(in: .whitespacesAndNewlines)
				let normalizedType = normalizeTypeName(rawType)

				let logicalExpr = findLogicalTypeAttribute(on: varDecl, binding: binding)
				let mapped: String
				if let logicalExpr {
					// Validate allowed Swift types for this logical type
					if let allowed = allowedSwiftTypes(forLogicalExpr: logicalExpr),
						!allowed.contains(normalizedType)
					{
						diagnoseInvalidLogicalType(
							on: binding,
							in: context,
							propName: propName,
							logicalExpr: logicalExpr,
							actualType: rawType,
							allowed: allowed
						)
					}
					let underlying = underlyingForLogicalExpr(logicalExpr)
					mapped = ".logical(type: \(logicalExpr), underlying: \(underlying))"
				} else {
					mapped = mapToAvroType(rawType: rawType)
				}
				fieldEntries.append(".init(name: Self.CodingKeys.\(propName).stringValue, type: \(mapped))")
			}
		}

		let fieldsJoined = fieldEntries.joined(separator: ",\n\t\t\t")

		// Generate encode(to:) method that handles optionals properly
		var encodeStatements: [String] = []
		for member in structDecl.memberBlock.members {
			guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }
			for binding in varDecl.bindings {
				guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
				let propName = pattern.identifier.text
				guard let typeSyntax = binding.typeAnnotation?.type else { continue }
				let rawType = typeSyntax.description.trimmingCharacters(in: .whitespacesAndNewlines)

				// Check if this is an optional type
				if rawType.hasSuffix("?") {
					// For optional fields, we need to explicitly encode nil
					encodeStatements.append(
						"""
							if let value = self.\(propName) {
								try container.encode(value, forKey: .\(propName))
							} else {
								try container.encodeNil(forKey: .\(propName))
							}
						"""
					)
				} else {
					// For non-optional fields, use normal encoding
					encodeStatements.append("try container.encode(self.\(propName), forKey: .\(propName))")
				}
			}
		}

		let encodeBody = encodeStatements.joined(separator: "\n\t\t")

		let schemaSource = """
			public static var avroSchema: AvroSchemaDefinition {
				.record(name: "\(structName)", fields: [
					\(fieldsJoined)
				])
			}
			"""

		let schemaStringSource = """
			public static var avroSchemaString: String {
				get throws {
					try avroSchema.toJSONString()
				}
			}
			"""

		let encodeSource = """
			public func encode(to encoder: Encoder) throws {
				var container = encoder.container(keyedBy: CodingKeys.self)
				\(encodeBody)
			}
			"""

		return [
			DeclSyntax(stringLiteral: schemaSource),
			DeclSyntax(stringLiteral: schemaStringSource),
			DeclSyntax(stringLiteral: encodeSource)
		]
	}

	private static func mapToAvroType(rawType: String) -> String {
		// Check if the type is optional (ends with ?)
		let isOptional = rawType.hasSuffix("?")
		let type = rawType.replacingOccurrences(of: "?", with: "").trimmingCharacters(in: .whitespacesAndNewlines)

		let baseSchema: String
		switch type {
			case "Int", "Int32":
				baseSchema = ".int"
			case "Int64":
				baseSchema = ".long"
			case "Float":
				baseSchema = ".float"
			case "Double":
				baseSchema = ".double"
			case "Bool":
				baseSchema = ".boolean"
			case "String":
				baseSchema = ".string"
			case "Data", "[UInt8]":
				baseSchema = ".bytes"
			default:
				guard let nested = resolveNested(type: type) else {
					baseSchema = "\(type).avroSchema"
					// For optional custom types, we need to wrap in union
					if isOptional {
						return ".union([.null, \(baseSchema)])"
					}
					return baseSchema
				}
				baseSchema = nested
		}

		// If the original type was optional, wrap it in a union with null
		if isOptional {
			return ".union([.null, \(baseSchema)])"
		}

		return baseSchema
	}

	private static func resolveNested(type: String) -> String? {
		// Normalize whitespace
		let t = type.trimmingCharacters(in: .whitespacesAndNewlines)
		guard t.hasPrefix("[") && t.hasSuffix("]") else { return nil }

		// Strip outer brackets
		let inner = String(t.dropFirst().dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)

		// Determine if this is an array [T] or a dictionary [K: V] at the top level.
		// We need to find a top-level colon, not inside nested brackets.
		func topLevelColonIndex(in s: String) -> String.Index? {
			var depth = 0
			var idx = s.startIndex
			while idx < s.endIndex {
				let ch = s[idx]
				if ch == "[" { depth += 1 } else if ch == "]" { depth -= 1 } else if ch == ":" && depth == 0 { return idx }
				idx = s.index(after: idx)
			}
			return nil
		}

		guard let colon = topLevelColonIndex(in: inner) else {
			// Array [T]
			let elementSchema = mapToAvroType(rawType: inner)
			return ".array(items: \(elementSchema))"
		}
		let keyPart = inner[..<colon].trimmingCharacters(in: .whitespacesAndNewlines)
		let valuePart = inner[inner.index(after: colon)...].trimmingCharacters(in: .whitespacesAndNewlines)

		// Only String keys are supported by Avro maps
		let normalizedKey = normalizeTypeName(keyPart)
		guard normalizedKey == "String" else {
			// Unsupported key type for Avro maps; let caller handle as record reference
			return nil
		}
		let valueSchema = mapToAvroType(rawType: valuePart)
		return ".map(values: \(valueSchema))"
	}

	private static func findLogicalTypeAttribute(on varDecl: VariableDeclSyntax, binding: PatternBindingSyntax) -> String? {
		if let expr = extractLogicalType(from: varDecl.attributes) { return expr }
		return nil
	}

	private static func extractLogicalType(from attributes: AttributeListSyntax?) -> String? {
		guard let attributes else { return nil }
		for attr in attributes {
			guard let attrSyntax = attr.as(AttributeSyntax.self) else { continue }
			let name = attrSyntax.attributeName.trimmedDescription
			if name == "LogicalType" || name.hasSuffix(".LogicalType") {
				if let args = attrSyntax.arguments {
					let text = args.description.trimmingCharacters(in: .whitespacesAndNewlines)
					if text.hasPrefix("(") && text.hasSuffix(")") {
						let inner = String(text.dropFirst().dropLast())
						guard let comma = inner.firstIndex(of: ",") else {
							return inner.trimmingCharacters(in: .whitespacesAndNewlines)
						}
						let firstPart = inner[..<comma]
						return String(firstPart).trimmingCharacters(in: .whitespacesAndNewlines)
					}
					return text
				}
				return nil
			}
		}
		return nil
	}

	private static func underlyingForLogicalExpr(_ logicalExpr: String) -> String {
		let base = logicalExpr.replacingOccurrences(of: "AvroSchemaDefinition.LogicalType.", with: "")
			.replacingOccurrences(of: ".LogicalType.", with: "")
			.trimmingCharacters(in: .whitespacesAndNewlines)

		if base.hasPrefix(".date") { return ".int" }
		if base.hasPrefix(".timeMillis") { return ".int" }
		if base.hasPrefix(".timestampMillis") { return ".long" }
		if base.hasPrefix(".timeMicros") { return ".long" }
		if base.hasPrefix(".timestampMicros") { return ".long" }
		if base.hasPrefix(".uuid") { return ".string" }
		if base.hasPrefix(".decimal") { return ".bytes" }

		// Fallback: default to bytes if unknown
		return ".bytes"
	}

	private static func normalizeTypeName(_ raw: String) -> String {
		let noOptional = raw.replacingOccurrences(of: "?", with: "")
			.trimmingCharacters(in: .whitespacesAndNewlines)
		let components = noOptional.split(separator: ".").map(String.init)
		let base = components.last ?? noOptional
		switch base {
			case "Int32": return "Int32"
			case "Int64": return "Int64"
			case "Int": return "Int"
			case "Float": return "Float"
			case "Double": return "Double"
			case "Bool": return "Bool"
			case "String": return "String"
			case "Data": return "Data"
			case "UInt8": return "UInt8"
			default:
				return base
		}
	}

	private static func allowedSwiftTypes(forLogicalExpr logicalExpr: String) -> Set<String>? {
		let base =
			logicalExpr
			.replacingOccurrences(of: "AvroSchemaDefinition.LogicalType.", with: "")
			.replacingOccurrences(of: ".LogicalType.", with: "")
			.trimmingCharacters(in: .whitespacesAndNewlines)

		let caseName: String = {
			if let idx = base.firstIndex(of: "(") { return String(base[..<idx]) }
			return base
		}()

		switch caseName {
			case ".date":
				return ["Date"]
			case ".timeMillis":
				return ["Int", "Int32"]
			case ".timestampMillis":
				return ["Int64", "Date"]
			case ".timeMicros":
				return ["Int", "Int64"]
			case ".timestampMicros":
				return ["Int64", "Date"]
			case ".uuid":
				return ["String", "UUID"]
			case ".decimal":
				return ["Decimal"]
			default:
				return nil // Unknown logical type; skip validation
		}
	}

	private static func diagnoseInvalidLogicalType(
		on binding: PatternBindingSyntax,
		in context: some MacroExpansionContext,
		propName: String,
		logicalExpr: String,
		actualType: String,
		allowed: Set<String>
	) {
		let allowedList = allowed.sorted().joined(separator: ", ")
		let message =
			"@LogicalType \(logicalExpr) requires one of [\(allowedList)] but found '\(actualType)' for property '\(propName)'."
		let diag = Diagnostic(
			node: Syntax(binding),
			message: SimpleDiagnosticMessage(message: message, severity: .error)
		)
		context.diagnose(diag)
	}

	private struct SimpleDiagnosticMessage: DiagnosticMessage {
		let message: String
		let severity: DiagnosticSeverity
		var diagnosticID: MessageID { .init(domain: "GenerateAvroSchema", id: "invalid-logical-type") }
		var messageText: String { message }
	}

	public static func expansion(
		of node: AttributeSyntax,
		attachedTo declaration: some DeclGroupSyntax,
		providingExtensionsOf type: some TypeSyntaxProtocol,
		conformingTo protocols: [TypeSyntax],
		in context: some MacroExpansionContext
	) throws -> [ExtensionDeclSyntax] {
		let avroProtocolExtension: DeclSyntax =
			"""
			extension \(type.trimmed): AvroProtocol {}
			"""

		guard let extensionDecl = avroProtocolExtension.as(ExtensionDeclSyntax.self) else {
			return []
		}

		return [extensionDecl]
	}
}
