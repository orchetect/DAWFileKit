//
//  FCPXMLElementDuration.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

public protocol FCPXMLElementRequiredDuration: FCPXMLElement {
    /// Local timeline duration. (Required)
    var duration: Fraction { get set }
}

extension FCPXMLElementRequiredDuration {
    public var duration: Fraction {
        get { element.fcpDuration ?? .zero }
        set { element.fcpDuration = newValue }
    }
    
    /// Returns the local timeline duration of the element as timecode.
    public func durationAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement
    ) -> Timecode? {
        try? element._fcpTimecode(
            fromRational: duration,
            frameRateSource: frameRateSource
        )
    }
}

public protocol FCPXMLElementOptionalDuration: FCPXMLElement {
    /// Local timeline duration.
    var duration: Fraction? { get set }
}

extension FCPXMLElementOptionalDuration {
    public var duration: Fraction? {
        get { element.fcpDuration }
        set { element.fcpDuration = newValue }
    }
    
    /// Returns the start time of the element as timecode.
    public func durationAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement
    ) -> Timecode? {
        guard let duration = duration else { return nil }
        return try? element._fcpTimecode(
            fromRational: duration,
            frameRateSource: frameRateSource
        )
    }
}

#endif
