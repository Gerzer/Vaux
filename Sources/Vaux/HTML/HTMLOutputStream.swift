//
//  HTMLOutputStream.swift
//
//
//  Created by David Okun on 6/6/19.
//

import Foundation

// MARK: - HTMLOutputStream
/// A helper class for rendering formatted HTML to a given `TextOutputStream`.
public class HTMLOutputStream {
	
	// Regular expression matching the special tokens of HTML: &word; or #number; where number can also be in hex.
	static let specialTokenRegExp = #"&\w+;|&#[0-9]+;|&#[xX][a-fA-F0-9]+;"#
	
	var indentation: Int = 0
	public internal(set) var output: TextOutputStream
	
	/// Create an `HTMLOutputStream` that will render `HTML` nodes as HTML text.
	public init(_ output: TextOutputStream, _ tag: String?) {
		self.output = output
		if tag == "html" {
			self.write("<!DOCTYPE html>")
			self.writeNewline()
		}
	}
	
	func withIndent(_ f: () -> Void) {
		self.indentation += 2
		f()
		self.indentation -= 2
	}
	
	func writeIndent() {
		self.write(String(repeating: " ", count: indentation))
	}
	
	func line<Str: StringProtocol>(_ line: Str) {
		self.writeIndent()
		self.write(line)
		self.writeNewline()
	}
	
	func write<Str: StringProtocol>(_ text: Str) {
		self.output.write(String(text))
	}
	
	func writeDoubleQuoted(_ string: String) {
		self.write("\"")
		self.write(string)
		self.write("\"")
	}
	
	func writeNewline() {
		self.write("\n")
	}
	
	func writeCarriageReturn() {
		self.write("\r")
	}
	
	func writeEscaped<Str: StringProtocol>(_ string: Str) {
		let tokens = self.tokenize(text: String(string), using: HTMLOutputStream.specialTokenRegExp)
		for (matchingSpecial, token) in tokens {
			if matchingSpecial {
				self.write(token)
			} else {
				for c in token {
					switch c {
					case "\"":
						self.write("&quot;")
					case "&":
						self.write("&amp;")
					case "<":
						self.write("&lt;")
					case ">":
						self.write("&gt;")
					default:
						write(String(c))
					}
				}
			}
		}
	}
	
	/// Split the full `String` with matching tokens separated.
	/// - Parameter text: The text to split
	/// - Parameter regex: The regular expression used to split.
	/// - Returns: A array of tuple `Bool` and `String` where the the matching tokens have `matching` set to `true`.
	/// - Note: The order of the string is kept.
	func tokenize(text: String, using regex: String) -> [(matching: Bool, token: String)] {
		do {
			let regex = try NSRegularExpression(pattern: regex)
			let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
			var array: [Int] = []
			var status = (results.first?.range.location == 0)
			if status == false {
				array.append(0)
			}
			for r in results {
				array.append(r.range.location)
				array.append(r.range.length + r.range.location)
			}
			array.append(text.count)
			var components: [(Bool, String)] = []
			for (index, value) in array.dropLast().enumerated() {
				if let range = Range(NSRange(location: value, length: array[index + 1] - value), in: text) {
					components.append((status, String(text[range])))
					status = !status
				} else {
					//This is an error; return immediately!
					return []
				}
			}
			return components
		} catch {
			return []
		}
	}
	
	/// Renders the provided `HTML` node as HTML text to the receiver's stream.
	public func render(_ content: HTML) {
		content.renderAsHTML(into: self, attributes: [])
	}
	
}

extension FileHandle: TextOutputStream {
	
	public func write(_ string: String) {
		self.write(Data(string.utf8))
	}
	
}
