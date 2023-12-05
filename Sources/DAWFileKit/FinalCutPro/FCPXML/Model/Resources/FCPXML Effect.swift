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
    public struct Effect: Equatable, Hashable {
        public let element: XMLElement
        
        // shared resource attributes
        
        /// Required.
        /// Identifier.
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
        
        /// Required.
        /// UID.
        public var uid: String {
            get { element.fcpUID ?? "" }
            set { element.fcpUID = newValue }
        }
        
        /// Source.
        public var src: String? {
            get { element.fcpSRC }
            set { element.fcpSRC = newValue }
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Effect {
    public static let resourceType: FinalCutPro.FCPXML.ResourceType = .effect
    
    public enum Attributes: String, XMLParsableAttributesKey {
        // shared resource attributes
        /// Required.
        /// Identifier.
        case id
        
        /// Name.
        case name
        
        // effect attributes
        
        /// Required.
        /// UID.
        case uid // required
        
        /// Source.
        case src
    }
}

extension XMLElement { // Effect
    /// FCPXML: Returns the element wrapped in an ``FinalCutPro/FCPXML/Effect`` model object.
    /// Call this on an `effect` element only.
    public var fcpAsEffect: FinalCutPro.FCPXML.Effect {
        .init(element: self)
    }
}

#endif
