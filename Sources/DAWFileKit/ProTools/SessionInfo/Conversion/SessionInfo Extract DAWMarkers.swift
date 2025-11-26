//
//  SessionInfo Extract DAWMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKitCore

// MARK: - Helpers

extension ProTools.SessionInfo {
    /// Parses the contents and extracts marker events.
    public func extractDAWMarkers() throws -> [DAWMarkerTrack] {
        guard let frameRate = main.frameRate else {
            throw ParseError.general(
                "Could not determine frame rate."
            )
        }
        
        return markers?.convertToDAWMarkers(originalFrameRate: frameRate) ?? []
    }
}

extension Array where Element == ProTools.SessionInfo.Marker {
    /// Converts `[DAWFileKit.ProTools.SessionInfo.Marker]` to `DAWMarker` array(s) broken down by
    /// ruler/track.
    public func convertToDAWMarkers(
        originalFrameRate: TimecodeFrameRate
    ) -> [DAWMarkerTrack] {
        // PT uses 100 subframes
        let subFramesBase: Timecode.SubFramesBase = .max100SubFrames
        
        // init array so we can append to it
        var dawMarkerTracks: [DAWMarkerTrack] = []
        
        for marker in self {
            // TODO: handle PT Session info text files that don't use Timecode as the primary time format
            guard let loc = marker.location,
                  case let .timecode(tc) = loc
            else { continue }
            
            let storage = DAWMarker.Storage(
                value: .timecodeString(absolute: tc.stringValue(format: ProTools.timecodeStringFormat)),
                frameRate: originalFrameRate,
                base: subFramesBase
            )
            
            let newMarker = DAWMarker(
                storage: storage,
                name: marker.name,
                comment: marker.comment
            )
            
            // add to corresponding marker track.
            // create new track if necessary.
            
            let trackIndex: Int
            if let ti = dawMarkerTracks.firstIndex(where: { dawMarkerTrack in
                dawMarkerTrack.name == marker.trackName &&
                dawMarkerTrack.trackType == marker.trackType
            }) {
                trackIndex = ti
            } else {
                let newMarkerTrack = DAWMarkerTrack(
                    trackType: marker.trackType.dawTrackType,
                    name: marker.trackName,
                    markers: []
                )
                dawMarkerTracks.append(newMarkerTrack)
                trackIndex = dawMarkerTracks.indices.last!
            }
            
            dawMarkerTracks[trackIndex].markers.append(newMarker)
        }
        
        return dawMarkerTracks
    }
}

// MARK: - Bridging to DAW-agnostic types

extension DAWTrackType {
    var proToolsSessionInfoTextMarkerTrackType: ProTools.SessionInfo.Marker.TrackType {
        switch self {
        case .ruler: return .ruler
        case .track: return .track
        }
    }
}

extension ProTools.SessionInfo.Marker.TrackType {
    var dawTrackType: DAWTrackType {
        switch self {
        case .ruler: return .ruler
        case .track: return .track
        }
    }
}

func == (lhs: DAWTrackType, rhs: ProTools.SessionInfo.Marker.TrackType) -> Bool {
    lhs.proToolsSessionInfoTextMarkerTrackType == rhs
}

func == (lhs: ProTools.SessionInfo.Marker.TrackType, rhs: DAWTrackType) -> Bool {
    rhs == lhs
}
