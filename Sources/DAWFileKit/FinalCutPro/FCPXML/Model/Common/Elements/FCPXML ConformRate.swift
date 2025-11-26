//
//  FCPXML ConformRate.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Clip conform rate.
    ///
    /// > FCPXML 1.11 DTD:
    /// >
    /// > "A `conform-rate` defines how the clip's frame rate should be conformed to the sequence frame rate".
    public struct ConformRate: FCPXMLElement, Equatable, Hashable {
        public let element: XMLElement
        
        public let elementType: ElementType = .conformRate
        
        public static let supportedElementTypes: Set<ElementType> = [.conformRate]
        
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

extension FinalCutPro.FCPXML.ConformRate {
    public init(
        scaleEnabled: Bool = true,
        srcFrameRate: SourceFrameRate?,
        frameSampling: FinalCutPro.FCPXML.FrameSampling = .floor
    ) {
        self.init()
        
        self.scaleEnabled = scaleEnabled
        self.srcFrameRate = srcFrameRate
        self.frameSampling = frameSampling
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.ConformRate {
    public enum Attributes: String {
        case scaleEnabled // default: true
        case srcFrameRate // optional
        case frameSampling // default: floor
    }
    
    // no children
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.ConformRate {
    /// Scale enabled. (Default: true)
    public var scaleEnabled: Bool {
        get {
            element.getBool(forAttribute: Attributes.scaleEnabled.rawValue) ?? true
        }
        nonmutating set {
            element.set(
                bool: newValue,
                forAttribute: Attributes.scaleEnabled.rawValue,
                defaultValue: true,
                removeIfDefault: true,
                useInt: true
            )
        }
    }
    
    /// Source frame rate.
    public var srcFrameRate: SourceFrameRate? {
        get {
            guard let value = element.stringValue(forAttributeNamed: Attributes.srcFrameRate.rawValue)
            else { return nil }
            
            return SourceFrameRate(rawValue: value)
        }
        nonmutating set { 
            element.addAttribute(withName: Attributes.srcFrameRate.rawValue, value: newValue?.rawValue)
        }
    }
}

extension FinalCutPro.FCPXML.ConformRate: FCPXMLElementFrameSampling { }

// MARK: - Typing

// ConformRate
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/ConformRate`` model object.
    /// Call this on a `conform-rate` element only.
    public var fcpAsConformRate: FinalCutPro.FCPXML.ConformRate? {
        .init(element: self)
    }
}

// MARK: - Supporting Types

extension FinalCutPro.FCPXML.ConformRate {
    /// Supported frame rates used in FCPXML `conform-rate` elements.
    public enum SourceFrameRate: String, CaseIterable {
        case fps23_98 = "23.98"
        case fps24 = "24"
        case fps25 = "25"
        case fps29_97 = "29.97"
        case fps30 = "30"
        case fps47_95 = "47.95"
        case fps48 = "48"
        case fps50 = "50"
        case fps60 = "60"
        case fps59_94 = "59.94"
    }
}

extension FinalCutPro.FCPXML.ConformRate.SourceFrameRate {
    public init?(timecodeFrameRate: TimecodeFrameRate) {
        guard let match = Self.allCases.first(where: {
            $0.timecodeFrameRate == timecodeFrameRate
        }) else { return nil }
        
        self = match
    }
    
    public var timecodeFrameRate: TimecodeFrameRate {
        switch self {
        case .fps23_98: return .fps23_976
        case .fps24: return .fps24
        case .fps25: return .fps25
        case .fps29_97: return .fps29_97
        case .fps30: return .fps30
        case .fps47_95: return .fps47_952
        case .fps48: return .fps48
        case .fps50: return .fps50
        case .fps60: return .fps60
        case .fps59_94: return .fps59_94
        }
    }
}

#endif
