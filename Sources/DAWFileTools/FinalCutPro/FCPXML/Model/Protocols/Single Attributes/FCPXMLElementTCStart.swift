//
//  FCPXMLElementTCStart.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore

public protocol FCPXMLElementOptionalTCStart: FCPXMLElement {
    /// Local timeline origin time.
    var tcStart: Fraction? { get nonmutating set }
}

extension FCPXMLElementOptionalTCStart {
    public var tcStart: Fraction? {
        get { element.fcpTCStart }
        nonmutating set { element.fcpTCStart = newValue }
    }
    
    /// Returns the start time of the element as timecode.
    public func tcStartAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement
    ) -> Timecode? {
        element._fcpTCStartAsTimecode(
            frameRateSource: frameRateSource
        )
    }
}

// MARK: - XML Utils

extension XMLElement {
    func _fcpTCStartAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement
    ) -> Timecode? {
        guard let tcStart = fcpTCStart else { return nil }
        return try? _fcpTimecode(
            fromRational: tcStart,
            frameRateSource: frameRateSource
        )
    }
}

#endif
