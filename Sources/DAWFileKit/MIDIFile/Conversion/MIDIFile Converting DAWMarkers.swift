//
//  MIDIFile Converting DAWMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
@_implementationOnly import OTCore
import MIDIKitSMF
import TimecodeKit

extension MIDIFile {
    /// Constructs a MIDI file based on a marker list.
    /// Markers must be sorted chronologically first, by calling `markers.sorted()`.
    public init(
        converting markers: [DAWMarker],
        tempo inputTempo: Double,
        startTimecode: Timecode,
        includeComments: Bool
    ) throws {
        var buildMessages: [String] = []
        try self.init(
            converting: markers,
            tempo: inputTempo,
            startTimecode: startTimecode,
            includeComments: includeComments,
            buildMessages: &buildMessages
        )
    }
    
    /// Constructs a MIDI file based on a marker list.
    /// Markers must be sorted chronologically first, by calling `markers.sorted()`.
    public init(
        converting markers: [DAWMarker],
        tempo: Double,
        startTimecode: Timecode,
        includeComments: Bool,
        buildMessages messages: inout [String]
    ) throws {
        // MARK: File header
        
        var midiFile = MIDIFile()
        
        midiFile.format = .singleTrack
        
        // MARK: Tempo validation and calculation
        
        let tempoEvent = try Self.encodedTempo(bpm: tempo, buildMessages: &messages)
        let tempo = tempoEvent.bpmEncoded
        
        // MARK: File time-base
        
        let tpq = Self.ticksPerQuarter(forTempo: tempo)
        midiFile.timeBase = .musical(ticksPerQuarterNote: tpq)
        
        // MARK: MIDI file track
        
        let newTrack = Self.newMarkersTrack(
            name: "Markers",
            smpteStart: startTimecode,
            staticTempo: tempoEvent
        )
        
        // MARK: Marker Events
        
        let trackWriter = MarkersTrackWriter(
            track: newTrack,
            startTimecode: startTimecode,
            tempo: tempoEvent
        )
        
        for marker in markers {
            let markerBuildMessages = try trackWriter.add(
                marker: marker,
                includeComments: includeComments
            )
            messages.append(contentsOf: markerBuildMessages)
        }
        
        // MARK: Add track to MIDI file
        
        midiFile.chunks.append(.track(trackWriter.track))
        
        self = midiFile
    }
}

// MARK: - Builder Methods

extension MIDIFile {
    /// Validate and convert tempo to a quantized tempo compatible with Standard MIDI Files.
    static func encodedTempo(
        bpm inputTempo: Double,
        buildMessages messages: inout [String]
    ) throws -> MIDIFileEvent.Tempo {
        guard (5.0 ... 300.0).contains(inputTempo) else {
            throw BuildError.general(
                "Tempo \(inputTempo)bpm is not within valid range (5bpm-300bpm)."
            )
        }
        
        // because tempo resolution is lossy in a MIDI file, we need to get the tempo value
        // converted to the format that is stored in the midi file, then convert it back to a double
        // which may be slightly off from our actual input tempo (ie: 152.5 bpm -> midi file ->
        // 152.503 bpm read by a DAW importing the midi file). this will ensure optimal accuracy
        // when calculating marker event positions in the midi file
        
        let tempoEvent = MIDIFileEvent.Tempo(bpm: inputTempo)
        let encodedTempo = tempoEvent.bpmEncoded // get our new adjusted tempo for calculation
        
        if inputTempo != encodedTempo {
            messages.append(
                "Input tempo \(inputTempo)bpm resolves to \(encodedTempo)bpm after encoding in a MIDI file. "
                + "Depending on variances in how DAWs interpret MIDI file tempos, after importing the MIDI file, markers may not exactly correspond to their timecodes in the DAW session. "
                + "Stable tempos for retaining the highest timing precision include: 30, 60, 120, 125, 150, 160, 192, 200, 240, 250 bpm."
            )
        }
        
        return tempoEvent
    }
    
    /// Ticks per quarter-note resolution.
    static func ticksPerQuarter(forTempo tempo: Double) -> UInt16 {
        // calculate a multiple of the tempo for increased resolution/accuracy
        // 4_000 is a soft ceiling -- according to my tests, it's a safe maximum that can address at
        // least 24 hours up to 300 bpm and all frame rates
        
        // Pro Tools uses 9600
        // Cubase uses 480 by default but can be changed
        
        // this code DOES WORK but may not be necessary - in my tests, using 4000 vs. calculated
        // ppq based on tempo made no practical difference
        //    var ppqCalculation = tempo
        //    repeat {
        //        // calculate highest power of 2
        //        ppqCalculation = ppqCalculation * 2
        //    } while ppqCalculation < 4_000
        //    midifile.midiFileTicksPerQuarter = UInt16(ppqCalculation)
        //
        //    logger.debug("constructMIDIFile(...): Calculated \(midifile.midiFileTicksPerQuarter)ppq based on tempo \(tempo)bpm.")
        
        // set to static PPQ
        return 9600
    }
    
    static func ticksPerSecond(tempo: Double, ticksPerQuarter: UInt16) -> Double {
        // let beatDurationInSeconds = (60.0 / tempo)
        
        let beatsPerSecond = (tempo / 60.0)
        let ticksPerSecond = beatsPerSecond * Double(ticksPerQuarter)
        
        return ticksPerSecond
    }
    
    static func newMarkersTrack(
        name trackName: String,
        smpteStart: Timecode,
        staticTempo: MIDIFileEvent.Tempo
    ) -> Chunk.Track {
        var midiTrack = MIDIFile.Chunk.Track()
        
        midiTrack.events.append(
            .text(
                delta: .none,
                type: .trackOrSequenceName,
                string: trackName
            )
        )
        
        // Pro Tools will read SMPTE offset and set its session start time to that timecode.
        // It doesn't interpret the frame rate from the MIDI file in a way that is expected.
        // ie: MIDI file with 29.97d rate will make Pro Tools set its session frame rate to 30d
        // even though Pro Tools 2020.12.0 will write both 29.97d and 30d as 29.97d in a MIDI file.
        // For some reason it decides 30d is a better candidate for importing the MIDI file...?
        // Might be a PT bug because I can't imagine 30d is more useful/common.
        
        midiTrack.events.append(.smpteOffset(delta: .none, scaling: smpteStart))
        
        midiTrack.events.append(staticTempo.smfWrappedEvent(delta: .none))
        
        return midiTrack
    }
    
    /// Origin time offset in milliseconds.
    ///
    /// Start with slight offset so markers fall at the start of a frame and not just prior to
    /// it, with tolerance for the deltaTicks round() up or down that happens.
    /// Based on our calculation method, some frame rates may need a larger offset to overcome
    /// potential +/- variances.
    static func staticOffsetMS(for frameRate: TimecodeFrameRate) -> Double {
        frameRate.frameDuration.doubleValue / 32
    }
}

// MARK: - Track Writer

extension MIDIFile {
    class MarkersTrackWriter {
        private let startTimecode: Timecode
        private var frameRate: TimecodeFrameRate { startTimecode.frameRate }
        private var subFramesBase: Timecode.SubFramesBase { startTimecode.subFramesBase }
        private var upperLimit: Timecode.UpperLimit { startTimecode.upperLimit }
        
        private let ticksPerSecond: Double
        
        private var currentRealTimeOffset: Double
        private let originRealTimeOffset: Double
        private var framePosition: Timecode
        private var realTimePosition = 0.0
        private var tickPosition: UInt32 = 0
        
        public var track: Chunk.Track
        
        public init(
            track: Chunk.Track,
            startTimecode: Timecode,
            tempo: MIDIFileEvent.Tempo
        ) {
            self.track = track
            self.startTimecode = startTimecode
            
            // origin time offset in ms
            currentRealTimeOffset = MIDIFile.staticOffsetMS(for: startTimecode.frameRate)
            originRealTimeOffset = MIDIFile.staticOffsetMS(for: startTimecode.frameRate)
            framePosition = startTimecode
            
            // ticks per second
            let encodedTempo = tempo.bpmEncoded
            let tpq = MIDIFile.ticksPerQuarter(forTempo: encodedTempo)
            ticksPerSecond = MIDIFile.ticksPerSecond(tempo: encodedTempo, ticksPerQuarter: tpq)
        }
        
        /// Add a marker to the track.
        /// - Returns: Build messages.
        public func add(
            marker: DAWMarker,
            includeComments: Bool
        ) throws -> [String] {
            #warning(
                "> TODO: may need to factor in marker's original session start timecode against the 'startTimecode' parameter passed into this function"
            )
            
            var buildMessages: [String] = []
            
            // get marker's timecode object
            guard let markerTimecode = marker.resolvedTimecode(
                at: frameRate,
                base: subFramesBase,
                limit: upperLimit,
                startTimecode: startTimecode
            ) else {
                throw BuildError.general(
                    "Encountered an invalid timecode in the markers list."
                )
            }
            
            // calculate amount of time to advance
            let deltaAdvanceFrames = (markerTimecode - framePosition)
            
            var deltaAdvanceRealTime = currentRealTimeOffset
            deltaAdvanceRealTime += ((markerTimecode - startTimecode).realTimeValue * 1000.0) // ms
            deltaAdvanceRealTime -= ((framePosition - startTimecode).realTimeValue * 1000.0) // ms
            
            // only use offset the for the first marker
            if currentRealTimeOffset != 0.0 { currentRealTimeOffset = 0.0 }
            
            let deltaTicks = UInt32(round((deltaAdvanceRealTime * ticksPerSecond) / 1000.0))
            let deltaTime: MIDIFileEvent.DeltaTime = .ticks(deltaTicks)
            
            // do some self-validation to see if the event converts back into the same timecode as
            // the marker's input timecode
            var debugMarkerRealTime = originRealTimeOffset
            debugMarkerRealTime += (startTimecode.realTimeValue * 1000)
            debugMarkerRealTime += realTimePosition
            debugMarkerRealTime += deltaAdvanceRealTime
            
            if let debugRoundTripTC = try? Timecode(
                .realTime(seconds: debugMarkerRealTime / 1000.0),
                at: frameRate,
                limit: .max24Hours
            ),
               markerTimecode.stringValue(format: [.showSubFrames])
                != debugRoundTripTC.stringValue(format: [.showSubFrames])
            {
                let errorString = "Warning: Marker origin "
                    + markerTimecode.stringValue(format: [.showSubFrames])
                    + " -> "
                    + debugRoundTripTC.stringValue(format: [.showSubFrames])
                    + " read back from real time position."
                buildMessages.append(errorString)
            }
            
            // add marker event, and optionally include comment
            var markerName = marker.name
            
            if includeComments,
               let commentString = marker.comment
            {
                markerName.append(" - \(commentString)")
            }
            
            let newMarker = MIDIFileEvent.Text(
                type: .marker,
                string: markerName
            )
            
            track.events.append(newMarker.smfWrappedEvent(delta: deltaTime))
            
            // update running position
            framePosition += deltaAdvanceFrames
            realTimePosition += deltaAdvanceRealTime
            tickPosition += deltaTicks
            
            return buildMessages
        }
    }
}
