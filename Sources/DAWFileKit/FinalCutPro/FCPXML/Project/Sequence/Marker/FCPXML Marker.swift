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
        public var start: Timecode
        public var duration: Timecode
        public var name: String
        public var note: String
        public var metaData: MarkerMetaData
        
        public init(
            name: String,
            start: Timecode,
            duration: Timecode,
            note: String,
            metaData: MarkerMetaData = .standard
        ) {
            self.name = name
            self.start = start
            self.duration = duration
            self.note = note
            self.metaData = metaData
        }
    }
}

extension FinalCutPro.FCPXML.Marker {
    /// Init from XML. If marker type is unrecognized, returns `nil`.
    internal init?(
        from xmlLeaf: XMLElement,
        sequenceFrameRate frameRate: TimecodeFrameRate
    ) {
        let leafName = xmlLeaf.name ?? ""
        guard let nodeType = MarkerNodeType(rawValue: leafName)
        else {
            print("Error: Invalid XML leaf name \(leafName.quoted) while attempting to parse marker. Leaf is not a marker.")
            return nil
        }
        
        // parse common attributes that all markers share
        
        // "start"
        if let startString = xmlLeaf.attributeStringValue(forName: Attributes.start.rawValue),
           let tc = try? FinalCutPro.FCPXML.timecode(
            fromRational: startString,
            frameRate: frameRate
           )
        {
            start = tc
        } else {
            let defaultTimecode = FinalCutPro.formTimecode(at: frameRate)
            print("Error: start could not be decoded. Defaulting to \(defaultTimecode.stringValue()) @ \(frameRate.stringValueVerbose).")
            start = defaultTimecode
        }
        
        // "duration"
        if let durationString = xmlLeaf.attributeStringValue(forName: Attributes.duration.rawValue),
           let tc = try? FinalCutPro.FCPXML.timecode(
            fromRational: durationString,
            frameRate: frameRate
           )
        {
            duration = tc
        } else {
            let defaultTimecode = FinalCutPro.formTimecode(at: frameRate)
            print("Error: duration could not be decoded. Defaulting to \(defaultTimecode.stringValue()) @ \(frameRate.stringValueVerbose).")
            duration = defaultTimecode
        }
        
        // "value" - marker name
        name = xmlLeaf.attributeStringValue(forName: Attributes.value.rawValue) ?? ""
        
        // "note"
        note = xmlLeaf.attributeStringValue(forName: Attributes.note.rawValue) ?? ""
        
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
            // FYI: posterOffset (thumbnail timecode) can a be negative offset
            // so we need to use TimecodeInterval
            
            if let posterOffsetString = xmlLeaf.attributeStringValue(forName: Attributes.posterOffset.rawValue),
               let tc = try? FinalCutPro.FCPXML.timecodeInterval(
                fromRational: posterOffsetString,
                frameRate: frameRate
               )
            {
                metaData = .chapter(posterOffset: tc)
            } else {
                let defaultTimecodeInterval = FinalCutPro.formTimecodeInterval(at: frameRate)
                print("Error: posterOffset could not be decoded. Defaulting to \(defaultTimecodeInterval.description) @ \(frameRate.stringValueVerbose).")
                metaData = .chapter(posterOffset: defaultTimecodeInterval)
            }
        }
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
