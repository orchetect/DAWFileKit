//
//  TrackArchive Extract DAWMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore

extension Cubase.TrackArchive {
    /// Parses the contents and extracts marker events from marker tracks.
    public func extractDAWMarkers() throws -> [DAWMarkerTrack] {
        guard let frameRate = main.frameRate else {
            throw ParseError.general(
                "Could not determine frame rate."
            )
        }
        
        // init array so we can append to it
        var dawMarkerTracks: [DAWMarkerTrack] = []
        
        // filter just marker tracks (in case there are other non-marker tracks in the data set)
        
        var markerTracks: [MarkerTrack] = tracks?.compactMap {
            switch $0 {
            case let .marker(track): track
            default: nil
            }
        } ?? []
        
        // if necessary, convert time values to be from zero (00:00:00:00) instead of offsets from session start time
        
        if let startTimeSeconds = main.startTimeSeconds,
           startTimeSeconds > 0.0
        {
            //logger.debug(
            //    "Converting " + fileTypeDescription + " event start times to zero-start. (" +
            //    "\(startTimeSeconds)" +
            //    "sec session start time, \(markerTracks.count) marker tracks)"
            //)
            
            for trackIdx in markerTracks.indices {
                for eventIdx in markerTracks[trackIdx].events.indices {
                    if let srt = markerTracks[trackIdx].events[eventIdx].startRealTime {
                        markerTracks[trackIdx].events[eventIdx].startRealTime = srt + startTimeSeconds
                    }
                }
            }
        }
        
        for markerTrack in markerTracks {
            // translate to native Marker objects
            let markers = markerTrack.events.convertToDAWMarkers(
                originalFrameRate: frameRate
            )
            
            let dawMarkerTrack = DAWMarkerTrack(
                trackType: .track,
                name: markerTrack.name ?? "",
                markers: markers
            )
            
            dawMarkerTracks.append(dawMarkerTrack)
        }
        
        return dawMarkerTracks
    }
}

// MARK: - Helpers

extension Array where Element: CubaseTrackArchiveMarker {
    /// Converts `[any CubaseTrackArchiveMarker]` to `[DAWMarker]`.
    public func convertToDAWMarkers(
        originalFrameRate: TimecodeFrameRate
    ) -> [DAWMarker] {
        // Cubase uses 80 subframes
        let subFramesBase: Timecode.SubFramesBase = .max80SubFrames
        
        // init array so we can append to it
        var markers: [DAWMarker] = []
        
        for marker in self {
            // take start time regardless whether it's a marker or cycle marker
            let tc = marker.startTimecode
            
            if marker.startRealTime != nil {
                let storage = DAWMarker.Storage(
                    value: .realTime(relativeToStart: marker.startRealTime!),
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
                    value: .timecodeString(absolute: tc.stringValue(format: Cubase.timecodeStringFormat)),
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
