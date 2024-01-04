//
//  FCPXMLElementFrameSampling.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

public protocol FCPXMLElementFrameSampling: FCPXMLElement {
    /// Frame sampling. (Default: floor)
    var frameSampling: FinalCutPro.FCPXML.FrameSampling { get set }
}

extension FCPXMLElementFrameSampling {
    private var _frameSamplingDefault: FinalCutPro.FCPXML.FrameSampling { .floor }
    
    public var frameSampling: FinalCutPro.FCPXML.FrameSampling {
        get {
            guard let value = element.stringValue(forAttributeNamed: "frameSampling")
            else { return _frameSamplingDefault }
            
            return FinalCutPro.FCPXML.FrameSampling(rawValue: value) ?? _frameSamplingDefault
        }
        set {
            if newValue == _frameSamplingDefault {
                // can remove attribute if value is default
                element.removeAttribute(forName: "frameSampling")
            } else {
                element.addAttribute(withName: "frameSampling", value: newValue.rawValue)
            }
        }
    }
}

#endif
