//
//  FCPXMLElementMediaAttributes.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

/// FCPXML 1.11 DTD:
///
/// ```xml
/// <!-- The 'media_attrs' entity declares the attributes common to media instances. -->
/// <!-- 'format' specifies a <format> resource ID. -->
/// <!-- 'tcStart' specifies the timecode origin of the media. -->
/// <!-- 'tcFormat' specifies the timecode display format (DF=drop frame; NDF=non-drop frame). -->
/// <!ENTITY % media_attrs "
///     format IDREF #REQUIRED
///     duration %time; #IMPLIED
///     tcStart %time; #IMPLIED
///     tcFormat (DF | NDF) #IMPLIED
/// ">
/// ```
public protocol FCPXMLElementMediaAttributes: FCPXMLElement,
    FCPXMLElementOptionalDuration,
    FCPXMLElementOptionalTCStart,
    FCPXMLElementOptionalTCFormat
{
    /// Format resource ID. (Required)
    var format: String { get set }
    
    // FCPXMLElementOptionalDuration
    /// Local timeline duration.
    var duration: Fraction? { get set }
    
    // FCPXMLElementTCStart
    /// Local timeline start time.
    var tcStart: Fraction? { get set }
    
    // FCPXMLElementTCFormat
    /// Local timeline timecode format.
    var tcFormat: FinalCutPro.FCPXML.TimecodeFormat? { get set }
}

extension FCPXMLElementMediaAttributes {
    public var format: String {
        get { element.fcpFormat ?? "" }
        set { element.fcpFormat = newValue }
    }
    
    // implemented by FCPXMLElementOptionalDuration
    // public var duration: Fraction?
    
    // implemented by FCPXMLElementOptionalTCStart
    // public var tcStart: Fraction?
    
    // implemented by FCPXMLElementOptionalTCFormat
    // public var tcFormat: FinalCutPro.FCPXML.TimecodeFormat?
}

#endif
