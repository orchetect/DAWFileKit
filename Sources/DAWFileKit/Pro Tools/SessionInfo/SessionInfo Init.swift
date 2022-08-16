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
    public init(data: Data) throws {
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
        
        try self.init(string: dataToString, messages: &messages)
    }
}

extension ProTools.SessionInfo {
    /// Parse text file contents exported from Pro Tools.
    public init(string: String) throws {
        var dummy: [ParseMessage] = []
        try self.init(string: string, messages: &dummy)
    }
    
    /// Parse text file contents exported from Pro Tools.
    public init(
        string: String,
        messages: inout [ParseMessage]
    ) throws {
        let parsed = try Self.parse(string: string)
        self = parsed.sessionInfo
        messages = parsed.messages
    }
}
