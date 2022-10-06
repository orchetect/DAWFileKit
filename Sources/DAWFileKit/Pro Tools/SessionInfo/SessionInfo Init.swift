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
    public init(fileContent data: Data) throws {
        var dummy: [ParseMessage] = []
        try self.init(data: data, messages: &dummy)
    }
    
    /// Parse text file contents exported from Pro Tools.
    public init(
        data: Data,
        messages: inout [ParseMessage]
    ) throws {
        guard let dataToString = String(data: data, encoding: .ascii) else {
            throw ParseError.general(
                "Error: could not convert document file data to String."
            )
        }
        
        try self.init(fileContent: dataToString, messages: &messages)
    }
}

extension ProTools.SessionInfo {
    /// Parse text file contents exported from Pro Tools.
    public init(fileContent: String) throws {
        var dummy: [ParseMessage] = []
        try self.init(fileContent: fileContent, messages: &dummy)
    }
    
    /// Parse text file contents exported from Pro Tools.
    public init(
        fileContent: String,
        messages: inout [ParseMessage]
    ) throws {
        let parsed = try Self.parse(fileContent: fileContent)
        self = parsed.sessionInfo
        messages = parsed.messages
    }
}
