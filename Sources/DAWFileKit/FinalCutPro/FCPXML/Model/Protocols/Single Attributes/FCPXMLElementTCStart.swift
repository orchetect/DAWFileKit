//
//  FCPXMLElementTCStart.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

public protocol FCPXMLElementOptionalTCStart: FCPXMLElement {
    /// Local timeline origin time.
    var tcStart: Fraction? { get set }
}

extension FCPXMLElementOptionalTCStart {
    public var tcStart: Fraction? {
        get { element.fcpTCStart }
        set { element.fcpTCStart = newValue }
    }
    
    /// Returns the start time of the element as timecode.
    public func tcStartAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement
    ) -> Timecode? {
        guard let tcStart = tcStart else { return nil }
        return try? element._fcpTimecode(
            fromRational: tcStart,
            frameRateSource: frameRateSource
        )
    }
}

#endif
