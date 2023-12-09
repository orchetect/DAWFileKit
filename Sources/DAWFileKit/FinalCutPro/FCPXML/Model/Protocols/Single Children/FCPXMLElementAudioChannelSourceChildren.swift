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
    var audioChannelSources: LazyMapSequence<
        LazyFilterSequence<LazyMapSequence<
            LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>>.Elements,
            FinalCutPro.FCPXML.AudioChannelSource?
        >>,
        FinalCutPro.FCPXML.AudioChannelSource
    > { get }
}

extension FCPXMLElementAudioChannelSourceChildren {
    public var audioChannelSources: LazyMapSequence<
        LazyFilterSequence<LazyMapSequence<
            LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>>.Elements,
            FinalCutPro.FCPXML.AudioChannelSource?
        >>,
        FinalCutPro.FCPXML.AudioChannelSource
    > {
        element.fcpAudioChannelSources()
    }
}

extension XMLElement {
    /// FCPXML: Returns child `audio-channel-source` elements.
    /// Use on `clip` or `asset-clip` elements.
    public func fcpAudioChannelSources() -> LazyMapSequence<
        LazyFilterSequence<LazyMapSequence<
            LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>>.Elements,
            FinalCutPro.FCPXML.AudioChannelSource?
        >>,
        FinalCutPro.FCPXML.AudioChannelSource
    > {
        childElements
            .filter(whereElementNamed: "audio-channel-source")
            .compactMap(\.fcpAsAudioChannelSource)
    }
}
#endif
