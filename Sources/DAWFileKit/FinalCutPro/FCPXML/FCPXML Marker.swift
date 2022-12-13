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
    /// Returns the marker type.
    public var markerType: MarkerType {
        switch metaData {
        case .standard: return .standard
        case .chapter: return .chapter
        case .toDo: return .toDo
        }
    }
    
    public enum MarkerNodeType: String {
        case marker
        case chapterMarker = "chapter-marker"
    }
    
    /// Marker XML Attributes.
    public enum Attributes: String {
        // XML Attributes all Markers have in common.
        case start
        case duration
        case value // marker name
        case note
        
        // Chapter Marker only
        case posterOffset
        
        // To Do Marker only
        case completed
    }
}

extension FinalCutPro.FCPXML.Marker {
    public enum MarkerMetaData: Equatable, Hashable {
        
        // <marker start="27248221/7500s" duration="1001/30000s" value="Standard Marker" note="some notes here"/>
        /// Standard Marker.
        case standard
        
        // <chapter-marker start="108995887/30000s" duration="1001/30000s" value="Chapter Marker" posterOffset="11/30s"/>
        /// Chapter Marker.
        case chapter(posterOffset: Timecode)
        
        // <marker start="7266259/2000s" duration="1001/30000s" value="To Do Marker, Incomplete" completed="0" note="more notes here"/>
        // <marker start="54497443/15000s" duration="1001/30000s" value="To Do Marker, Completed" completed="1" note="notes yey"/>
        /// To Do Marker.
        case toDo(completed: Bool)
    }
}

extension FinalCutPro.FCPXML.Marker {
    public enum MarkerType: String, CaseIterable {
        case standard = "Standard"
        case chapter = "Chapter"
        case toDo = "To Do"
    }
    
//    public enum ToDoStatus: String, CaseIterable {
//        case notStarted = "Not Started"
//        case inProgress = "In Progress" // TODO: not sure if FCP supports this? maybe older FCPXML ver?
//        case done = "Done"
//    }
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
            fromString: startString,
            frameRate: frameRate
           )
        {
            start = tc
        } else {
            print("Error: start could not be decoded. Defaulting to 00:00:00:00 @ 30fps.")
            start = FinalCutPro.formTimecode(at: ._30)
        }
        
        // "duration"
        if let durationString = xmlLeaf.attributeStringValue(forName: Attributes.duration.rawValue),
           let tc = try? FinalCutPro.FCPXML.timecode(
            fromString: durationString,
            frameRate: frameRate
           )
        {
            duration = tc
        } else {
            print("Error: duration could not be decoded. Defaulting to 00:00:00:00 @ 30fps.")
            duration = FinalCutPro.formTimecode(at: ._30)
        }
        
        // "value" // marker name
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
            if let posterOffsetString = xmlLeaf.attributeStringValue(forName: Attributes.posterOffset.rawValue),
               let tc = try? FinalCutPro.FCPXML.timecode(
                fromString: posterOffsetString,
                frameRate: frameRate
               )
            {
                metaData = .chapter(posterOffset: tc)
            } else {
                print("Error: posterOffset could not be decoded. Defaulting to 00:00:00:00 @ 30fps.")
                metaData = .chapter(posterOffset: FinalCutPro.formTimecode(at: ._30))
            }
        }
    }
}

#endif
