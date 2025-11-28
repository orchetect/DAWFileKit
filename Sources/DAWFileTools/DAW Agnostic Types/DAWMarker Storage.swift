//
//  DAWMarker Storage.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import SwiftTimecodeCore

extension DAWMarker {
    public struct Storage {
        /// Time value.
        public let value: Value
        
        /// The original frame rate that was associated with the `timeStorage` value.
        public let frameRate: TimecodeFrameRate
        
        /// The original timecode subframes divisor.
        public let base: Timecode.SubFramesBase
        
        public init(
            value: Value,
            frameRate: TimecodeFrameRate,
            base: Timecode.SubFramesBase
        ) {
            self.value = value
            self.frameRate = frameRate
            self.base = base
        }
    }
}

extension DAWMarker.Storage: Equatable { }

extension DAWMarker.Storage: Hashable { }

extension DAWMarker.Storage: Sendable { }

extension DAWMarker.Storage: Codable { }
