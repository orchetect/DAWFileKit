//
//  FCPXML Effect.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

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
        // shared resource attributes
        public var id: String // required
        public var name: String?
        
        // effect attributes
        public var uid: String // required
        public var src: String?
        
        public init(
            id: String,
            name: String?,
            uid: String,
            src: String?
        ) {
            // shared resource attributes
            self.id = id
            self.name = name
            
            // effect attributes
            self.uid = uid
            self.src = src
        }
    }
}

extension FinalCutPro.FCPXML.Effect: FCPXMLResource {
    /// Attributes unique to ``Effect``.
    public enum Attributes: String, XMLParsableAttributesKey {
        // shared resource attributes
        case id
        case name
        
        // effect attributes
        case uid
        case src
    }
    
    public init?(from xmlLeaf: XMLElement) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        guard let id = rawValues[.id] else { return nil }
        self.id = id
        name = rawValues[.name]
        
        // effect attributes
        guard let uid = rawValues[.uid] else { return nil }
        self.uid = uid
        src = rawValues[.src]
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == resourceType.rawValue else { return nil }
    }
    
    public var resourceType: FinalCutPro.FCPXML.ResourceType { .effect }
    public func asAnyResource() -> FinalCutPro.FCPXML.AnyResource { .effect(self) }
}

#endif
