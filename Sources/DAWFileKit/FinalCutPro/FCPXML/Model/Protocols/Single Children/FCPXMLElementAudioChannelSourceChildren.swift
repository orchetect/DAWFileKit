//
//  FCPXMLElementAudioChannelSourceChildren.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

public protocol FCPXMLElementAudioChannelSourceChildren: FCPXMLElement {
    /// Child `audio-channel-source` elements.
    var audioChannelSources: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> { get }
}

extension FCPXMLElementAudioChannelSourceChildren {
    public var audioChannelSources: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpAudioChannelSources()
    }
}

extension XMLElement {
    /// FCPXML: Returns child `audio-channel-source` elements.
    /// Use on `clip` or `asset-clip` elements.
    public func fcpAudioChannelSources() -> LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter(whereElementNamed: "audio-channel-source")
    }
}
#endif
