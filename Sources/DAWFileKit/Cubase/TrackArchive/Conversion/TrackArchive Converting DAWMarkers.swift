//
//  TrackArchive Converting DAWMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions
import TimecodeKitCore

extension Cubase.TrackArchive {
    /// Creates a new Track Archive XML file by converting markers to marker track(s).
    public init(
        converting markers: [DAWMarker],
        at frameRate: TimecodeFrameRate,
        startTimecode: Timecode,
        includeComments: Bool,
        separateCommentsTrack: Bool = false
    ) {
        var buildMessages: [Cubase.TrackArchive.EncodeMessage] = []
        self.init(
            converting: markers,
            at: frameRate,
            startTimecode: startTimecode,
            includeComments: includeComments,
            separateCommentsTrack: separateCommentsTrack,
            buildMessages: &buildMessages
        )
    }
    
    /// Creates a new Track Archive XML file by converting markers to marker track(s).
    public init(
        converting markers: [DAWMarker],
        at frameRate: TimecodeFrameRate,
        startTimecode: Timecode,
        includeComments: Bool,
        separateCommentsTrack: Bool = false,
        buildMessages messages: inout [Cubase.TrackArchive.EncodeMessage]
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
                if includeComments, !separateCommentsTrack,
                   let comment = marker.comment
                {
                    name += " - " + comment
                }
                
                return name
            },
            buildMessages: &messages
        )
        tracks?.append(.marker(markersTrack))
        
        // comments track
        if includeComments, separateCommentsTrack {
            let commentsTrack = Self.buildTrack(
                name: "Comments",
                from: markers,
                at: frameRate,
                startTimecode: startTimecode,
                markerName: { marker in
                    // skip empty comments and empty comment strings
                    guard let comment = marker.comment,
                          !comment.trimmed.isEmpty
                    else { return nil }
                    
                    return comment
                },
                buildMessages: &messages
            )
            tracks?.append(.marker(commentsTrack))
        }
    }
    
    internal static func buildTrack(
        name: String,
        from markers: [DAWMarker],
        at frameRate: TimecodeFrameRate,
        startTimecode: Timecode,
        markerName nameBlock: (_ marker: DAWMarker) -> String? = { $0.name },
        buildMessages messages: inout [Cubase.TrackArchive.EncodeMessage]
    ) -> Cubase.TrackArchive.MarkerTrack {
        var track = Cubase.TrackArchive.MarkerTrack()
        track.name = name
        let convertedMarkers = markers.convertToCubaseTrackArchiveXMLMarkers(
            at: frameRate,
            startTimecode: startTimecode,
            name: nameBlock,
            buildMessages: &messages
        )
        let boxed = convertedMarkers.map(AnyMarker.init)
        track.events.append(contentsOf: boxed)
        return track
    }
}

extension DAWMarker {
    /// If `nameBlock` returns `nil`, this will also return `nil`.
    internal func convertToCubaseTrackArchiveXMLMarker(
        at frameRate: TimecodeFrameRate,
        startTimecode: Timecode,
        name nameBlock: (_ marker: DAWMarker) -> String? = { $0.name },
        buildMessages messages: inout [Cubase.TrackArchive.EncodeMessage]
    ) -> Cubase.TrackArchive.Marker? {
        let upperLimit = startTimecode.upperLimit
        let subFramesBase = startTimecode.subFramesBase
        
        let markerName = nameBlock(self)
        
        guard let markerTC = resolvedTimecode(
            at: frameRate,
            base: subFramesBase,
            limit: upperLimit,
            startTimecode: startTimecode
        ) else {
            let tcString = startTimecode.stringValue(format: [.showSubFrames])
            let mnString = (markerName ?? "").quoted
            messages.append(.error("Could not resolve timecode for marker at timecode \(tcString) with name \(mnString)."))
            return nil
        }
        
        guard let markerName = markerName else { return nil }
        
        return Cubase.TrackArchive.Marker(
            name: markerName,
            startTimecode: markerTC
        )
    }
}

extension Array where Element == DAWMarker {
    /// If `nameBlock` returns `nil`, this will return an empty array.
    internal func convertToCubaseTrackArchiveXMLMarkers(
        at frameRate: TimecodeFrameRate,
        startTimecode: Timecode,
        name nameBlock: (_ marker: DAWMarker) -> String? = { $0.name },
        buildMessages messages: inout [Cubase.TrackArchive.EncodeMessage]
    ) -> [Cubase.TrackArchive.Marker] {
        reduce(into: [Cubase.TrackArchive.Marker]()) { partialResult, marker in
            guard let converted = marker.convertToCubaseTrackArchiveXMLMarker(
                at: frameRate,
                startTimecode: startTimecode,
                name: nameBlock,
                buildMessages: &messages
            ) else {
                // no need to append a buildMessages error since the method already will if necessary
                return
            }
            partialResult.append(converted)
        }
    }
}

#endif
