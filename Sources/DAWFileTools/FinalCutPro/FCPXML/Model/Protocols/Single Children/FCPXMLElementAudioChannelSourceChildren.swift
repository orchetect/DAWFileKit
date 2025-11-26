//
//  FCPXMLElementAudioChannelSourceChildren.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions
import TimecodeKitCore

public protocol FCPXMLElementAudioChannelSourceChildren: FCPXMLElement {
    /// Child `audio-channel-source` elements.
    var audioChannelSources: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.AudioChannelSource> { get nonmutating set }
}

extension FCPXMLElementAudioChannelSourceChildren {
    public var audioChannelSources: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.AudioChannelSource> {
        get { element.fcpAudioChannelSources }
        nonmutating set { element.fcpAudioChannelSources = newValue }
    }
}

extension XMLElement {
    /// FCPXML: Returns child `audio-channel-source` elements.
    /// Use on `clip` or `asset-clip` elements.
    public var fcpAudioChannelSources: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.AudioChannelSource> {
        get { children(whereFCPElement: .audioChannelSource) }
        set { _updateChildElements(ofType: .audioChannelSource, with: newValue) }
    }
}
#endif
