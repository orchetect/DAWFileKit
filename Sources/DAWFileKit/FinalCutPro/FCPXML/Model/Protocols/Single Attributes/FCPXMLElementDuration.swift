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
    
    /// Convenience:
    /// Returns the local timeline duration of the element as timecode.
    public var durationAsTimecode: Timecode? {
        try? element._fcpTimecode(fromRational: duration)
    }
}

public protocol FCPXMLElementOptionalDuration: FCPXMLElement {
    /// Local timeline duration.
    var duration: Fraction? { get set }
}

extension FCPXMLElementOptionalDuration {
    public var duration: Fraction? {
        get { element.fcpStart }
        set { element.fcpStart = newValue }
    }
    
    /// Convenience:
    /// Returns the start time of the element as timecode.
    public var durationAsTimecode: Timecode? {
        guard let duration = duration else { return nil }
        return try? element._fcpTimecode(fromRational: duration)
    }
}

#endif
