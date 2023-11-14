//
//  FCPXML Marker.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import CoreMedia

extension FinalCutPro.FCPXML {
    /// Represents a marker event and its contents.
    public struct Marker: Equatable, Hashable {
        public var start: Timecode // required
        public var duration: Timecode?
        public var name: String // a.k.a. `value`, required
        public var metaData: MarkerMetaData // required
        public var note: String?
        
        public init(
            start: Timecode,
            duration: Timecode?,
            name: String,
            metaData: MarkerMetaData = .standard,
            note: String?
        ) {
            self.start = start
            self.duration = duration
            self.name = name
            self.metaData = metaData
            self.note = note
        }
    }
}

extension FinalCutPro.FCPXML.Marker {
    /// Attributes unique to Marker.
    public enum Attributes: String {
        // common for all marker types
        case start
        case duration
        case value // a.k.a name
        case note
        
        // Chapter Marker only
        case posterOffset
        
        // To Do Marker only
        case completed
    }
    
    /// Init from XML. If marker type is unrecognized, returns `nil`.
    init?(
        from xmlLeaf: XMLElement,
        frameRate: TimecodeFrameRate
    ) {
        let leafName = xmlLeaf.name ?? ""
        guard let nodeType = MarkerNodeType(rawValue: leafName)
        else {
            print("Error: Invalid XML leaf name \(leafName.quoted) while attempting to parse marker. Leaf is not a marker.")
            return nil
        }
        
        // parse common attributes that all markers share
        
        // "start"
        guard let startString = xmlLeaf.attributeStringValue(forName: Attributes.start.rawValue),
              let start = try? FinalCutPro.FCPXML.timecode(
                  fromRational: startString,
                  frameRate: frameRate
              )
        else {
            print("Error: marker start could not be decoded.")
            return nil
        }
        self.start = start
        
        // "duration"
        if let durationString = xmlLeaf.attributeStringValue(forName: Attributes.duration.rawValue),
           let tc = try? FinalCutPro.FCPXML.timecode(
            fromRational: durationString,
            frameRate: frameRate
           )
        {
            duration = tc
        }
        
        // "value" - marker name
        guard let name = xmlLeaf.attributeStringValue(forName: Attributes.value.rawValue) else { return nil }
        self.name = name
        
        // "note"
        note = xmlLeaf.attributeStringValue(forName: Attributes.note.rawValue)
        
        // check marker type to parse additional metadata
        
        switch nodeType {
        case .marker: // standard marker or to-do marker
            // "completed" attribute will only exist if marker is a to-do marker
            if let completed = xmlLeaf.attributeStringValue(forName: Attributes.completed.rawValue)
            {
                metaData = .toDo(completed: completed == "1")
            } else {
                // marker is a standard marker
                metaData = .standard
            }
            
        case .chapterMarker:
            // FYI: posterOffset (thumbnail timecode) is optional, but can a be negative offset
            // so we need to use TimecodeInterval
            
            var posterOffset: TimecodeInterval? = nil
            if let posterOffsetString = xmlLeaf.attributeStringValue(forName: Attributes.posterOffset.rawValue) {
                guard let tc = try? FinalCutPro.FCPXML.timecodeInterval(
                    fromRational: posterOffsetString,
                    frameRate: frameRate
                ) else {
                    print("Error: marker posterOffset could not be decoded.")
                    return nil
                }
                posterOffset = tc
            }
            metaData = .chapter(posterOffset: posterOffset)
        }
    }
    
    init?<C: FCPXMLTimelineAttributes>(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        timelineContext: C.Type,
        timelineContextInstance: C
    ) {
        guard let frameRate = FinalCutPro.FCPXML.parseTimecodeFrameRate(
            from: xmlLeaf,
            resources: resources,
            timelineContext: timelineContext,
            timelineContextInstance: timelineContextInstance
        ) else { return nil }
        self.init(from: xmlLeaf, frameRate: frameRate)
    }
}

extension FinalCutPro.FCPXML.Marker {
    /// Returns the marker type.
    public var markerType: MarkerType {
        switch metaData {
        case .standard: return .standard
        case .chapter: return .chapter
        case .toDo: return .toDo
        }
    }
}

#endif
