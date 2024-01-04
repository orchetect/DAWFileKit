//
//  FCPXMLElementTimingParams.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore
import TimecodeKit

/// FCPXML 1.11 DTD:
///
/// ```xml
/// <!-- The 'timing-params' entity declare rate conform and time mapping adjustments. -->
/// <!ENTITY % timing-params "(conform-rate?, timeMap?)">
/// ```
public protocol FCPXMLElementTimingParams: FCPXMLElement {
    /// Clip conform rate.
    ///
    /// > FCPXML 1.11 DTD:
    /// >
    /// > "A `conform-rate` defines how the clip's frame rate should be conformed to the sequence frame rate".
    var conformRate: FinalCutPro.FCPXML.ConformRate? { get set }
    
    /// Clip time map.
    ///
    /// > FCPXML 1.11 DTD:
    /// >
    /// > "A `timeMap` is a container for `timept` elements that change the output speed of the clip's local timeline.
    /// > When present, a `timeMap` defines a new adjusted time range for the clip using the first and last `timept`
    /// > elements. All other time values are interpolated from the specified `timept` elements."
    var timeMap: FinalCutPro.FCPXML.TimeMap? { get set }
}

extension FCPXMLElementTimingParams {
    public var conformRate: FinalCutPro.FCPXML.ConformRate? {
        get {
            element.firstChild(whereFCPElement: .conformRate)
        }
        set { 
            element._updateFirstChildElement(ofType: .conformRate, withChild: newValue)
        }
    }
    
    public var timeMap: FinalCutPro.FCPXML.TimeMap? {
        get {
            element.firstChild(whereFCPElement: .timeMap)
        }
        set {
            element._updateFirstChildElement(ofType: .timeMap, withChild: newValue)
        }
    }
}

#endif
