//
//  FCPXMLElementStart.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

public protocol FCPXMLElementRequiredStart: FCPXMLElement {
    /// Local timeline start. (Required)
    var start: Fraction { get set }
}

extension FCPXMLElementRequiredStart {
    public var start: Fraction {
        get { element.fcpStart ?? .zero }
        set { element.fcpStart = newValue }
    }
    
    /// Returns the start time of the element as timecode.
    public func startAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement
    ) -> Timecode? {
        try? element._fcpTimecode(
            fromRational: start,
            frameRateSource: frameRateSource
        )
    }
}

public protocol FCPXMLElementOptionalStart: FCPXMLElement {
    /// Local timeline start.
    var start: Fraction? { get set }
}

extension FCPXMLElementOptionalStart {
    public var start: Fraction? {
        get { element.fcpStart }
        set { element.fcpStart = newValue }
    }
    
    /// Returns the start time of the element as timecode.
    public func startAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement
    ) -> Timecode? {
        guard let start = start else { return nil }
        return try? element._fcpTimecode(
            fromRational: start,
            frameRateSource: frameRateSource
        )
    }
}

#endif
