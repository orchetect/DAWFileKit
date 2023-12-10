//
//  FCPXML Effect.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Effect shared resource.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Reference visual, audio, or custom effects.
    /// >
    /// > Use the `effect` element to reference an effect that can be a Motion template, a FxPlug,
    /// > an Audio Unit, or an audio effect bundle. Use a `filter-video`, `filter-video-mask`, or
    /// > `filter-audio` element to apply the effect to a story element.
    /// >
    /// > See [`effect`](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/effect
    /// > ).
    public struct Effect: FCPXMLElement {
        public let element: XMLElement
        
        public let elementType: ElementType = .effect
        
        public static let supportedElementTypes: Set<ElementType> = [.effect]
        
        public init() {
            element = XMLElement(name: elementType.rawValue)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementTypeSupported(element: element) else { return nil }
        }
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Effect {
    public enum Attributes: String {
        // shared resource attributes
        /// Identifier. (Required)
        case id
        
        /// Name.
        case name
        
        // effect attributes
        
        /// UID. (Required)
        case uid // required
        
        /// Source.
        case src
    }
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Effect {
    // shared resource attributes
    
    /// Identifier. (Required)
    public var id: String {
        get { element.fcpID ?? "" }
        set { element.fcpID = newValue }
    }
    
    /// Name.
    public var name: String? {
        get { element.fcpName }
        set { element.fcpName = newValue }
    }
    
    // effect attributes
    
    /// UID. (Required)
    public var uid: String {
        get { element.fcpUID ?? "" }
        set { element.fcpUID = newValue }
    }
    
    /// Source.
    public var src: String? {
        get { element.fcpSRC }
        set { element.fcpSRC = newValue }
    }
}

// MARK: - Typing

// Effect
extension XMLElement {
    /// FCPXML: Returns the element wrapped in an ``FinalCutPro/FCPXML/Effect`` model object.
    /// Call this on an `effect` element only.
    public var fcpAsEffect: FinalCutPro.FCPXML.Effect? {
        .init(element: self)
    }
}

#endif
