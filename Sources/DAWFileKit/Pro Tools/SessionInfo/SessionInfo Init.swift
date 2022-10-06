//
//  SessionInfo Init.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

// MARK: - Parse methods

extension ProTools.SessionInfo {
    /// Parse text file contents exported from Pro Tools.
    ///
    /// - Parameters:
    ///   - data: Raw file content.
    ///   - timeValueFormat: If the time format is known, supply it. Otherwise pass `nil` to automatically detect the format.
    public init(
        fileContent data: Data,
        timeValueFormat: TimeValueFormat? = nil
    ) throws {
        var dummy: [ParseMessage] = []
        try self.init(
            data: data,
            timeValueFormat: timeValueFormat,
            messages: &dummy
        )
    }
    
    /// Parse text file contents exported from Pro Tools.
    ///
    /// - Parameters:
    ///   - data: Raw file content.
    ///   - timeValueFormat: If the time format is known, supply it. Otherwise pass `nil` to automatically detect the format.
    ///   - messages: An array of messages to update with information and errors during the parsing process.
    public init(
        data: Data,
        timeValueFormat: TimeValueFormat? = nil,
        messages: inout [ParseMessage]
    ) throws {
        guard let dataToString = String(data: data, encoding: .ascii) else {
            throw ParseError.general(
                "Error: could not convert document file data to String."
            )
        }
        
        try self.init(
            fileContent: dataToString,
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
    ///   - timeValueFormat: If the time format is known, supply it. Otherwise pass `nil` to automatically detect the format.
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
    ///   - timeValueFormat: If the time format is known, supply it. Otherwise pass `nil` to automatically detect the format.
    ///   - messages: An array of messages to update with information and errors during the parsing process.
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
