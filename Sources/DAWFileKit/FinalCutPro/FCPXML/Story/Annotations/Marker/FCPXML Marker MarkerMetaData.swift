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
        // <marker start="27248221/7500s" duration="1001/30000s" value="Standard Marker" note="some notes here"/>
        /// Standard Marker.
        case standard
        
        // <chapter-marker start="108995887/30000s" duration="1001/30000s" value="Chapter Marker" posterOffset="11/30s"/>
        /// Chapter Marker.
        ///
        /// `posterOffset` is the chapter marker's thumbnail location expressed as a delta distance (offset) from the marker's position.
        /// This may be positive or negative which is why it is encapsulated in a `TimecodeInterval`.
        case chapter(posterOffset: TimecodeInterval?)
        
        // <marker start="7266259/2000s" duration="1001/30000s" value="To Do Marker, Incomplete" completed="0" note="more notes here"/>
        // <marker start="54497443/15000s" duration="1001/30000s" value="To Do Marker, Completed" completed="1" note="notes yey"/>
        /// To Do Marker.
        case toDo(completed: Bool)
    }
}

#endif
