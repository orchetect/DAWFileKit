//
//  FCPXML Metadata Metadatum.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

// MARK: - Metadatum

extension FinalCutPro.FCPXML.Metadata {
    /// A single key/value element of metadata.
    public struct Metadatum: FCPXMLElement, Equatable, Hashable {
        public let element: XMLElement
        
        public let elementType: FinalCutPro.FCPXML.ElementType = .metadatum
        
        public static let supportedElementTypes: Set<FinalCutPro.FCPXML.ElementType> = [.metadatum]
        
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

extension FinalCutPro.FCPXML.Metadata.Metadatum {
    // TODO: add init after adding properties
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Metadata.Metadatum {
    public enum Attributes: String {
        case key // required
        case value // optional
        case editable // Bool, implied default: false
        case type // optional `md-type`, not often present
        case displayName // optional
        case description // optional
        case source // optional
    }
    
    // some md keys use the `value` attribute, and some use an interior `array`
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Metadata.Metadatum {
    /// Metadata key returned as a ``FinalCutPro/FCPXML/Metadata/Key`` enum case.
    /// This is stored as a reverse-DNS formatted string. ie: `"com.apple.proapps.studio.reel"`
    ///
    /// Even though `key` is a required attribute, this property returns an Optional since not all
    /// metadata keys may be known.
    ///
    /// Note that setting this property to `nil` has no effect since `key` is a required attribute.
    public var key: FinalCutPro.FCPXML.Metadata.Key? {
        get { FinalCutPro.FCPXML.Metadata.Key(rawValue: keyString) }
        set {
            guard let newValue else { return }
            keyString = newValue.rawValue
        }
    }
    
    /// Metadata raw key name string.
    /// This is stored as a reverse-DNS formatted string. ie: `"com.apple.proapps.studio.reel"`
    public var keyString: String {
        get { element.stringValue(forAttributeNamed: Attributes.key.rawValue) ?? "" }
        set { element.addAttribute(withName: Attributes.key.rawValue, value: newValue) }
    }
    
    /// Metadata raw `value` attribute string.
    public var value: String? {
        get { element.fcpValue }
        set { element.fcpValue = newValue }
    }
    
    /// Boolean value determining whether the metadatum's value is editable.
    /// (Default: false)
    public var editable: Bool {
        get {
            element.getBool(forAttribute: Attributes.editable.rawValue) ?? false
        }
        set {
            element._fcpSet(
                bool: newValue,
                forAttribute: Attributes.editable.rawValue,
                defaultValue: false,
                removeIfDefault: true
            )
        }
    }
    
    /// The value type of the metadatum.
    public var type: FinalCutPro.FCPXML.Metadata.MetadatumType? {
        get {
            guard let value = element.stringValue(forAttributeNamed: Attributes.type.rawValue)
            else { return nil }
            
            return FinalCutPro.FCPXML.Metadata.MetadatumType(rawValue: value)
        }
        set { 
            element.addAttribute(withName: Attributes.type.rawValue, value: newValue?.rawValue)
        }
    }
    
    /// Display name for user interface.
    public var displayName: String? {
        get { element.stringValue(forAttributeNamed: Attributes.displayName.rawValue) }
        set { element.addAttribute(withName: Attributes.displayName.rawValue, value: newValue) }
    }
    
    /// Description for user interface.
    public var displayDescription: String? {
        get { element.stringValue(forAttributeNamed: Attributes.description.rawValue) }
        set { element.addAttribute(withName: Attributes.description.rawValue, value: newValue) }
    }
}

// MARK: - Children

extension FinalCutPro.FCPXML.Metadata.Metadatum {
    /// Returns the internal string array if applicable.
    public var valueArray: [String]? {
        get { element._getFirstChildStringArray() }
        set { element._setFirstChildStringArray(newValue) }
    }
}

// MARK: - Typing

// Metadatum
extension XMLElement {
    /// FCPXML:
    /// Returns the element wrapped in a ``FinalCutPro/FCPXML/Metadata/Metadatum`` model object.
    /// Call this on an `md` element only.
    public var fcpAsMetadatum: FinalCutPro.FCPXML.Metadata.Metadatum? {
        .init(element: self)
    }
}

// MARK: - Metadatum Type

extension FinalCutPro.FCPXML.Metadata {
    /// `md-type` FCPXML DTD element.
    /// Describes the value format for an individual piece of metadata (metadatum).
    public enum MetadatumType: String, Equatable, Hashable, CaseIterable, Sendable {
        case string
        case boolean
        case integer
        case float
        case date
        case timecode
    }
}

#endif
