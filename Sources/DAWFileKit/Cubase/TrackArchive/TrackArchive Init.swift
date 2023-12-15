//
//  TrackArchive Init.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore
import TimecodeKit

// MARK: - Init

extension Cubase.TrackArchive {
    /// Parse Track Archive XML file contents exported from Cubase.
    public init(fileContent data: Data) throws {
        var dummy: [ParseMessage] = []
        try self.init(fileContent: data, messages: &dummy)
    }
    
    /// Parse Track Archive XML file contents exported from Cubase.
    public init(
        fileContent data: Data,
        messages: inout [ParseMessage]
    ) throws {
        let xmlDocument = try XMLDocument(data: data)
        let parsed = try Self.parse(fileContent: xmlDocument)
        self = parsed.trackArchive
        messages = parsed.messages
    }
}

extension Cubase.TrackArchive {
    /// Parse Track Archive XML file contents exported from Cubase.
    public init(fileContent xml: XMLDocument) throws {
        var dummy: [ParseMessage] = []
        try self.init(fileContent: xml, messages: &dummy)
    }
    
    /// Parse Track Archive XML file contents exported from Cubase.
    public init(
        fileContent xml: XMLDocument,
        messages: inout [ParseMessage]
    ) throws {
        let parsed = try Self.parse(fileContent: xml)
        self = parsed.trackArchive
        messages = parsed.messages
    }
}

extension Cubase.TrackArchive {
    /// Parse Track Archive XML file contents exported from Cubase.
    public init(fileContent xmlRoot: XMLElement) {
        var dummy: [ParseMessage] = []
        self.init(fileContent: xmlRoot, messages: &dummy)
    }
    
    /// Parse Track Archive XML file contents exported from Cubase.
    public init(
        fileContent xmlRoot: XMLElement,
        messages: inout [ParseMessage]
    ) {
        let parsed = Self.parse(fileContent: xmlRoot)
        self = parsed.trackArchive
        messages = parsed.messages
    }
}

#endif
