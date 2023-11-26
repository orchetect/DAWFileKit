//
//  FCPXML Audition.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import CoreMedia
import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Contains one active story element followed by alternative story elements in the audition
    /// > container.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > When exported, the XML lists the currently active item as the first child in the audition
    /// > container.
    public struct Audition: FCPXMLAnchorableAttributes {
        public var lane: Int?
        public var offset: Timecode?
        
        public var clips: [AnyClip]
        
        // TODO: public var dateModified: Date?
        
        public init(
            lane: Int?,
            offset: Timecode?,
            clips: [AnyClip] = []
        ) {
            self.lane = lane
            self.offset = offset
            self.clips = clips
        }
    }
}

extension FinalCutPro.FCPXML.Audition: FCPXMLClipAttributes {
    public var name: String? {
        activeClip?.name
    }
    
    public var start: Timecode? {
        activeClip?.start
    }
    
    public var duration: Timecode? {
        activeClip?.duration
    }
    
    public var enabled: Bool {
        activeClip?.enabled ?? true
    }
}

extension FinalCutPro.FCPXML.Audition: FCPXMLElementContext {
    public var context: FinalCutPro.FCPXML.ElementContext {
        activeClip?.context ?? .init()
    }
}

extension FinalCutPro.FCPXML.Audition: FCPXMLClip {
    /// Attributes unique to ``Audition``.
    public enum Attributes: String, XMLParsableAttributesKey {
        case modDate
    }
    
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        // let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        let anchorableAttributes = Self.parseAnchorableAttributes(
            from: xmlLeaf,
            resources: resources
        )
        lane = anchorableAttributes.lane
        offset = anchorableAttributes.offset
        
        let storyElements = FinalCutPro.FCPXML.storyElements( // adds xmlLeaf as breadcrumb
            in: xmlLeaf,
            breadcrumbs: breadcrumbs,
            resources: resources,
            contextBuilder: contextBuilder
        )
        
        // filter only clips, since auditions can only contain clips and not other story elements
        clips = storyElements.clips()
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == clipType.rawValue else { return nil }
    }
    
    public var clipType: FinalCutPro.FCPXML.ClipType { .audition }
    public func asAnyClip() -> FinalCutPro.FCPXML.AnyClip { .audition(self) }
}

extension FinalCutPro.FCPXML.Audition {
    /// Convenience to return the active audition clip.
    public var activeClip: FinalCutPro.FCPXML.AnyClip? {
        clips.first
    }
    
    /// Convenience to return the inactive audition clips, if any.
    public var inactiveClips: [FinalCutPro.FCPXML.AnyClip] {
        Array(clips.dropFirst())
    }
}

extension FinalCutPro.FCPXML.Audition: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        []
    }
    
    public func extractableChildren() -> [FinalCutPro.FCPXML.AnyElement] {
        // note: extract logic will handle audition mask.
        // this just to fulfill the protocol requirement.
        clips.asAnyElements()
    }
    
    public func extractableChildren(mask: Mask) -> [FinalCutPro.FCPXML.AnyElement] {
        switch mask {
        case .active:
            if let activeClip = activeClip {
                return [activeClip.asAnyElement()]
            } else {
                print("Note: No active audition in FCPXML audition clip.")
                return []
            }
            
        case .activeAndAlternates:
            return clips.asAnyElements()
        }
    }
    
    public enum Mask: Equatable, Hashable, CaseIterable {
        case active
        case activeAndAlternates
    }
}

#endif
