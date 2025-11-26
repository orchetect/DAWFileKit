//
//  FCPXMLElementFrameSampling.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore

public protocol FCPXMLElementFrameSampling: FCPXMLElement {
    /// Frame sampling. (Default: floor)
    var frameSampling: FinalCutPro.FCPXML.FrameSampling { get nonmutating set }
}

extension FCPXMLElementFrameSampling {
    private var _frameSamplingDefault: FinalCutPro.FCPXML.FrameSampling { .floor }
    
    public var frameSampling: FinalCutPro.FCPXML.FrameSampling {
        get {
            guard let value = element.stringValue(forAttributeNamed: "frameSampling")
            else { return _frameSamplingDefault }
            
            return FinalCutPro.FCPXML.FrameSampling(rawValue: value) ?? _frameSamplingDefault
        }
        nonmutating set {
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
