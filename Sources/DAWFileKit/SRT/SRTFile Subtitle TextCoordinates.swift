//
//  SRTFile Subtitle TextCoordinates.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import OTCore

extension SRTFile.Subtitle {
    /// Unofficially, text coordinates can be specified at the end of the timestamp line as `X1:… X2:… Y1:… Y2:…`.
    public struct TextCoordinates {
        public var x1: Int
        public var x2: Int
        public var y1: Int
        public var y2: Int
        
        public init(x1: Int, x2: Int, y1: Int, y2: Int) {
            self.x1 = x1
            self.x2 = x2
            self.y1 = y1
            self.y2 = y2
        }
    }
}

extension SRTFile.Subtitle.TextCoordinates: Equatable { }

extension SRTFile.Subtitle.TextCoordinates: Hashable { }

extension SRTFile.Subtitle.TextCoordinates: Sendable { }
