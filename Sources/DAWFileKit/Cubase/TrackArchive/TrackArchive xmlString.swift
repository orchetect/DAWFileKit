//
//  TrackArchive xmlString.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions
import TimecodeKitCore

extension Cubase.TrackArchive {
    // MARK: xmlString
    
    /// Returns Cubase XML file contents generated from the `TrackArchive` contents as a String.
    public func xmlString() throws -> (
        xmlString: String,
        messages: [EncodeMessage]
    ) {
        var messages: [EncodeMessage] = []
        
        func addEncodeMessage(_ msg: EncodeMessage) {
            messages.append(msg)
        }
        
        var idCounter = IDCounter()
        
        let xmlOptions: XMLNode.Options = [.nodePrettyPrint, .nodeCompactEmptyElement]
        
        // xml doc
        
        let xml = XMLDocument(kind: .document, options: xmlOptions)
        xml.version = "1.0"
        xml.characterEncoding = "utf-8"
        xml.setRootElement(XMLElement(name: "root"))
        
        // root
        
        guard let root = xml.rootElement() else {
            throw EncodeError.general(
                "Could not access root XML element."
            )
        }
        root.name = "tracklist2"
        
        // track list
        
        _addTrackListAndTempoEvents(root, idCounter: &idCounter, messages: &messages)
        
        // setup
        
        try _addSetup(root, idCounter: &idCounter, messages: &messages)
        
        // return data
        
        return (
            xmlString: xml.xmlString(options: xmlOptions),
            messages: messages
        )
    }
}

extension Cubase.TrackArchive {
    // MARK: _addSetup
    
    fileprivate func _addSetup(
        _ root: XMLElement,
        idCounter: inout IDCounter,
        messages: inout [EncodeMessage]
    ) throws {
        func addEncodeMessage(_ msg: EncodeMessage) {
            messages.append(msg)
        }
        
        let setupNode = XMLElement(
            name: "obj",
            attributes: [
                ("class", "PArrangeSetup"),
                ("name", "Setup"),
                ("ID", idCounter.getNewID().string)
            ]
        )
        
        // frame rate
        if let value = Self.frameRateTable
            .first(where: { $0.value == main.frameRate })?
            .key
        {
            setupNode.addChild(XMLElement(
                name: "int",
                attributes: [
                    ("name", "FrameType"),
                    ("value", value.string)
                ]
            ))
        }
        
        // start time
        if let stc = main.startTimecode {
            let startNode = XMLElement(
                name: "member",
                attributes: [("name", "Start")]
            )
            
            let value = stc.realTimeValue.stringValueHighPrecision
            
            startNode.addChild(XMLElement(
                name: "float",
                attributes: [
                    ("name", "Time"),
                    ("value", value)
                ]
            ))
            
            // TODO: instead of raw string, use a non-throwing method?
            startNode.addChild(
                try XMLElement(
                    xmlString: #"<member name="Domain"><int name="Type" value="1"/><float name="Period" value="1"/></member>"#
                )
            )
            
            setupNode.addChild(startNode)
        }
        
        // length
        if let ltc = main.lengthTimecode {
            let startNode = XMLElement(
                name: "member",
                attributes: [("name", "Length")]
            )
            
            let value = ltc.realTimeValue.string
            
            startNode.addChild(XMLElement(
                name: "float",
                attributes: [
                    ("name", "Time"),
                    ("value", value)
                ]
            ))
            
            // TODO: instead of raw string, use a non-throwing method?
            startNode.addChild(
                try XMLElement(
                    xmlString: #"<member name="Domain"><int name="Type" value="1"/><float name="Period" value="1"/></member>"#
                )
            )
            
            setupNode.addChild(startNode)
        }
        
        // TimeType - not implemented yet
        
        // bar offset
        if let value = main.barOffset {
            setupNode.addChild(XMLElement(
                name: "int",
                attributes: [
                    ("name", "BarOffset"),
                    ("value", value.string)
                ]
            ))
        }
        
        // sample rate
        if let value = main.sampleRate {
            setupNode.addChild(XMLElement(
                name: "float",
                attributes: [
                    ("name", "SampleRate"),
                    ("value", value.stringValueHighPrecision)
                ]
            ))
        }
        
        // bit depth
        if let value = main.bitDepth {
            setupNode.addChild(XMLElement(
                name: "int",
                attributes: [
                    ("name", "SampleSize"),
                    ("value", value.string)
                ]
            ))
        }
        
        // 'SampleFormatSize' - not implemented yet
        
        // 'RecordFile' - not implemented yet
        
        // 'RecordFileType' ... - not implemented yet
        
        // 'PanLaw' - not implemented yet
        
        // 'VolumeMax' - not implemented yet
        
        // 'HmtType' - not implemented yet
        
        // 'HmtDepth'
        if let value = main.hmtDepth {
            setupNode.addChild(XMLElement(
                name: "int",
                attributes: [
                    ("name", "HmtDepth"),
                    ("value", value.string)
                ]
            ))
        }
        
        root.addChild(setupNode)
    }
}

extension Cubase.TrackArchive {
    // MARK: _addTrackListAndTempoEvents
    
    fileprivate func _addTrackListAndTempoEvents(
        _ root: XMLElement,
        idCounter: inout IDCounter,
        messages: inout [EncodeMessage]
    ) {
        func addEncodeMessage(_ msg: EncodeMessage) {
            messages.append(msg)
        }
        
        let listNode = XMLElement(
            name: "list",
            attributes: [
                ("name", "track"),
                ("type", "obj")
            ]
        )
        
        #warning("> TODO: needs coding - add tracks and tempo events")
        
        for track in tracks ?? [] {
            let newTrack = XMLElement()
            
            // Flags
            // TODO: not sure what this value is for, but Cubase will refuse
            // to open the XML if it's absent
            newTrack.addChild(XMLElement(
                name: "int",
                attributes: [
                    ("name", "Flags"),
                    ("value", "1")
                ]
            ))
            
            // Start
            newTrack.addChild(XMLElement(
                name: "float",
                attributes: [
                    ("name", "Start"),
                    ("value", "0")
                ]
            ))
            
            // Length - needed?
            
            // MListNode
            let mlistNode = XMLElement(
                name: "obj",
                attributes: [
                    ("class", "MListNode"),
                    ("name", "Node"),
                    ("ID", idCounter.getNewID().string)
                ]
            )
            newTrack.addChild(mlistNode)
            
            // Track Name
            mlistNode.addChild(XMLElement(
                name: "string",
                attributes: [
                    ("name", "Name"),
                    ("value", track.name ?? "")
                ]
            ))
            
            // Time domain
            let Domain = XMLElement(
                name: "member",
                attributes: [("name", "Domain")]
            )
            Domain.addChild(XMLElement(
                name: "int",
                attributes: [
                    ("name", "Type"),
                    ("value", "1")
                ]
            ))
            Domain.addChild(XMLElement(
                name: "float",
                attributes: [
                    ("name", "Period"),
                    ("value", "1")
                ]
            ))
            mlistNode.addChild(Domain)
            
            // track-specific contents
            
            switch track {
            case let .marker(markerTrack):
                _addTrackMarker(
                    using: newTrack,
                    track: markerTrack,
                    idCounter: &idCounter,
                    messages: &messages
                )
                
            default:
                addEncodeMessage(
                    .error(
                        "Unhandled track type while building XML file for track named: \((track.name ?? "").quoted)"
                    )
                )
            }
            
            // Track Device
            // TODO: not sure what this value is for, but Cubase will refuse
            // to open the XML if it's absent
            let TrackDevice = XMLElement(
                name: "obj",
                attributes: [
                    ("class", "MTrack"),
                    ("name", "Track Device"),
                    ("ID", idCounter.getNewID().string)
                ]
            )
            TrackDevice.addChild(XMLElement(
                name: "int",
                attributes: [
                    ("name", "Connection Type"),
                    ("value", "2")
                ]
            ))
            newTrack.addChild(TrackDevice)
            
            listNode.addChild(newTrack)
        }
        
        root.addChild(listNode)
    }
    
    // MARK: _addTrackMarker
    
    @discardableResult
    fileprivate func _addTrackMarker(
        using newTrack: XMLElement,
        track: MarkerTrack,
        idCounter: inout IDCounter,
        messages: inout [EncodeMessage]
    ) -> XMLElement {
        func addEncodeMessage(_ msg: EncodeMessage) {
            messages.append(msg)
        }
        
        var staticMarkerIDCounter = 0
        var cycleMarkerIDCounter = 0
        
        newTrack.name = "obj"
        newTrack.addAttributes([
            ("class", "MMarkerTrackEvent"),
            ("ID", idCounter.getNewID().string)
        ])
        
        // MListNode
        let mlistNode = newTrack.childElements
            .filter(whereNodeNamed: "obj")
            .filter(whereAttribute: "class", hasValue: "MListNode")
            .first(whereAttribute: "name", hasValue: "Node")
        
        // MListNode.Events
        let eventsNode = XMLElement(
            name: "list",
            attributes: [
                ("name", "Events"),
                ("type", "obj")
            ]
        )
        
        for event in track.events {
            let newNode = XMLElement(name: "obj")
            
            // add length as real time if present, otherwise convert the
            // timecode object to real time
            if let eventStartRealTime = event.startRealTime {
                newNode.addChild(XMLElement(
                    name: "float",
                    attributes: [
                        ("name", "Start"),
                        (
                            "value",
                            eventStartRealTime
                                .stringValueHighPrecision
                        )
                    ]
                ))
            } else {
                let sessionStartTC = (main.startTimecode ?? Timecode(.zero, at: main.frameRate ?? event.startTimecode.frameRate))
                let eventTC = event.startTimecode
                let sortedTCs = [sessionStartTC, eventTC].sorted(timelineStart: sessionStartTC)
                let offsetTC = sortedTCs[0].interval(to: sortedTCs[1]).flattened()
                
                newNode.addChild(XMLElement(
                    name: "float",
                    attributes: [
                        ("name", "Start"),
                        (
                            "value",
                            offsetTC
                                .realTimeValue
                                .stringValueHighPrecision
                        )
                    ]
                ))
            }
            
            switch event {
            case .marker(_): // MMarkerEvent
                newNode.addAttribute(withName: "class", value: "MMarkerEvent")
                
            case let .cycleMarker(cycleMarker): // MRangeMarkerEvent
                newNode.addAttribute(withName: "class", value: "MRangeMarkerEvent")
                
                // add length as real time if present, otherwise convert the
                // timecode object to real time
                if let markerLengthRealTime = cycleMarker.lengthRealTime {
                    newNode.addChild(XMLElement(
                        name: "float",
                        attributes: [
                            ("name", "Length"),
                            (
                                "value",
                                markerLengthRealTime
                                    .stringValueHighPrecision
                            )
                        ]
                    ))
                } else {
                    newNode.addChild(XMLElement(
                        name: "float",
                        attributes: [
                            ("name", "Length"),
                            (
                                "value",
                                cycleMarker.lengthTimecode
                                    .realTimeValue
                                    .stringValueHighPrecision
                            )
                        ]
                    ))
                }
            }
            
            newNode.addChild(XMLElement(name: "string", attributes: [
                ("name", "Name"),
                ("value", event.name)
            ]))
            
            switch event {
            case .marker(_): // MMarkerEvent
                staticMarkerIDCounter += 1
                newNode.addChild(XMLElement(name: "int", attributes: [
                    ("name", "ID"),
                    (
                        "value",
                        staticMarkerIDCounter.string
                    )
                ]))
                
            case .cycleMarker(_): // MRangeMarkerEvent
                cycleMarkerIDCounter += 1
                newNode.addChild(XMLElement(name: "int", attributes: [
                    ("name", "ID"),
                    (
                        "value",
                        cycleMarkerIDCounter.string
                    )
                ]))
            }
            newNode.addAttribute(withName: "ID", value: idCounter.getNewID().string)
            
            eventsNode.addChild(newNode)
        }
        
        mlistNode?.addChild(eventsNode)
        
        return newTrack
    }
}

// MARK: - ID Counter

extension Cubase.TrackArchive {
    fileprivate struct IDCounter {
        var id = 0
        
        mutating func getNewID() -> Int {
            id += 1
            return id
        }
    }
}
#endif
