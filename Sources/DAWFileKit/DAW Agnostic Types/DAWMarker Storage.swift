//
//  DAWMarker Storage.swift
//  MarkerToolShared
//
//  Created by Steffan Andrews on 2020-07-30.
//  Copyright © 2020 Steffan Andrews. All rights reserved.
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
