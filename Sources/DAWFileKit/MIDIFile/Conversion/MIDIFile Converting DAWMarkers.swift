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
    public init(
        converting markers: [DAWMarker],
        tempo inputTempo: Double,
        startTimecode: Timecode,
        includeComments: Bool,
        buildMessages messages: inout [String]
    ) throws {
        // ascertain frame rate - let's just grab it from the start timecode object (reasonably
        // assuming all timecode objects have the same framerate)
        
        let frameRate = startTimecode.frameRate
        let upperLimit = startTimecode.upperLimit
        let subFramesBase = startTimecode.subFramesBase
        
        // MARK: MIDI file header
        
        var midifile = MIDIFile()
        
        midifile.format = .singleTrack
        
        // MARK: Tempo validation and calculation
        
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
        let tempo = tempoEvent.bpmEncoded    // get our new adjusted tempo for calculation
        
        if inputTempo != tempo {
            messages.append(
                "Input tempo \(inputTempo)bpm resolves to \(tempo)bpm after encoding in a MIDI file. "
                + "Depending on variances in how DAWs interpret MIDI file tempos, after importing the MIDI file, markers may not exactly correspond to their timecodes in the DAW session. "
                + "Stable tempos for retaining the highest timing precision include: 30, 60, 120, 125, 150, 160, 192, 200, 240, 250 bpm."
            )
        }
        
        // MARK: Ticks per quarter-note
        
        // ticks per quarter-note resolution
        // calculate a multiple of the tempo for increased resolution/accuracy
        // 4_000 is a soft ceiling -- according to my tests, it's a safe maximum that can address at
        // least 24 hours up to 300 bpm and all frame rates
        
        // Pro Tools uses 9600
        // Cubase uses 480 by default but can be changed
        
        // this code DOES WORK but may not be necessary - in my tests, using 4_000 vs. calculated
        // ppq based on tempo made no practical difference
        //    var ppqCalculation = tempo
        //    repeat {
        //        // calculate highest power of 2
        //        ppqCalculation = ppqCalculation * 2
        //    } while ppqCalculation < 4_000
        //    midifile.midiFileTicksPerQuarter = UInt16(ppqCalculation)
        //
        //    logger.debug("constructMIDIFile(...): Calculated \(midifile.midiFileTicksPerQuarter)ppq based on tempo \(tempo)bpm.")
        
        let tpq: UInt16 = 9600
        
        midifile.timeBase = .musical(ticksPerQuarterNote: tpq) // set to static PPQ
        
        // let beatDurationInSeconds = (60.0 / tempo)
        //    let beatsPerSecond = (tempo / 60.0)
        //    let ticksPerSecond = beatsPerSecond * Double(midifile.midiFileTicksPerQuarter)
        
        let ticksPerSecond = (tempo / 60.0) * Double(tpq)
        
        // MARK: MIDI file track
        
        var midiTrack = MIDIFile.Chunk.Track()
        
        // MARK: MIDI file track - Track name
        
        midiTrack.events.append(
            .text(
                delta: .none,
                type: .trackOrSequenceName,
                string: "Markers"
            )
        )
        
        // MARK: MIDI file track - SMPTE offset (start time & frame rate)
        
        // Pro Tools will read SMPTE offset and set its session start time to that timecode
        // It doesn't interpret the frame rate from the MIDI file in a way that is expected
        // ie: MIDI file with 29.97d rate will make Pro Tools set its session frame rate to 30d
        // even though Pro Tools 2020.12.0 will write both 29.97d and 30d as 29.97d in a MIDI file
        // for some reason it decides 30d is a better candidate for importing the MIDI file...?
        // might be a PT bug because I can't imagine 30d is more useful/common
        
        midiTrack.events.append(.smpteOffset(delta: .none, scaling: startTimecode))
        
        // MARK: MIDI file track - Tempo event
        
        midiTrack.events.append(tempoEvent.smfWrappedEvent(delta: .none))
        
        // MARK: MIDI file Events
        
        var framePosition = startTimecode
        
        // origin time offset in ms
        // start with slight offset so markers fall at the start of a frame and not just prior to
        // it, with tolerance for the deltaTicks round() up or down that happens
        // based on our calculation method, some frame rates need a larger offset to overcome
        // potential +/- variances
        var currentRealTimeOffset: Double
        var originRealTimeOffset: Double
        
        var currentRealTimeOffset: Double = frameRate.frameDuration.doubleValue / 32
        let originRealTimeOffset: Double = frameRate.frameDuration.doubleValue / 32
        
        var realTimePosition = 0.0
        var tickPosition: UInt32 = 0
        
        for marker in markers {
            #warning(
                "> TODO: this may need to factor in marker's original session start timecode against the 'startTimecode' parameter passed into this function. should be an abstracted method that can convert/flatten a marker to a resolved timecode at a certain framerate and start time"
            )
            
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
            let deltaAdvanceRealTime = currentRealTimeOffset
                + ((markerTimecode - startTimecode).realTimeValue * 1000.0) // ms
                - ((framePosition - startTimecode).realTimeValue * 1000.0) // ms
            if currentRealTimeOffset !=
                0.0 { currentRealTimeOffset = 0.0 } // only use offset the for the first marker
            let deltaTicks = UInt32(round((deltaAdvanceRealTime * ticksPerSecond) / 1000.0))
            let deltaTime: MIDIFileEvent.DeltaTime = .ticks(deltaTicks)
            
            // do some self-validation to see if the event converts back into the same timecode as
            // the marker's input timecode
            let debugMarkerRealTime = originRealTimeOffset + (startTimecode.realTimeValue * 1000) +
                realTimePosition + deltaAdvanceRealTime
            
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
                messages.append(errorString)
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
            
            midiTrack.events.append(newMarker.smfWrappedEvent(delta: deltaTime))
            
            // update running position
            framePosition += deltaAdvanceFrames
            realTimePosition += deltaAdvanceRealTime
            tickPosition += deltaTicks
        }
        
        // add track to midi file
        
        midifile.chunks.append(.track(midiTrack))
        
        self = midifile
    }
}
