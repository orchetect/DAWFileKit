//
//  FCPXML Project.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import CoreMedia

extension FinalCutPro.FCPXML {
    public struct Project {
        public let name: String
        public let sequences: [Sequence]
    }
}

extension FinalCutPro.FCPXML.Project {
    /// Returns the start timecode of the earliest sequence in the project.
    public var startTimecode: Timecode? {
        sequences
            .map(\.start)
            .sorted()
            .first
    }
    
    /// Returns the frame rate of the project.
    public var frameRate: TimecodeFrameRate? {
        sequences
            .map(\.start)
            .sorted()
            .map(\.frameRate)
            .first
    }
}

#endif
