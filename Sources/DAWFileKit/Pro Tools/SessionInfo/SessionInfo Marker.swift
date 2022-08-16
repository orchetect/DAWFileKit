//
//  SessionInfo Marker.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKit

extension ProTools.SessionInfo {
    /// Represents a single marker and its related info
    public struct Marker {
        public var number: Int?
        
        public var timecode: Timecode?
        
        public var timeReference: String = ""
        
        public enum Units {
            case samples
            case ticks
        }
        
        public var units: Units = .samples
        
        public var name: String = ""
        public var comment: String?
        
        // init
        
        public init() { }
        
        public init(
            number: Int? = nil,
            timecode: Timecode? = nil,
            timeReference: String = "",
            units: Units = .samples,
            name: String = "",
            comment: String? = nil
        ) {
            self.number = number
            self.timecode = timecode
            self.timeReference = timeReference
            self.units = units
            self.name = name
            self.comment = comment
        }
        
        /// Convenience function - instances an `Timecode` to the `timecode` property and returns true if timecode is valid.
        mutating func validate(
            timecodeString: String,
            at frameRate: Timecode.FrameRate
        ) -> Bool {
            timecode = ProTools.kTimecode(timecodeString, at: frameRate)
            
            return timecode != nil
        }
    }
}
