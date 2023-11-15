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
    public struct Audition: FCPXMLStoryElement {
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
    public var markers: [FinalCutPro.FCPXML.Marker] {
        clips.first?.markers ?? []
    }
    
    public func extractMarkers(
        settings: FCPXMLMarkersExtractionSettings
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        switch settings.auditionMask {
        case .omitAuditions:
            return []
            
        case .activeAudition:
            return activeClip?.extractMarkers(settings: settings) ?? []
            
        case .allAuditions:
            return clips.flatMap { $0.extractMarkers(settings: settings) }
        }
    }
    
    public enum Mask {
        case omitAuditions
        case activeAudition
        case allAuditions
    }
}

#endif
