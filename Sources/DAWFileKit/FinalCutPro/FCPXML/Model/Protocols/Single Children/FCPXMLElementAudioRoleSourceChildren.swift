//
//  FCPXMLElementAudioRoleSourceChildren.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

public protocol FCPXMLElementAudioRoleSourceChildren: FCPXMLElement {
    /// Child `audio-role-source` elements.
    var audioRoleSources: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> { get }
}

extension FCPXMLElementAudioRoleSourceChildren {
    public var audioRoleSources: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpAudioRoleSources()
    }
}

extension XMLElement {
    /// FCPXML: Returns child `audio-role-source` elements.
    /// Use on `ref-clip`, `sync-source`, or `mc-source` elements.
    public func fcpAudioRoleSources() -> LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements.filter(whereElementNamed: "audio-role-source")
    }
}
#endif
