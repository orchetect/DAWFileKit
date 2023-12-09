//
//  FCPXMLElementAudioRoleSourceChildren.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore
import TimecodeKit

public protocol FCPXMLElementAudioRoleSourceChildren: FCPXMLElement {
    /// Child `audio-role-source` elements.
    var audioRoleSources: LazyMapSequence<
        LazyFilterSequence<LazyMapSequence<
            LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>>.Elements,
            FinalCutPro.FCPXML.AudioRoleSource?
        >>,
        FinalCutPro.FCPXML.AudioRoleSource
    > { get }
}

extension FCPXMLElementAudioRoleSourceChildren {
    public var audioRoleSources: LazyMapSequence<
        LazyFilterSequence<LazyMapSequence<
            LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>>.Elements,
            FinalCutPro.FCPXML.AudioRoleSource?
        >>,
        FinalCutPro.FCPXML.AudioRoleSource
    > {
        element.fcpAudioRoleSources()
    }
}

extension XMLElement {
    /// FCPXML: Returns child `audio-role-source` elements.
    /// Use on `ref-clip`, `sync-source`, or `mc-source` elements.
    public func fcpAudioRoleSources() -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<
        LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>>.Elements,
        FinalCutPro.FCPXML.AudioRoleSource?
    >>, FinalCutPro.FCPXML.AudioRoleSource
    > {
        childElements
            .filter(whereElementNamed: "audio-role-source")
            .compactMap(\.fcpAsAudioRoleSource)
    }
}
#endif
