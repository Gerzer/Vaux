//
//  Vaux.swift
//
//
//  Created by David Okun on 6/6/19.
//

import Foundation

// MARK: - Vaux Interface class
/// An instance of Vaux will render a document for you and put the content where you want it to go.
/// - Parameters:
///   - outputLocation: Chooses whether to render the document to stdout, which is effective for quick testing or to a file with a specified name and path, which will always end in `.html`
public class Vaux {
	
	public enum VauxOutput {
		
		case stdout
		case file(filepath: FilePath)
		
	}
	
	/// Default parameter for where render output goes
	public var outputLocation: VauxOutput = .stdout
	
	/// Initializer must be public to create instance
	public init() { }
	
	/// Handles retrieving correct `HTMLOutputStream` for where rendered document will go
	private func getStream(for content: HTML) throws -> HTMLOutputStream {
		switch self.outputLocation {
		case .stdout:
			return HTMLOutputStream(FileHandle.standardOutput, content.getTag())
		case .file(let filepath):
			do {
				guard let url = VauxFileHelper.createFile(filepath) else {
					throw VauxFileHelperError.noFile
				}
				let handler = try FileHandle(forWritingTo: url)
				return HTMLOutputStream(handler, content.getTag())
			} catch let error {
				throw error
			}
		}
	}
	
	/// Renders `HTML` into a static HTML file.
	/// - Parameters:
	///   - content: A function that builds `HTML` that you intend to render.
	public func render(_ content: HTML) throws {
		do {
			let stream = try self.getStream(for: content)
			content.renderAsHTML(into: stream, attributes: [])
		} catch let error {
			throw error
		}
	}
	
}
