//
//  TrackArchive Init.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

// MARK: - Init

extension Cubase.TrackArchive {
    /// Parse Track Archive XML file contents exported from Cubase.
    public init(data: Data) throws {
        var dummy: [ParseMessage] = []
        try self.init(data: data, messages: &dummy)
    }
    
    /// Parse Track Archive XML file contents exported from Cubase.
    public init(
        data: Data,
        messages: inout [ParseMessage]
    ) throws {
        let xmlDocument = try XMLDocument(data: data)
        let parsed = try Self.parse(xml: xmlDocument)
        self = parsed.trackArchive
        messages = parsed.messages
    }
}

extension Cubase.TrackArchive {
    /// Parse Track Archive XML file contents exported from Cubase.
    public init(xml: XMLDocument) throws {
        var dummy: [ParseMessage] = []
        try self.init(xml: xml, messages: &dummy)
    }
    
    /// Parse Track Archive XML file contents exported from Cubase.
    public init(
        xml: XMLDocument,
        messages: inout [ParseMessage]
    ) throws {
        let parsed = try Self.parse(xml: xml)
        self = parsed.trackArchive
        messages = parsed.messages
    }
}

extension Cubase.TrackArchive {
    /// Parse Track Archive XML file contents exported from Cubase.
    public init(xml root: XMLElement) {
        var dummy: [ParseMessage] = []
        self.init(xml: root, messages: &dummy)
    }
    
    /// Parse Track Archive XML file contents exported from Cubase.
    public init(
        xml root: XMLElement,
        messages: inout [ParseMessage]
    ) {
        let parsed = Self.parse(xml: root)
        self = parsed.trackArchive
        messages = parsed.messages
    }
}

#endif
