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
        
        /// Returns the earliest sequence start timecode in the project.
        public var startTimecode: Timecode? {
            sequences
                .map(\.startTimecode)
                .sorted()
                .first
        }
    }
}

#endif
