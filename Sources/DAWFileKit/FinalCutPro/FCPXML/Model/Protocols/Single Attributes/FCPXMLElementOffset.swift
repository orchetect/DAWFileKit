//
//  FCPXMLElementOffset.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore

public protocol FCPXMLElementRequiredOffset: FCPXMLElement {
    /// Local timeline offset. (Required)
    var offset: Fraction { get nonmutating set }
}

extension FCPXMLElementRequiredOffset {
    public var offset: Fraction {
        get { element.fcpOffset ?? .zero }
        nonmutating set { element.fcpOffset = newValue }
    }
    
    /// Returns the local timeline offset of the element as timecode.
    public func offsetAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement
    ) -> Timecode? {
        element._fcpOffsetAsTimecode(
            frameRateSource: frameRateSource,
            default: .zero
        )
    }
}

public protocol FCPXMLElementOptionalOffset: FCPXMLElement {
    /// Local timeline offset.
    var offset: Fraction? { get nonmutating set }
}

extension FCPXMLElementOptionalOffset {
    public var offset: Fraction? {
        get { element.fcpOffset }
        nonmutating set { element.fcpOffset = newValue }
    }
    
    /// Returns the offset of the element as timecode.
    public func offsetAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement
    ) -> Timecode? {
        guard offset != nil else { return nil }
        return element._fcpOffsetAsTimecode(
            frameRateSource: frameRateSource,
            default: nil
        )
    }
}

// MARK: - XML Utils

extension XMLElement {
    func _fcpOffsetAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement,
        default defaultOffset: Fraction? = .zero
    ) -> Timecode? {
        guard let dur = fcpOffset ?? defaultOffset else { return nil }
        
        return try? _fcpTimecode(
            fromRational: dur,
            frameRateSource: frameRateSource
        )
    }
}

#endif
