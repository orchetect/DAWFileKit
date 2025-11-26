//
//  TrackArchive Parse.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions
import TimecodeKit

extension Cubase.TrackArchive {
    internal static func parse(fileContent xml: XMLDocument) throws -> (
        trackArchive: Self,
        messages: [ParseMessage]
    ) {
        guard let root = xml.rootElement() else {
            throw ParseError.general(
                "Could not read root XML element."
            )
        }
        
        return Self.parse(fileContent: root)
    }
    
    internal static func parse(fileContent xmlRoot: XMLElement) -> (
        trackArchive: Self,
        messages: [ParseMessage]
    ) {
        var messages: [ParseMessage] = []
        
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        var info = Self()
        
        info._parseSetup(root: xmlRoot, messages: &messages)
        info._parseTempoTrack(root: xmlRoot, messages: &messages)
        info._parseTracks(root: xmlRoot, messages: &messages)
        
        return (
            trackArchive: info,
            messages: messages
        )
    }
}

// MARK: - _parseSetup

extension Cubase.TrackArchive {
    private mutating func _parseSetup(
        root: XMLElement,
        messages: inout [ParseMessage]
    ) {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        // setup section
        
        guard let setup = root.childElements
            .first(whereNameAttributeValue: "Setup")
        else {
            addParseMessage(.error(
                "Could not extract global session information. Setup block could not be located."
            ))
            return
        }
        
        // frame rate
        if let fRate = setup.childElements
            .first(whereNameAttributeValue: "FrameType")?
            .stringValue(forAttributeNamed: "value")?
            .int
        {
            if let fr = Self.frameRateTable[fRate] { main.frameRate = fr }
        }
        
        // start time
        if let dbl = setup.childElements
            .first(whereNameAttributeValue: "Start")?.childElements
            .first(whereNameAttributeValue: "Time")?
            .stringValue(forAttributeNamed: "value")?
            .double
        {
            main.startTimeSeconds = dbl
        }
        
        main.startTimecode = calculateStartTimecode(ofRealTimeValue: 0.0)
        
        // length
        if let dbl = setup.childElements
            .first(whereNameAttributeValue: "Length")?.childElements
            .first(whereNameAttributeValue: "Time")?
            .stringValue(forAttributeNamed: "value")?
            .double
        {
            main.lengthTimecode = calculateLengthTimecode(ofRealTimeValue: dbl)
        }
        
        // TimeType - not implemented yet
        
        // bar offset
        main.barOffset = setup.childElements
            .first(whereNameAttributeValue: "BarOffset")?
            .stringValue(forAttributeNamed: "value")?
            .int
        
        // sample rate
        main.sampleRate = setup.childElements
            .first(whereNameAttributeValue: "SampleRate")?
            .stringValue(forAttributeNamed: "value")?
            .double
        
        // bit depth
        main.bitDepth = setup.childElements
            .first(whereNameAttributeValue: "SampleSize")?
            .stringValue(forAttributeNamed: "value")?
            .int
        
        // 'SampleFormatSize' - not implemented yet
        
        // 'RecordFile' - not implemented yet
        
        // 'RecordFileType' ... - not implemented yet
        
        // 'PanLaw' - not implemented yet
        
        // 'VolumeMax' - not implemented yet
        
        // 'HmtType' - not implemented yet
        
        // 'HmtDepth'
        main.hmtDepth = setup.childElements
            .first(whereNameAttributeValue: "HmtDepth")?
            .stringValue(forAttributeNamed: "value")?
            .int
    }
}

// MARK: - _parseTempoTrack

extension Cubase.TrackArchive {
    private mutating func _parseTempoTrack(
        root: XMLElement,
        messages: inout [ParseMessage]
    ) {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        // tempo track
        
        // operating under the assumption (as anecdotally observed) that tempo track events are
        // inserted into the first track of the XML file regardless of what that track type was;
        // Cubase does not export the tempo track as a separate track in the XML as you might
        // expect.
        
        guard let firstTrack = root.childElements
            .first(whereNameAttributeValue: "track")?
            .childElements
            .first
        else {
            addParseMessage(.error(
                "Could not extract tempo information. First track could not be located."
            ))
            return
        }
        
        let eventTree = firstTrack.childElements
            .filter(whereClassAttributeValue: "MListNode")
            .first(whereNameAttributeValue: "Node")
        
        let domain = eventTree?.childElements
            .filter(whereNodeNamed: "member")
            .first(whereNameAttributeValue: "Domain")
        
        let getTempoTrack = domain?.childElements
            .filter(whereClassAttributeValue: "MTempoTrackEvent")
            .first(whereNameAttributeValue: "Tempo Track")
        
        // match both type and name
        let getTempoEvents = getTempoTrack?.childElements
            .filter(whereNodeNamed: "list")
            .first(whereNameAttributeValue: "TempoEvent")
        
        if let getTempoEvents = getTempoEvents {
            // FYI: contains tempo events as well as other meta-data keys
            for event in getTempoEvents.childElements {
                guard event.stringValue(forAttributeNamed: "class") == "MTempoEvent" else { continue }
                let bpm: Double? = event.childElements
                    .first(whereNameAttributeValue: "BPM")?
                    .stringValue(forAttributeNamed: "value")?
                    .double
                
                let ppq: Double? = event.childElements
                    .first(whereNameAttributeValue: "PPQ")?
                    .stringValue(forAttributeNamed: "value")?
                    .double
                
                // if Int attribute "Func" with value of 1 exists, then it's a ramp
                // if the key doesn't exist, it's a jump (default)
                let type: TempoTrack.Event.TempoEventType = event.childElements
                    .first(whereNameAttributeValue: "Func")?
                    .stringValue(forAttributeNamed: "value")?
                    .int
                == 1 ? .ramp : .jump
                
                if let bpm = bpm, let ppq = ppq {
                    let newTempoEvent = TempoTrack.Event(
                        startTimeAsPPQ: ppq,
                        tempo: bpm,
                        type: type
                    )
                    tempoTrack.events.append(newTempoEvent)
                }
            }
        }
    }
}

// MARK: - _parseTracks

extension Cubase.TrackArchive {
    private mutating func _parseTracks(
        root: XMLElement,
        messages: inout [ParseMessage]
    ) {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        guard let tracks = root.childElements
            .filter(whereNodeNamed: "list")
            .first(whereNameAttributeValue: "track")?
            .childElements
        else {
            addParseMessage(.info("No tracks found."))
            return
        }
        
        // init property if nil
        if self.tracks == nil { self.tracks = [] }
        
        for track in tracks {
            // get track type
            
            let trackType = Self.trackTypeTable[track.stringValue(forAttributeNamed: "class") ?? ""]
            
            // create new track object
            
            // TODO: add additional track types in future
            
            switch trackType {
            case is MarkerTrack.Type:
                _parseTracks_MarkerTrack(track: track, messages: &messages)
                
            default:
                let newTrack = OrphanTrack(
                    rawXMLContent: track.xmlString(options: .nodePrettyPrint)
                )
                self.tracks?.append(newTrack)
            }
        }
    }
}

// MARK: - _parseTracks_MarkerTrack

extension Cubase.TrackArchive {
    private mutating func _parseTracks_MarkerTrack(
        track: XMLNode,
        messages: inout [ParseMessage]
    ) {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        var newTrack = MarkerTrack()
        
        // TODO: abstract common track metadata to a generic track parser, then specialize per track type for events
        
        // find list by matching both its name and class name
        let eventTree = track.childElements
            .filter(whereNameAttributeValue: "Node")
            .first(whereClassAttributeValue: "MListNode")
        
        let trackDomain: TrackTimeDomain
        
        switch eventTree?.childElements
            .first(whereNameAttributeValue: "Domain")?
            .childElements
            .first(whereNameAttributeValue: "Type")?
            .stringValue(forAttributeNamed: "value")?
            .int {
        case 0?: trackDomain = .musical
        case 1?: trackDomain = .linear
        default: return
        }
        
        // track name
        newTrack.name = eventTree?.childElements
            .first(whereNameAttributeValue: "Name")?
            .stringValue(forAttributeNamed: "value")
        
        // track events
        guard let events = eventTree?.childElements
            .first(whereNameAttributeValue: "Events")?
            .childElements
        else { return }
        
        for event in events {
            switch event.stringValue(forAttributeNamed: "class") {
            case "MMarkerEvent", "MRangeMarkerEvent": // all marker event types
                var newMarker: CubaseTrackArchiveMarker?
                
                var name: String?
                var tcStart: Timecode?
                var tcStartRealTime: TimeInterval?
                
                // marker name
                name = event.childElements
                    .first(whereNameAttributeValue: "Name")?
                    .stringValue(forAttributeNamed: "value")
                
                // start time
                if let str = event.childElements
                    .first(whereNameAttributeValue: "Start")?
                    .stringValue(forAttributeNamed: "value")
                {
                    if let toNum = str.double {
                        switch trackDomain {
                        case .musical:
                            tcStart = calculateStartTimecode(ofMusicalTimeValue: toNum)
                            
                        case .linear:
                            tcStart = calculateStartTimecode(ofRealTimeValue: toNum)
                            
                            // add real time value to the marker as well
                            tcStartRealTime = toNum
                        }
                    }
                }
                
                switch event.stringValue(forAttributeNamed: "class") {
                case "MMarkerEvent": // single marker
                    guard let tcStart = tcStart else { continue }
                    newMarker = Marker(
                        name: name ?? "",
                        startTimecode: tcStart,
                        startRealTime: tcStartRealTime
                    )
                    
                case "MRangeMarkerEvent": // cycle marker
                    var tcLength: Timecode?
                    var tcLengthRealTime: TimeInterval?
                    
                    // length time
                    if let str = event.childElements
                        .first(whereNameAttributeValue: "Length")?
                        .stringValue(forAttributeNamed: "value")
                    {
                        if let toNum = str.double {
                            switch trackDomain {
                            case .musical:
                                tcLength = calculateLengthTimecode(ofMusicalTimeValue: toNum)
                                
                            case .linear:
                                tcLength = calculateLengthTimecode(ofRealTimeValue: toNum)
                                
                                // add real time value to the marker as well
                                tcLengthRealTime = toNum
                            }
                        }
                    }
                    
                    guard let tcStart = tcStart,
                          let unwrappedTCLength = tcLength
                    else { continue }
                    
                    newMarker = CycleMarker(
                        name: name ?? "",
                        startTimecode: tcStart,
                        startRealTime: tcStartRealTime,
                        lengthTimecode: unwrappedTCLength,
                        lengthRealTime: tcLengthRealTime
                    )
                    
                default:
                    break
                }
                
                if let newMarker = newMarker { newTrack.events.append(newMarker) }
                
            default:
                addParseMessage(.error(
                    "Unrecognized marker track event in XML: \(event.xmlString)"
                ))
            }
        }
        
        tracks?.append(newTrack)
    }
}

#endif
