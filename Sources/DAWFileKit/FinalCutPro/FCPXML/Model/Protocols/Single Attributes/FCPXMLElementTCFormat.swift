//
//  FCPXMLElementTCFormat.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore

public protocol FCPXMLElementOptionalTCFormat: FCPXMLElement {
    /// Local timeline timecode format.
    var tcFormat: FinalCutPro.FCPXML.TimecodeFormat? { get nonmutating set }
}

extension FCPXMLElementOptionalTCFormat {
    public var tcFormat: FinalCutPro.FCPXML.TimecodeFormat? {
        get { element.fcpTCFormat }
        nonmutating set { element.fcpTCFormat = newValue }
    }
}

#endif
