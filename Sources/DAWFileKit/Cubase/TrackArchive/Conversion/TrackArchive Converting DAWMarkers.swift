//
//  TrackArchive Converting DAWMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

extension Cubase.TrackArchive {
    /// Returns XML data if success
    public init?(
        converting markers: [DAWMarker],
        at frameRate: Timecode.FrameRate,
        startTimecode: Timecode,
        includeComments: Bool,
        separateCommentTrack: Bool = false
    ) {
        self.init()
        
        main.startTimecode = startTimecode
        main.frameRate = frameRate
        
        tracks = [] // init track array
        
        // markers track
        let markersTrack = Self.buildTrack(
            name: "Markers",
            from: markers,
            at: frameRate,
            startTimecode: startTimecode,
            markerName: { marker in
                var name = marker.name
                
                // add comment to marker text, if comments are included and comments aren't destined
                // for their own track
                if includeComments, !separateCommentTrack,
                   let comment = marker.comment
                {
                    name += " - " + comment
                }
                
                return name
            }
        )
        tracks?.append(markersTrack)
        
        // comments track
        if includeComments, separateCommentTrack {
            let commentsTrack = Self.buildTrack(
                name: "Markers",
                from: markers,
                at: frameRate,
                startTimecode: startTimecode,
                markerName: { marker in
                    // skip empty comments and empty comment strings
                    guard let comment = marker.comment,
                          !comment.trimmed.isEmpty
                    else { return nil }
                    
                    return comment
                }
            )
            tracks?.append(commentsTrack)
        }
    }
    
    /// Returns XML data if success
    internal static func buildTrack(
        name: String,
        from markers: [DAWMarker],
        at frameRate: Timecode.FrameRate,
        startTimecode: Timecode,
        markerName nameBlock: (_ marker: DAWMarker) -> String? = { $0.name }
    ) -> Cubase.TrackArchive.MarkerTrack {
        var track = Cubase.TrackArchive.MarkerTrack()
        track.name = name
        let convertedMarkers = markers.convertToCubaseTrackArchiveXMLMarkers(
            at: frameRate,
            startTimecode: startTimecode,
            name: nameBlock
        )
        track.events.append(contentsOf: convertedMarkers)
        return track
    }
}

extension DAWMarker {
    internal func convertToCubaseTrackArchiveXMLMarker(
        at frameRate: Timecode.FrameRate,
        startTimecode: Timecode,
        name nameBlock: (_ marker: DAWMarker) -> String? = { $0.name }
    ) -> Cubase.TrackArchive.Marker? {
        let upperLimit = startTimecode.upperLimit
        let subFramesBase = startTimecode.subFramesBase
        
        guard let startTC = try? resolvedTimecode(
            at: frameRate,
            limit: upperLimit,
            base: subFramesBase
        )?
            .subtracting(startTimecode.components)
        else {
            // logger.error("Could not resolve timecode.")
            return nil
        }
        
        guard let markerName = nameBlock(self) else { return nil }
        
        return Cubase.TrackArchive.Marker(
            name: markerName,
            startTimecode: startTC
        )
    }
}

extension Array where Element == DAWMarker {
    internal func convertToCubaseTrackArchiveXMLMarkers(
        at frameRate: Timecode.FrameRate,
        startTimecode: Timecode,
        name nameBlock: (_ marker: DAWMarker) -> String? = { $0.name }
    ) -> [Cubase.TrackArchive.Marker] {
        reduce(into: [Cubase.TrackArchive.Marker]()) { partialResult, marker in
            if let converted = marker.convertToCubaseTrackArchiveXMLMarker(
                at: frameRate,
                startTimecode: startTimecode,
                name: nameBlock
            ) {
                partialResult.append(converted)
            }
        }
    }
}
