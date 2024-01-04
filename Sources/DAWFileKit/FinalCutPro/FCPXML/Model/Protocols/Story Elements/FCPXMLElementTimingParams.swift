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
    var conformRate: FinalCutPro.FCPXML.ConformRate? { get set }
    
    // TODO: add timeMap
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
    
    // TODO: add timeMap
}

#endif
