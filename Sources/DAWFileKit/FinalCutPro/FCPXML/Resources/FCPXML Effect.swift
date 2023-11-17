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
    /// > See [`effect`](https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/effect).
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

extension FinalCutPro.FCPXML.Effect {
    /// Attributes unique to ``Effect``.
    public enum Attributes: String {
        // shared resource attributes
        case id
        case name
        
        // effect attributes
        case uid
        case src
    }
    
    init?(from xmlLeaf: XMLElement) {
        guard let id = xmlLeaf.attributeStringValue(forName: Attributes.id.rawValue) else { return nil }
        self.id = id
        name = xmlLeaf.attributeStringValue(forName: Attributes.name.rawValue)
        
        // effect attributes
        guard let uid = xmlLeaf.attributeStringValue(forName: Attributes.uid.rawValue) else { return nil }
        self.uid = uid
        src = xmlLeaf.attributeStringValue(forName: Attributes.src.rawValue)
    }
}

extension FinalCutPro.FCPXML.Effect: FCPXMLResource {
    public var resourceType: FinalCutPro.FCPXML.ResourceType { .effect }
    public func asAnyResource() -> FinalCutPro.FCPXML.AnyResource { .effect(self) }
}

#endif
