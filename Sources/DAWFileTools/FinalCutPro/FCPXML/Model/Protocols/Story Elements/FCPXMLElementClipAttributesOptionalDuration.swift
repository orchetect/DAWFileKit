//
//  FCPXMLElementClipAttributesOptionalDuration.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftTimecodeCore

/// FCPXML 1.11 DTD:
///
/// ```xml
/// <!-- Where applicable the duration attribute is implied, and comes from the underlying media. -->
/// <!ENTITY % clip_attrs_with_optional_duration "
///     %ao_attrs;
///     name CDATA #IMPLIED
///     start %time; #IMPLIED
///     duration %time; #IMPLIED
///     enabled (0 | 1) '1'
/// ">
/// ```
public protocol FCPXMLElementClipAttributesOptionalDuration: FCPXMLElement,
    FCPXMLElementAnchorableAttributes,
    FCPXMLElementOptionalStart, FCPXMLElementOptionalDuration
{
    /// Clip name.
    var name: String? { get nonmutating set }
    
    // FCPXMLElementStart
    /// Clip local timeline start time.
    var start: Fraction? { get nonmutating set }
    
    // FCPXMLElementOptionalDuration
    /// Clip duration.
    var duration: Fraction? { get nonmutating set }
    
    /// Clip enabled state. (Default: `true`)
    var enabled: Bool { get nonmutating set }
}

extension FCPXMLElementClipAttributesOptionalDuration {
    public var name: String? {
        get { element.fcpName }
        nonmutating set { element.fcpName = newValue }
    }
    
    // implemented by FCPXMLElementOptionalStart
    // public var start: Fraction?
    
    // implemented by FCPXMLElementOptionalDuration
    // public var duration: Fraction?
    
    public var enabled: Bool {
        get { element.fcpGetEnabled(default: true) }
        nonmutating set { element.fcpSet(enabled: newValue, default: true) }
    }
}

#endif
