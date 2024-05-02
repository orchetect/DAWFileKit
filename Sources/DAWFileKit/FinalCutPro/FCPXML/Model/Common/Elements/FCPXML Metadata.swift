//
//  FCPXML Metadata.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Metadata container.
    public struct Metadata: FCPXMLElement, Equatable, Hashable {
        public let element: XMLElement
        
        public let elementType: ElementType = .metadata
        
        public static let supportedElementTypes: Set<ElementType> = [.metadata]
        
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

extension FinalCutPro.FCPXML.Metadata {
    // TODO: add init after adding properties
    
    // TODO: this is not practical since not all keys use a string value. some use a string array.
    // /// Initialize by providing metadata key/value pairs.
    // public init(contents: [Key: String]) {
    //     self.init()
    //
    //     for item in contents {
    //         setStringValue(forKey: item.key, value: item.value)
    //     }
    // }
    
    /// Initialize by providing metadata contents.
    public init(contents: [Metadatum]) {
        self.init()
        self.metadatumContents = contents
    }
}

// MARK: Custom inits

extension FinalCutPro.FCPXML.Metadata {
    /// Wraps children in a `metadata` container element.
    public init(from children: [XMLElement]) {
        let container = XMLElement(name: elementType.rawValue)
        container.addChildren(children)
        element = container
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Metadata {
    // no attributes
    
    // contains key/value children
}

// MARK: - Children

extension FinalCutPro.FCPXML.Metadata {
    // MARK: - Individual metadata key/value properties
    
    /// Get or set **Reel** metadata value.
    public var reel: String? {
        get { getStringValue(forKey: .reel) }
        set { setStringValue(forKey: .reel, value: newValue) }
    }
    
    /// Get or set **Scene** metadata value.
    public var scene: String? {
        get { getStringValue(forKey: .scene) }
        set { setStringValue(forKey: .scene, value: newValue) }
    }
    
    /// Get or set **Shot** metadata value.
    public var shot: String? {
        get { getStringValue(forKey: .shot) }
        set { setStringValue(forKey: .shot, value: newValue) }
    }
    
    /// Get or set **Camera Angle** metadata value.
    public var cameraAngle: String? {
        get { getStringValue(forKey: .cameraAngle) }
        set { setStringValue(forKey: .cameraAngle, value: newValue) }
    }
    
    /// Get or set **Camera Name** metadata value.
    public var cameraName: String? {
        get { getStringValue(forKey: .cameraName) }
        set { setStringValue(forKey: .cameraName, value: newValue) }
    }
    
    // TODO: Should be `Bool`?
    /// Get or set **Raw To Log Conversion** metadata value.
    public var rawToLogConversion: String? {
        get { getStringValue(forKey: .rawToLogConversion) }
        set { setStringValue(forKey: .rawToLogConversion, value: newValue) }
    }
    
    /// Get or set **Color Profile** metadata value.
    public var colorProfile: String? {
        get { getStringValue(forKey: .colorProfile) }
        set { setStringValue(forKey: .colorProfile, value: newValue) }
    }
    
    /// Get or set **Camera ISO** metadata value.
    public var cameraISO: String? {
        get { getStringValue(forKey: .cameraISO) }
        set { setStringValue(forKey: .cameraISO, value: newValue) }
    }
    
    /// Get or set **Camera Color Temperature** metadata value.
    public var cameraColorTemperature: String? {
        get { getStringValue(forKey: .cameraColorTemperature) }
        set { setStringValue(forKey: .cameraColorTemperature, value: newValue) }
    }
    
    /// Get or set **Camera Color Temperature** metadata value.
    public var codecs: [String]? {
        get { getStringArrayValue(forKey: .codecs) }
        set { setStringArrayValue(forKey: .codecs, value: newValue) }
    }
    
    // TODO: Should be `Date`?
    /// Get or set **Ingest Date** metadata value.
    public var ingestDate: String? {
        get { getStringValue(forKey: .ingestDate) }
        set { setStringValue(forKey: .ingestDate, value: newValue) }
    }
    
    // MARK: - Generic accessors for individual metadata key/value properties
    
    /// Generic method to read a string value for a metadata key.
    public func getStringValue(forKey key: Key) -> String? {
        element._fcpMetadataChild(forKey: key)?.fcpValue
    }
    
    /// Generic method to set a string value for a metadata key.
    public func setStringValue(forKey key: Key, value newValue: String?) {
        element._fcpUpdateMetadataChild(forKey: key, with: newValue)
    }
    
    /// Generic method to read a string array value for a metadata key.
    public func getStringArrayValue(forKey key: Key) -> [String]? {
        element._fcpMetadataChildStringArrayValue(forKey: key)
    }
    
    /// Generic method to set a string array value for a metadata key.
    public func setStringArrayValue(forKey key: Key, value newArray: [String]?) {
        element._fcpUpdateMetadataChild(forKey: key, with: newArray)
    }
    
    // MARK: - General child accessors
    
    /// Get or set child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        get { element.childElements }
        set {
            element.removeAllChildren()
            element.addChildren(newValue)
        }
    }
    
    /// Get or set the metadata contents as model objects.
    public var metadatumContents: [Metadatum] {
        get { element.childElements.compactMap(\.fcpAsMetadatum) }
        set {
            element.removeAllChildren()
            element.addChildren(newValue.map(\.element))
        }
    }
}

// MARK: - Typing

// Metadata
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Metadata`` model object.
    /// Call this on a `metadata` element only.
    public var fcpAsMetadata: FinalCutPro.FCPXML.Metadata? {
        .init(element: self)
    }
}

// MARK: - Metadata Keys

extension FinalCutPro.FCPXML.Metadata {
    // TODO: This is not an exhaustive or complete list of metadata keys.
    
    /// Common/standard Final Cut Pro metadata keys.
    public enum Key: String, Equatable, Hashable, CaseIterable {
        // typically found within clip element
        case reel = "com.apple.proapps.studio.reel" // value attribute
        case scene = "com.apple.proapps.studio.scene" // value attribute
        case shot = "com.apple.proapps.studio.shot" // value attribute
        case cameraAngle = "com.apple.proapps.studio.angle" // value attribute
        
        // typically found within resource element
        case cameraName = "com.apple.proapps.mio.cameraName" // value attribute
        case rawToLogConversion = "com.apple.proapps.studio.rawToLogConversion" // value attribute
        case colorProfile = "com.apple.proapps.spotlight.kMDItemProfileName" // value attribute
        case cameraISO = "com.apple.proapps.studio.cameraISO" // value attribute
        case cameraColorTemperature = "com.apple.proapps.studio.cameraColorTemperature" // value attribute
        case codecs = "com.apple.proapps.spotlight.kMDItemCodecs" // child string array
        case ingestDate = "com.apple.proapps.mio.ingestDate" // value attribute
    }
}

#endif
