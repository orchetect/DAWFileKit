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
    public struct Marker {
        public var type: MarkerType
        public var name: String
//        public var notes: String
//        public var role: String
//        public var status: MarkerStatus
//        public var checked: Bool
        public var startTimecode: Timecode // contains frame rate
//        public var parentClipName: String
//        public var parentClipDuration: TimecodeInterval
//        public var parentEventName: String
//        public var parentProjectName: String
//        public var parentLibraryName: String
//        public var nameMode: MarkerIDMode
        
//        public var id: String {
//            switch nameMode {
//            case .projectTimecode:
//                return "\(parentProjectName)_\(startTimecode)"
//            case .name:
//                return name
//            case .notes:
//                return notes
//            }
//        }
        
        public init(
            type: MarkerType,
            name: String,
            startTimecode: Timecode
        ) {
            self.type = type
            self.name = name
            self.startTimecode = startTimecode
        }
    }
}

extension FinalCutPro.FCPXML.Marker {
    public enum MarkerType: String, CaseIterable {
        case standard = "Standard"
        case chapter = "Chapter"
        case todo = "To Do"
    }
    
    public enum MarkerStatus: String, CaseIterable {
        case notStarted = "Not Started"
        case inProgress = "In Progress"
        case done = "Done"
    }
    
    public enum MarkerIDMode: String, CaseIterable {
        case projectTimecode = "ProjectTimecode"
        case name = "Name"
        case notes = "Notes"
    }
}

#endif
