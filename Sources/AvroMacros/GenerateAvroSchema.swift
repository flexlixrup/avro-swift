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
public struct GenerateAvroSchema: MemberMacro {
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
				fieldEntries.append(".init(name: \"\(propName)\", type: \(mapped))")
			}
		}

		let fieldsJoined = fieldEntries.joined(separator: ",\n\t\t\t")

		let memberSource = """
			public static var avroSchema: AvroSchema {
				.record(name: "\(structName)", fields: [
					\(fieldsJoined)
				])
			}
			"""

		return [DeclSyntax(stringLiteral: memberSource)]
	}

	private static func mapToAvroType(rawType: String) -> String {
		let type = rawType.replacingOccurrences(of: "?", with: "").trimmingCharacters(in: .whitespacesAndNewlines)

		switch type {
			case "Int", "Int32":
				return ".int"
			case "Int64":
				return ".long"
			case "Float":
				return ".float"
			case "Double":
				return ".double"
			case "Bool":
				return ".boolean"
			case "String":
				return ".string"
			case "Data", "[UInt8]":
				return ".bytes"
			default:
				return "\(type).avroSchema"
		}
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
		let base = logicalExpr.replacingOccurrences(of: "AvroSchema.LogicalType.", with: "")
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
			.replacingOccurrences(of: "AvroSchema.LogicalType.", with: "")
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
				return ["Int64"]
			case ".timeMicros":
				return ["Int64"]
			case ".timestampMicros":
				return ["Int64"]
			case ".uuid":
				return ["String"]
			case ".decimal":
				return ["Data", "[UInt8]"]
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
}
