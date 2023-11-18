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
    public struct Audition {
        public var clips: [AnyClip]
        
        public var lane: Int?
        
        // TODO: public var dateModified: Date?
        
        public init(
            clips: [AnyClip] = [],
            lane: Int?
        ) {
            self.clips = clips
            self.lane = lane
        }
    }
}

extension FinalCutPro.FCPXML.Audition: FCPXMLClipAttributes {
    public var name: String? {
        activeClip?.name
    }
    
    public var start: TimecodeKit.Timecode? {
        activeClip?.start
    }
    
    public var duration: TimecodeKit.Timecode? {
        activeClip?.duration
    }
    
    public var enabled: Bool {
        activeClip?.enabled ?? true
    }
    
    public var offset: TimecodeKit.Timecode? {
        activeClip?.offset
    }
}

extension FinalCutPro.FCPXML.Audition: FCPXMLElementContext {
    public var context: FinalCutPro.FCPXML.ElementContext {
        activeClip?.context ?? .init()
    }
}

extension FinalCutPro.FCPXML.Audition: FCPXMLClip {
    /// Attributes unique to ``Audition``.
    public enum Attributes: String {
        case lane
        case modDate
    }
    
    public init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        if let laneString = xmlLeaf.attributeStringValue(forName: Attributes.lane.rawValue) {
            lane = Int(laneString)
        }
        
        let storyElements = FinalCutPro.FCPXML.storyElements(in: xmlLeaf, resources: resources)
        
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
    
    public func extractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyElement],
        matching predicate: (_ element: FinalCutPro.FCPXML.AnyElement) -> Bool
    ) -> [FinalCutPro.FCPXML.AnyElement] {
        switch settings.auditionMask {
        case .omitAuditions:
            return []
            
        case .activeAudition:
            guard let activeClip = activeClip else {
                print("Note: No active audition in FCPXML audition clip.")
                return []
            }
            return extractElements(
                settings: settings,
                ancestorsOfParent: ancestorsOfParent,
                contents: [activeClip.asAnyElement()],
                matching: predicate
            )
            
        case .allAuditions:
            return extractElements(
                settings: settings,
                ancestorsOfParent: ancestorsOfParent,
                contents: clips.asAnyElements(),
                matching: predicate
            )
        }
    }
    
    public enum Mask {
        case omitAuditions
        case activeAudition
        case allAuditions
    }
}

#endif
