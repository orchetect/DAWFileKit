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
    var audioRoleSources: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.AudioRoleSource> { get nonmutating set }
}

extension FCPXMLElementAudioRoleSourceChildren {
    public var audioRoleSources: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.AudioRoleSource> {
        get { element.fcpAudioRoleSources }
        nonmutating set { element.fcpAudioRoleSources = newValue }
    }
}

extension XMLElement {
    /// FCPXML: Returns child `audio-role-source` elements.
    /// Use on `ref-clip`, `sync-source`, or `mc-source` elements.
    public var fcpAudioRoleSources: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.AudioRoleSource> {
        get { children(whereFCPElement: .audioRoleSource) }
        set { _updateChildElements(ofType: .audioRoleSource, with: newValue) }
    }
}

#endif
