//
//  FCPXMLElementAudioChannelSourceChildren.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore
import TimecodeKit

public protocol FCPXMLElementAudioChannelSourceChildren: FCPXMLElement {
    /// Child `audio-channel-source` elements.
    var audioChannelSources: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.AudioChannelSource> { get }
}

extension FCPXMLElementAudioChannelSourceChildren {
    // TODO: add set support, not just read-only
    public var audioChannelSources: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.AudioChannelSource> {
        element.fcpAudioChannelSources()
    }
}

extension XMLElement {
    /// FCPXML: Returns child `audio-channel-source` elements.
    /// Use on `clip` or `asset-clip` elements.
    public func fcpAudioChannelSources() -> LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.AudioChannelSource> {
        children(whereFCPElement: .audioChannelSource)
    }
}
#endif
