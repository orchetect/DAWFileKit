//
//  FCPXMLElementClipAttributes.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftTimecodeCore

/// FCPXML 1.11 DTD:
///
/// ```xml
/// <!-- The 'clip_attrs' entity declares the attributes common to all story elements. -->
/// <!-- The 'start' attribute defines a local timeline to schedule contained and anchored items. -->
/// <!-- The default start value is '0s'. -->
/// <!ENTITY % clip_attrs "
///     %ao_attrs;
///     name CDATA #IMPLIED
///     start %time; #IMPLIED
///     duration %time; #REQUIRED
///     enabled (0 | 1) '1'
/// ">
/// ```
public protocol FCPXMLElementClipAttributes: FCPXMLElement,
    FCPXMLElementAnchorableAttributes,
    FCPXMLElementOptionalStart, FCPXMLElementRequiredDuration
{
    /// Clip name.
    var name: String? { get nonmutating set }
    
    // FCPXMLElementStart
    /// Clip local timeline start time.
    var start: Fraction? { get nonmutating set }
    
    // FCPXMLElementRequiredDuration
    /// Clip duration.
    var duration: Fraction { get nonmutating set }
    
    /// Clip enabled state. (Default: `true`)
    var enabled: Bool { get nonmutating set }
}

extension FCPXMLElementClipAttributes {
    public var name: String? {
        get { element.fcpName }
        nonmutating set { element.fcpName = newValue }
    }
    
    // implemented by FCPXMLElementOptionalStart
    // public var start: Fraction?
    
    // implemented by FCPXMLElementRequiredDuration
    // public var duration: Fraction
    
    public var enabled: Bool {
        get { element.fcpGetEnabled(default: true) }
        nonmutating set { element.fcpSet(enabled: newValue, default: true) }
    }
}

#endif
