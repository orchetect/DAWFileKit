//
//  DAWMarker Storage.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import TimecodeKit

extension DAWMarker {
    public struct Storage: Codable {
        /// Time value.
        public let value: Value
        
        /// The original frame rate that was associated with the `timeStorage` value.
        public let frameRate: Timecode.FrameRate
        
        /// The original timecode subframes divisor.
        public let base: Timecode.SubFramesBase
        
        public init(
            value: Value,
            frameRate: Timecode.FrameRate,
            base: Timecode.SubFramesBase
        ) {
            self.value = value
            self.frameRate = frameRate
            self.base = base
        }
    }
}
