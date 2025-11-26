//
//  FCPXMLElementDuration.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore

public protocol FCPXMLElementRequiredDuration: FCPXMLElement {
    /// Local timeline duration. (Required)
    var duration: Fraction { get nonmutating set }
}

extension FCPXMLElementRequiredDuration {
    public var duration: Fraction {
        get { element.fcpDuration ?? .zero }
        nonmutating set { element.fcpDuration = newValue }
    }
    
    /// Returns the local timeline duration of the element as timecode.
    public func durationAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement
    ) -> Timecode? {
        element._fcpDurationAsTimecode(
            frameRateSource: frameRateSource,
            default: .zero
        )
    }
}

public protocol FCPXMLElementOptionalDuration: FCPXMLElement {
    /// Local timeline duration.
    var duration: Fraction? { get nonmutating set }
}

extension FCPXMLElementOptionalDuration {
    public var duration: Fraction? {
        get { element.fcpDuration }
        nonmutating set { element.fcpDuration = newValue }
    }
    
    /// Returns the start time of the element as timecode.
    public func durationAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement
    ) -> Timecode? {
        guard duration != nil else { return nil }
        return element._fcpDurationAsTimecode(
            frameRateSource: frameRateSource,
            default: nil
        )
    }
}

// MARK: - XML Utils

extension XMLElement {
    func _fcpDurationAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement,
        default defaultDuration: Fraction? = .zero
    ) -> Timecode? {
        guard let dur = fcpDuration ?? defaultDuration else { return nil }
        
        return try? _fcpTimecode(
            fromRational: dur,
            frameRateSource: frameRateSource
        )
    }
}

#endif
