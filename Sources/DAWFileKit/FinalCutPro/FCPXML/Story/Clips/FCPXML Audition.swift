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
        clips.first?.name
    }
    
    public var start: TimecodeKit.Timecode? {
        clips.first?.start
    }
    
    public var duration: TimecodeKit.Timecode? {
        clips.first?.duration
    }
    
    public var enabled: Bool {
        clips.first?.enabled ?? true
    }
    
    public var offset: TimecodeKit.Timecode? {
        clips.first?.offset
    }
}

extension FinalCutPro.FCPXML.Audition {
    /// Attributes unique to ``Audition``.
    public enum Attributes: String {
        case lane
        case modDate
    }
    
    init(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        if let laneString = xmlLeaf.attributeStringValue(forName: Attributes.lane.rawValue) {
            lane = Int(laneString)
        }
        
        clips = FinalCutPro.FCPXML.parseClips(in: xmlLeaf, resources: resources)
    }
}

extension FinalCutPro.FCPXML.Audition: FCPXMLClip {
    public var clipType: FinalCutPro.FCPXML.ClipType { .audition }
    
    public func asAnyClip() -> FinalCutPro.FCPXML.AnyClip {
        .audition(self)
    }
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

extension FinalCutPro.FCPXML.Audition: FCPXMLMarkersExtractable {
    /// Always returns an empty array since an audition cannot directly contain markers.
    public var markers: [FinalCutPro.FCPXML.Marker] {
        []
    }
    
    public func extractMarkers(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        switch settings.auditionMask {
        case .omitAuditions:
            return []
            
        case .activeAudition:
            let children = clips.prefix(1).asAnyStoryElements()
            return extractMarkers(
                settings: settings,
                ancestorsOfParent: ancestorsOfParent,
                children: children
            )
            
        case .allAuditions:
            return extractMarkers(
                settings: settings,
                ancestorsOfParent: ancestorsOfParent,
                children: clips.asAnyStoryElements()
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
