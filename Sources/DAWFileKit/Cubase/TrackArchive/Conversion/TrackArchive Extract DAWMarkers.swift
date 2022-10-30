//
//  TrackArchive Extract DAWMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension Cubase.TrackArchive {
    /// Parses the contents and extracts marker events from marker tracks.
    public func extractDAWMarkers() throws -> [[DAWMarker]] {
        guard let frameRate = main.frameRate else {
            throw ParseError.general(
                "Could not determine frame rate."
            )
        }
        
        // filter just marker tracks (in case there are other non-marker tracks in the data set)
        
        var markerTracks = tracks?.compactMap { $0 as? Cubase.TrackArchive.MarkerTrack } ?? []
        
        // if necessary, convert time values to be from zero (00:00:00:00) instead of offsets from session start time
        
        if let startTimeSeconds = main.startTimeSeconds,
           startTimeSeconds > 0.0
        {
            //logger.debug(
            //    "Converting " + fileTypeDescription + " event start times to zero-start. (" +
            //    "\(startTimeSeconds)" +
            //    "sec session start time, \(markerTracks.count) marker tracks)"
            //)
            
            for trackidx in markerTracks.indices {
                for eventidx in markerTracks[trackidx].events.indices {
                    if let srt = markerTracks[trackidx].events[eventidx].startRealTime {
                        markerTracks[trackidx].events[eventidx]
                            .startRealTime = srt + startTimeSeconds
                    }
                }
            }
        }
        
        // translate to native Marker objects
        
        let markers = markerTracks.map {
            $0.events.convertToDAWMarkers(
                originalFrameRate: frameRate
            )
        }
        
        return markers
    }
}

// MARK: - Helpers

extension Array where Element == CubaseTrackArchiveMarker {
    /// Converts `[CubaseTrackArchiveMarker]` to `[DAWMarker]`.
    public func convertToDAWMarkers(
        originalFrameRate: Timecode.FrameRate
    ) -> [DAWMarker] {
        // Cubase uses 80 subframes
        let subFramesBase: Timecode.SubFramesBase = ._80SubFrames
        
        // init array so we can append to it
        var markers: [DAWMarker] = []
        
        for marker in self {
            // take start time regardless whether it's a marker or cycle marker
            let tc = marker.startTimecode
            
            if marker.startRealTime != nil {
                let storage = DAWMarker.Storage(
                    value: .realTime(marker.startRealTime!),
                    frameRate: originalFrameRate,
                    base: subFramesBase
                )
                
                let newMarker = DAWMarker(
                    storage: storage,
                    name: marker.name
                ) // no comment text
                
                markers.append(newMarker)
            } else {
                let storage = DAWMarker.Storage(
                    value: .timecodeString(tc.stringValue),
                    frameRate: originalFrameRate,
                    base: subFramesBase
                )
                
                let newMarker = DAWMarker(
                    storage: storage,
                    name: marker.name
                ) // no comment text
                
                markers.append(newMarker)
            }
        }
        
        return markers
    }
}

#endif
