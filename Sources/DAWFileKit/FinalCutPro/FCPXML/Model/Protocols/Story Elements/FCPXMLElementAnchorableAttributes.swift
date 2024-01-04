//
//  FCPXMLElementAnchorableAttributes.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

/// FCPXML 1.11 DTD:
///
/// ```xml
/// <!-- The 'ao_attrs' entity declares the attributes common to 'anchorable' objects. -->
/// <!-- The 'lane' attribute specifies where the object is contained/anchored relative to its parent: -->
/// <!--    0 = contained inside its parent (default) -->
/// <!--    >0 = anchored above its parent -->
/// <!--    <0 = anchored below its parent -->
/// <!-- The 'offset' attribute defines the location of the object in the parent timeline (default is '0s'). -->
/// <!ENTITY % ao_attrs "
///     lane CDATA #IMPLIED
///     offset %time; #IMPLIED
/// ">
/// ```
public protocol FCPXMLElementAnchorableAttributes: FCPXMLElement {
    /// Lane.
    /// Specifies where the object is contained/anchored relative to its parent.
    ///
    /// - `0` = contained inside its parent (default)
    /// - `>0` = anchored above its parent
    /// - `<0` = anchored below its parent
    var lane: Int? { get set }
    
    /// Offset within parent timeline. (Default: 0)
    var offset: Fraction? { get set }
}

extension FCPXMLElementAnchorableAttributes {
    public var lane: Int? {
        get { element.fcpLane }
        set { element.fcpLane = newValue }
    }
    
    public var offset: Fraction? {
        get { element.fcpOffset }
        set { element.fcpOffset = newValue }
    }
}

extension FCPXMLElementAnchorableAttributes {
    /// Returns the offset of the element as timecode.
    public func offsetAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .localToElement
    ) -> Timecode? {
        guard let offset = offset else { return nil }
        return try? element._fcpTimecode(
            fromRational: offset,
            frameRateSource: frameRateSource,
            autoScale: true
        )
    }
}

#endif
