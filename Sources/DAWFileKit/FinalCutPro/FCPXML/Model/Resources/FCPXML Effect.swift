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
    public enum Effect { }
}

extension FinalCutPro.FCPXML.Effect {
    public static let resourceType: FinalCutPro.FCPXML.ResourceType = .effect
    
    public enum Attributes: String, XMLParsableAttributesKey {
        // shared resource attributes
        case id // required
        case name
        
        // effect attributes
        case uid // required
        case src
    }
}

#endif
