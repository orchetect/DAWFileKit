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
    var audioRoleSources: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.AudioRoleSource> { get }
}

extension FCPXMLElementAudioRoleSourceChildren {
    public var audioRoleSources: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.AudioRoleSource> {
        element.fcpAudioRoleSources()
    }
}

extension XMLElement {
    /// FCPXML: Returns child `audio-role-source` elements.
    /// Use on `ref-clip`, `sync-source`, or `mc-source` elements.
    public func fcpAudioRoleSources() -> LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.AudioRoleSource> {
        children(whereFCPElement: .audioRoleSource)
    }
}

#endif
