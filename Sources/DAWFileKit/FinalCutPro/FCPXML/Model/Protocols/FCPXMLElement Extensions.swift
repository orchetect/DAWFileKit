//
//  FCPXMLElement Extensions.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore

extension FCPXMLElement {
    /// Returns the timecode frame rate for the local timeline.
    public func localTimecodeFrameRate() -> TimecodeFrameRate? {
        // `sequence` has a `format` attribute,
        // and a tcFormat attribute determining drop or non-drop frame timecode
        element._fcpTimecodeFrameRate()
    }
}

#endif
