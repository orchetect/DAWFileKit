//
//  SessionInfo Init.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftExtensions
import TimecodeKitCore

// MARK: - Parse methods

extension ProTools.SessionInfo {
    // TODO: add init(URL)
    
    /// Parse text file contents exported from Pro Tools.
    ///
    /// - Parameters:
    ///   - data: Raw file content.
    ///   - timeValueFormat: If the time format is known, supply it.
    ///     Otherwise pass `nil` to automatically detect the format.
    public init(
        fileContent data: Data,
        timeValueFormat: TimeValueFormat? = nil
    ) throws {
        var dummy: [ParseMessage] = []
        try self.init(
            fileContent: data,
            timeValueFormat: timeValueFormat,
            messages: &dummy
        )
    }
    
    /// Parse text file contents exported from Pro Tools.
    ///
    /// - Parameters:
    ///   - data: Raw file content.
    ///   - timeValueFormat: If the time format is known, supply it.
    ///     Otherwise pass `nil` to automatically detect the format.
    ///   - messages: An array of messages to update with information and errors during the parsing
    ///     process.
    public init(
        fileContent data: Data,
        timeValueFormat: TimeValueFormat? = nil,
        messages: inout [ParseMessage]
    ) throws {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        // Mac OS Roman (legacy 'TextEdit' format when exporting from Pro Tools)
        // https://en.wikipedia.org/wiki/Mac_OS_Roman
        // The MIME Content-Type for this encoding is "text/plain; charset=macintosh"
        // With the release of Mac OS X, Mac OS Roman and all other "scripts" (as classic Mac OS
        // called them) were replaced by UTF-8 as the standard character encoding for the Macintosh
        // operating system.
        // Pro Tools still retains the Mac OS Roman encoding as its default export option.
        // However UTF8 is selectable as an alternate encoding for export.
        
        // Note: NSString.stringEncoding() doesn't work as expected for our needs to
        // attempt to detect text encoding of the file. Instead, a custom heuristic works
        // more reliably as follows:
        // 1. Attempt decoding UTF8 first, which often fails if extended
        //    Mac OS Roman character codes are present.
        // 2. Then fall back to Mac OS Roman as the second option.
        // 3. Fail if neither encoding succeeds, since these are the only 2 encodings
        //    that Pro Tools exports with.
        
        var rawString: String
        if let decoded = String(data: data, encoding: .utf8) {
            addParseMessage(.info("Detected format: UTF8"))
            rawString = decoded
        } else if let decoded = String(data: data, encoding: .macOSRoman) {
            addParseMessage(.info("Detected format: Mac OS Roman (Legacy 'TextEdit')"))
            rawString = decoded
        } else {
            throw ParseError.general(
                "Error: could not convert document file data to string."
            )
        }
        
        try self.init(
            fileContent: rawString,
            timeValueFormat: timeValueFormat,
            messages: &messages
        )
    }
}

extension ProTools.SessionInfo {
    /// Parse text file contents exported from Pro Tools.
    ///
    /// - Parameters:
    ///   - fileContent: Raw file content.
    ///   - timeValueFormat: If the time format is known, supply it.
    ///     Otherwise pass `nil` to automatically detect the format.
    public init(
        fileContent: String,
        timeValueFormat: TimeValueFormat? = nil
    ) throws {
        var dummy: [ParseMessage] = []
        try self.init(
            fileContent: fileContent,
            timeValueFormat: timeValueFormat,
            messages: &dummy
        )
    }
    
    /// Parse text file contents exported from Pro Tools.
    ///
    /// - Parameters:
    ///   - fileContent: Raw file content.
    ///   - timeValueFormat: If the time format is known, supply it.
    ///     Otherwise pass `nil` to automatically detect the format.
    ///   - messages: An array of messages to update with information and errors during the parsing
    ///     process.
    public init(
        fileContent: String,
        timeValueFormat: TimeValueFormat? = nil,
        messages: inout [ParseMessage]
    ) throws {
        let parsed = try Self.parse(
            fileContent: fileContent,
            timeValueFormat: timeValueFormat
        )
        self = parsed.sessionInfo
        messages = parsed.messages
    }
}
