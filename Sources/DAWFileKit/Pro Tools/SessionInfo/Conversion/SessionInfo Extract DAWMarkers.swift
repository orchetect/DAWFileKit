//
//  SessionInfo Extract DAWMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKit

// MARK: - Helpers

extension ProTools.SessionInfo {
    /// Parses the contents and extracts marker events.
    public func extractDAWMarkers() throws -> [DAWMarker] {
        guard let frameRate = main.frameRate else {
            throw ParseError.general(
                "Could not determine frame rate."
            )
        }
        
        return markers?.convertToDAWMarkers(originalFrameRate: frameRate) ?? []
    }
}

extension Array where Element == ProTools.SessionInfo.Marker {
    /// Converts `[DAWFileKit.ProTools.SessionInfo.Marker]` to `[DAWMarker]`.
    public func convertToDAWMarkers(
        originalFrameRate: Timecode.FrameRate
    ) -> [DAWMarker] {
        // PT uses 100 subframes
        let subFramesBase: Timecode.SubFramesBase = ._100SubFrames
        
        // init array so we can append to it
        var markers: [DAWMarker] = []
        
        for marker in self {
            // TODO: handle PT Session info text files that don't use Timecode as the primary time format
            guard let loc = marker.location,
                  case let .timecode(tc) = loc
            else { continue }
            
            let storage = DAWMarker.Storage(
                value: .timecodeString(tc.stringValue),
                frameRate: originalFrameRate,
                base: subFramesBase
            )
            
            let newMarker = DAWMarker(
                storage: storage,
                name: marker.name,
                comment: marker.comment
            )
            
            markers.append(newMarker)
        }
        
        return markers
    }
}
