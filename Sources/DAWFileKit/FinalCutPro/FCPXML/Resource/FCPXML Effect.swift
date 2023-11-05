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
        let name: String
        let id: String
        
        // effect attributes
        let uid: String
        
        init(
            name: String,
            id: String,
            uid: String
        ) {
            // shared resource attributes
            self.name = name
            self.id = id
            
            // effect attributes
            self.uid = uid
        }
        
        init(from xmlLeaf: XMLElement) {
            name = xmlLeaf.attributeStringValue(forName: Attributes.name.rawValue) ?? ""
            id = xmlLeaf.attributeStringValue(forName: Attributes.id.rawValue) ?? ""
            
            // effect attributes
            uid = xmlLeaf.attributeStringValue(forName: Attributes.uid.rawValue) ?? ""
        }
    }
}

extension FinalCutPro.FCPXML.Effect {
    public enum Attributes: String {
        // shared resource attributes
        case name
        case id
        
        // effect attributes
        case uid
    }
}

#endif
