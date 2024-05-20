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
        element._fcpStartAsTimecode(
            frameRateSource: frameRateSource,
            default: .zero
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
        guard  start != nil else { return nil }
        return element._fcpStartAsTimecode(
            frameRateSource: frameRateSource,
            default: .zero
        )
    }
}

// MARK: - XML Utils

extension XMLElement {
    func _fcpStartAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement,
        default defaultStart: Fraction? = .zero
    ) -> Timecode? {
        guard let dur = fcpStart ?? defaultStart else { return nil }
        
        return try? _fcpTimecode(
            fromRational: dur,
            frameRateSource: frameRateSource
        )
    }
}

#endif
