//
//  TrackArchive Parse.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

extension Cubase.TrackArchive {
    internal static func parse(xml: XMLDocument) throws -> (
        trackArchive: Self,
        messages: [ParseMessage]
    ) {
        guard let root = xml.rootElement() else {
            throw ParseError.general(
                "Could not read root XML element."
            )
        }
        
        return Self.parse(xml: root)
    }
    
    internal static func parse(xml root: XMLElement) -> (
        trackArchive: Self,
        messages: [ParseMessage]
    ) {
        var messages: [ParseMessage] = []
        
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        var info = Self()
        
        info._parseSetup(root: root, messages: &messages)
        info._parseTempoTrack(root: root, messages: &messages)
        info._parseTracks(root: root, messages: &messages)
        
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
        
        guard let setup = root.children?
            .filter(nameAttribute: "Setup")
            .first
        else {
            addParseMessage(
                .error(
                    "Could not extract global session information. Setup block could not be located."
                )
            )
            return
        }
        
        // frame rate
        if let fRate = setup.children?
            .filter(nameAttribute: "FrameType")
            .first?
            .attributeStringValue(forName: "value")?
            .int
        {
            if let fr = Self.frameRateTable[fRate] { main.frameRate = fr }
        }
        
        // start time
        if let dbl = setup.children?
            .filter(nameAttribute: "Start")
            .first?
            .children?
            .filter(nameAttribute: "Time")
            .first?
            .attributeStringValue(forName: "value")?
            .double
        {
            main.startTimeSeconds = dbl
        }
        
        main.startTimecode = calculateStartTimecode(ofRealTimeValue: 0.0)
        
        // length
        if let dbl = setup.children?
            .filter(nameAttribute: "Length")
            .first?
            .children?
            .filter(nameAttribute: "Time")
            .first?
            .attributeStringValue(forName: "value")?
            .double
        {
            main.lengthTimecode = calculateLengthTimecode(ofRealTimeValue: dbl)
        }
        
        // TimeType - not implemented yet
        
        // bar offset
        main.barOffset = setup.children?
            .filter(nameAttribute: "BarOffset")
            .first?
            .attributeStringValue(forName: "value")?
            .int
        
        // sample rate
        main.sampleRate = setup.children?
            .filter(nameAttribute: "SampleRate")
            .first?
            .attributeStringValue(forName: "value")?
            .double
        
        // bit depth
        main.bitDepth = setup.children?
            .filter(nameAttribute: "SampleSize")
            .first?
            .attributeStringValue(forName: "value")?
            .int
        
        // 'SampleFormatSize' - not implemented yet
        
        // 'RecordFile' - not implemented yet
        
        // 'RecordFileType' ... - not implemented yet
        
        // 'PanLaw' - not implemented yet
        
        // 'VolumeMax' - not implemented yet
        
        // 'HmtType' - not implemented yet
        
        // 'HmtDepth'
        main.hmtDepth = setup.children?
            .filter(nameAttribute: "HmtDepth")
            .first?
            .attributeStringValue(forName: "value")?
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
        
        // operating under the assumption (as anecdotally observed) that tempo track events are inserted into the first track of the XML file regardless of what that track type was; Cubase does not export the tempo track as a separate track in the XML as you might expect.
        
        guard let firstTrack = root.children?
            .filter(nameAttribute: "track")
            .first?
            .children?
            .first
        else {
            addParseMessage(
                .error(
                    "Could not extract tempo information. First track could not be located."
                )
            )
            return
        }
        
        let eventTree = firstTrack.children?
            .filter(classAttribute: "MListNode")
            .filter(nameAttribute: "Node")
            .first
        
        let domain = eventTree?.children?
            .filter(elementName: "member")
            .filter(nameAttribute: "Domain")
            .first
        
        let getTempoTrack = domain?.children?
            .filter(classAttribute: "MTempoTrackEvent")
            .filter(nameAttribute: "Tempo Track")
            .first
        
        // match both type and name
        let getTempoEvents = getTempoTrack?.children?
            .filter(elementName: "list")
            .filter(nameAttribute: "TempoEvent")
            .first
        
        // FYI: contains tempo events as well as other meta-data keys
        for event in getTempoEvents?.children ?? [] {
            if event.attributeStringValue(forName: "class") == "MTempoEvent" {
                let bpm = event.children?
                    .filter(nameAttribute: "BPM")
                    .first?
                    .attributeStringValue(forName: "value")?
                    .double
                
                let ppq = event.children?
                    .filter(nameAttribute: "PPQ")
                    .first?
                    .attributeStringValue(forName: "value")?
                    .double
                
                // if int "func" with value 1 exists, then it's a ramp
                // if the key doesn't exist, it's a jump (default)
                let type: TempoTrack.Event.TempoEventType = event.children?
                    .filter(nameAttribute: "Func")
                    .first?
                    .attributeStringValue(forName: "value")?
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
        
        guard let tracks = root.children?
            .filter(elementName: "list")
            .filter(nameAttribute: "track")
            .first?
            .children
        else {
            addParseMessage(.info("No tracks found."))
            return
        }
        
        // init property if nil
        if self.tracks == nil { self.tracks = [] }
        
        for track in tracks {
            // get track type
            
            let trackType = Self.TrackTypeTable[track.attributeStringValue(forName: "class") ?? ""]
            
            // create new track object
            
            switch trackType {
            case is MarkerTrack.Type:
                _parseTracks_MarkerTrack(track: track, messages: &messages)
                
            default:
                let newTrack = OrphanTrack(
                    rawXMLContent: track
                        .xmlString(options: .nodePrettyPrint)
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
        
        // find list by matching both its name and class name
        let eventTree = track.children?
            .filter(nameAttribute: "Node")
            .filter(classAttribute: "MListNode")
            .first
        
        let trackDomain: TrackTimeDomain
        
        switch eventTree?.children?
            .filter(nameAttribute: "Domain")
            .first?
            .children?
            .filter(nameAttribute: "Type")
            .first?
            .attributeStringValue(forName: "value")?
            .int
        {
        case 0?: trackDomain = .musical
        case 1?: trackDomain = .linear
        default: return
        }
        
        // track name
        newTrack.name = eventTree?.children?
            .filter(nameAttribute: "Name")
            .first?
            .attributeStringValue(forName: "value")
        
        // track events
        guard let events = eventTree?.children?
            .filter(nameAttribute: "Events")
            .first?
            .children
        else { return }
        
        for event in events {
            switch event.attributeStringValue(forName: "class") {
            case "MMarkerEvent", "MRangeMarkerEvent": // all marker event types
                
                var newMarker: CubaseTrackArchiveMarker?
                
                var name: String?
                var tcStart: Timecode?
                var tcStartRealTime: TimeInterval?
                
                // marker name
                name = event.children?
                    .filter(nameAttribute: "Name")
                    .first?
                    .attributeStringValue(forName: "value")
                
                // start time
                if let str = event.children?
                    .filter(nameAttribute: "Start")
                    .first?
                    .attributeStringValue(forName: "value")
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
                
                switch event.attributeStringValue(forName: "class") {
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
                    if let str = event.children?
                        .filter(nameAttribute: "Length")
                        .first?
                        .attributeStringValue(forName: "value")
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
                addParseMessage(
                    .error("Unrecognized marker track event in XML: \(event.xmlString)")
                )
            }
        }
        
        tracks?.append(newTrack)
    }
}

#endif
