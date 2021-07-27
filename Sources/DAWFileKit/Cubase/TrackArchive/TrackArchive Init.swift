//
//  TrackArchive Init.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

// MARK: - Init

extension Cubase.TrackArchive {
    
    /// Input text file contents exported from Pro Tools and returns `SessionInfo`
    public init?(fromData: Data) {
        
        // load XML tree
        
        guard let loadxml = try? XMLDocument(data: fromData) else { return nil }
        guard let root = loadxml.rootElement() else { return nil }
        
        // struct construction
        
        var info = Self.init()
        
        info._parseSetup(root: root)
        
        info._parseTempoTrack(root: root)
        
        info._parseTracks(root: root)
        
        // return
        
        self = info
        
    }
    
}


// MARK: - _parseSetup

extension Cubase.TrackArchive {
    
    private mutating func _parseSetup(root: XMLElement) {
        
        // setup section
        
        guard let setup = root.children?
                .filter(nameAttribute: "Setup")
                .first
        else {
            Log.debug("Could not extract global session information. Setup block could not be located.")
            return
        }
        
        // frame rate
        if let fRate = setup.children?
            .filter(nameAttribute: "FrameType")
            .first?
            .attributeStringValue(forName: "value")?
            .int
        {
            if let fr = Self.FrameRateTable[fRate] { main.frameRate = fr }
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
        
        main.startTimecode = CalculateStartTimecode(ofRealTimeValue: 0.0)
        
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
            main.lengthTimecode = CalculateLengthTimecode(ofRealTimeValue: dbl)
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
        
        // SampleFormatSize - not implemented yet
        
        // RecordFile - not implemented yet
        
        // RecordFileType ... - not implemented yet
        
        // PanLaw - not implemented yet
        
        // VolumeMax - not implemented yet
        
        // HmtType - not implemented yet
        
        // HMTDepth
        main.HMTDepth = setup.children?
            .filter(nameAttribute: "HmtDepth")
            .first?
            .attributeStringValue(forName: "value")?
            .int
        
    }
    
}

// MARK: - _parseTempoTrack

extension Cubase.TrackArchive {
    
    private mutating func _parseTempoTrack(root: XMLElement) {
        
        // tempo track
        
        // operating under the assumption (as anecdotally observed) that tempo track events are inserted into the first track of the XML file regardless of what that track type was; Cubase does not export the tempo track as a separate track in the XML as you might expect.
        
        guard let firstTrack = root.children?
                .filter(nameAttribute: "track")
                .first?
                .children?
                .first
        else {
            Log.debug("Could not extract tempo information. First track could not be located.")
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
                
                if bpm != nil && ppq != nil {
                    let newTempoEvent = TempoTrack.Event(startTimeAsPPQ: ppq!,
                                                         tempo: bpm!,
                                                         type: type)
                    tempoTrack.events.append(newTempoEvent)
                }
                
            }
            
        }
        
    }
    
}

// MARK: - _parseTracks

extension Cubase.TrackArchive {
    
    private mutating func _parseTracks(root: XMLElement) {
        
        guard let tracks = root.children?
                .filter(elementName: "list")
                .filter(nameAttribute: "track")
                .first?
                .children
        else {
            Log.debug("No tracks found.")
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
                _parseTracks_MarkerTrack(track: track)
                
            default:
                let newTrack = OrphanTrack(rawXMLContent: track.xmlString(options: .nodePrettyPrint))
                self.tracks?.append(newTrack)
                
            }
            
        }
        
    }
    
}

// MARK: - _parseTracks_MarkerTrack

extension Cubase.TrackArchive {
    
    private mutating func _parseTracks_MarkerTrack(track: XMLNode) {
        
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
                            tcStart = CalculateStartTimecode(ofMusicalTimeValue: toNum)
                            
                        case .linear:
                            tcStart = CalculateStartTimecode(ofRealTimeValue: toNum)
                            
                            // add real time value to the marker as well
                            tcStartRealTime = toNum
                        }
                    }
                }
                
                switch event.attributeStringValue(forName: "class") {
                case "MMarkerEvent": // single marker
                    
                    guard tcStart != nil else { continue }
                    newMarker = Marker(name: name ?? "",
                                       startTimecode: tcStart!,
                                       startRealTime: tcStartRealTime)
                    
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
                                tcLength = CalculateLengthTimecode(ofMusicalTimeValue: toNum)
                                
                            case .linear:
                                tcLength = CalculateLengthTimecode(ofRealTimeValue: toNum)
                                
                                // add real time value to the marker as well
                                tcLengthRealTime = toNum
                            }
                        }
                    }
                    
                    guard tcLength != nil else { continue }
                    newMarker = CycleMarker(name: name ?? "",
                                            startTimecode: tcStart!,
                                            startRealTime: tcStartRealTime,
                                            lengthTimecode: tcLength!,
                                            lengthRealTime: tcLengthRealTime)
                    
                default: break
                }
                
                if newMarker != nil { newTrack.events.append(newMarker!) }
                
            default:
                Log.debug("Unrecognized marker track event in XML")
            }
            
        }
        
        self.tracks?.append(newTrack)
        
    }
    
}

#endif
