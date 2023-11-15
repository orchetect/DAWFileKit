//
//  FCPXML Marker MarkerMetaData.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML.Marker {
    public enum MarkerMetaData: Equatable, Hashable {
        /// Standard Marker.
        case standard
        
        /// Chapter Marker.
        ///
        /// `posterOffset` is the chapter marker's thumbnail location expressed as a delta distance (offset) from the marker's position.
        /// This may be positive or negative which is why it is encapsulated in a `TimecodeInterval`.
        case chapter(posterOffset: TimecodeInterval?)
        
        /// To Do Marker.
        case toDo(completed: Bool)
    }
}

#endif
