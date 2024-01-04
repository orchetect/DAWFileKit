//
//  FCPXML TimeMap TimePoint.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore
import TimecodeKit

extension FinalCutPro.FCPXML.TimeMap {
    /// Time point on a time map.
    ///
    /// > FCPXML 1.11 DTD:
    /// >
    /// > ```xml
    /// > <!-- A 'timept' defines the re-mapped time values for a 'timeMap'. -->
    /// > <!ELEMENT timept EMPTY>
    /// > <!ATTLIST timept time %time; #REQUIRED>    <!-- new adjusted clip time -->
    /// > <!ATTLIST timept value CDATA #REQUIRED>    <!-- original clip time -->
    /// > <!ATTLIST timept interp (smooth2 | linear | smooth) "smooth2"> <!-- interpolation type for point.  smooth has been deprecated -->
    /// > <!ATTLIST timept inTime %time; #IMPLIED>   <!-- transition in-time for point (used only with smooth interpolations) -->
    /// > <!ATTLIST timept outTime %time; #IMPLIED>  <!-- transition out-time for point (used only with smooth interpolations) -->
    /// > ```
    public struct TimePoint: FCPXMLElement, Equatable, Hashable {
        public let element: XMLElement
        
        public let elementType: FinalCutPro.FCPXML.ElementType = .timePoint
        
        public static let supportedElementTypes: Set<FinalCutPro.FCPXML.ElementType> = [.timePoint]
        
        public init() {
            element = XMLElement(name: elementType.rawValue)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementTypeSupported(element: element) else { return nil }
        }
    }
}

// MARK: - Parameterized init

extension FinalCutPro.FCPXML.TimeMap.TimePoint {
    public init(
        time: Fraction,
        originalTime: Fraction, // TODO: Fraction? DTD type is CDATA, not `%time`
        interpolation: Interpolation = .smooth2,
        transitionInTime: Fraction? = nil,
        transitionOutTime: Fraction? = nil
    ) {
        self.init()
        
        self.time = time
        self.originalTime = originalTime
        self.interpolation = interpolation
        self.transitionInTime = transitionInTime
        self.transitionOutTime = transitionOutTime
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.TimeMap.TimePoint {
    public enum Attributes: String {
        case time = "time"
        case originalTime = "value"
        case interpolation = "interp"
        case transitionInTime = "inTime"
        case transitionOutTime = "outTime"
    }
    
    // no children
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.TimeMap.TimePoint {
    /// New adjusted clip time. (Required)
    public var time: Fraction {
        get {
            element._fcpGetFraction(forAttribute: Attributes.time.rawValue) ?? .zero
        }
        set {
            element._fcpSet(fraction: newValue, forAttribute: Attributes.time.rawValue)
        }
    }
    
    /// Original clip time. (Required)
    public var originalTime: Fraction {
        get { 
            element._fcpGetFraction(forAttribute: Attributes.originalTime.rawValue) ?? .zero
        }
        set { 
            element._fcpSet(fraction: newValue, forAttribute: Attributes.originalTime.rawValue)
        }
    }
    
    /// Interpolation type for point. (Default: `smooth2`)
    /// - Note: `smooth` has been deprecated by Final Cut Pro.
    public var interpolation: Interpolation {
        get { 
            guard let value = element.stringValue(forAttributeNamed: Attributes.interpolation.rawValue),
                  let interp = Interpolation(rawValue: value)
            else { return .smooth2 }
            
            return interp
        }
        set { 
            element.addAttribute(withName: Attributes.interpolation.rawValue, value: newValue.rawValue)
        }
    }
    
    /// Transition in time. (Used only with smooth interpolations.)
    public var transitionInTime: Fraction? {
        get { 
            element._fcpGetFraction(forAttribute: Attributes.transitionInTime.rawValue)
        }
        set { 
            element._fcpSet(fraction: newValue, forAttribute: Attributes.transitionInTime.rawValue)
        }
    }
    
    /// Transition out time. (Used only with smooth interpolations.)
    public var transitionOutTime: Fraction? {
        get {
            element._fcpGetFraction(forAttribute: Attributes.transitionOutTime.rawValue)
        }
        set { 
            element._fcpSet(fraction: newValue, forAttribute: Attributes.transitionOutTime.rawValue)
        }
    }
}

// MARK: - Typing

// TimePoint
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/TimeMap/TimePoint`` model object.
    /// Call this on a `timetp` element only.
    public var fcpAsTimePoint: FinalCutPro.FCPXML.TimeMap.TimePoint? {
        .init(element: self)
    }
}

// MARK: - Supporting Types

extension FinalCutPro.FCPXML.TimeMap.TimePoint {
    public enum Interpolation: String, Equatable, Hashable, CaseIterable, Sendable {
        /// Linear time interpolation.
        case linear
        
        /// Smooth time interpolation. (Deprecated)
        @available(
            *,
            deprecated,
            renamed: "smooth2",
            message: "Smooth interpolation has been deprecated by Final Cut Pro. Use `smooth2` instead."
        )
        case smooth
        
        /// Smooth 2 time interpolation.
        case smooth2
        
        // (Swift can't synthesize CaseIterable `allCases` if any case(s) are marked `@available`)
        public static let allCases: [Self] = [.linear, .smooth2]
    }
}

#endif
