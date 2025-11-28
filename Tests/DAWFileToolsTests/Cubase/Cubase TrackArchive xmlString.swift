//
//  Cubase TrackArchive xmlString.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import XCTest

class Cubase_TrackArchive_xmlString: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testXMLString_ZeroStartTime() throws {
        var trackArchive = Cubase.TrackArchive()
        
        // main
        trackArchive.main.startTimecode = Timecode(.zero, at: .fps24)
        trackArchive.main.frameRate = .fps24
        
        // markers
        var markerTrack = Cubase.TrackArchive.MarkerTrack()
        
        let marker1 = Cubase.TrackArchive.Marker(name: "Marker1", startTimecode: try Timecode(.components(f: 12), at: .fps24), startRealTime: nil)
        markerTrack.events.append(.marker(marker1))
        
        let marker2 = Cubase.TrackArchive.Marker(name: "Marker2", startTimecode: try Timecode(.components(s: 1), at: .fps24), startRealTime: nil)
        markerTrack.events.append(.marker(marker2))
        
        trackArchive.tracks = [.marker(markerTrack)]
        
        let (xmlString, messages) = try trackArchive.xmlString()
        
        // messages
        
        XCTAssertEqual(messages.errors.count, 0)
        if !messages.errors.isEmpty {
            dump(messages.errors)
        }
        
        let expectedXMLString = """
        <?xml version="1.0" encoding="utf-8"?>
        <tracklist2>
            <list name="track" type="obj">
                <obj class="MMarkerTrackEvent" ID="2">
                    <int name="Flags" value="1"/>
                    <float name="Start" value="0"/>
                    <obj class="MListNode" name="Node" ID="1">
                        <string name="Name" value=""/>
                        <member name="Domain">
                            <int name="Type" value="1"/>
                            <float name="Period" value="1"/>
                        </member>
                        <list name="Events" type="obj">
                            <obj class="MMarkerEvent" ID="3">
                                <float name="Start" value="0.5"/>
                                <string name="Name" value="Marker1"/>
                                <int name="ID" value="1"/>
                            </obj>
                            <obj class="MMarkerEvent" ID="4">
                                <float name="Start" value="1"/>
                                <string name="Name" value="Marker2"/>
                                <int name="ID" value="2"/>
                            </obj>
                        </list>
                    </obj>
                    <obj class="MTrack" name="Track Device" ID="5">
                        <int name="Connection Type" value="2"/>
                    </obj>
                </obj>
            </list>
            <obj class="PArrangeSetup" name="Setup" ID="6">
                <int name="FrameType" value="2"/>
                <member name="Start">
                    <float name="Time" value="0"/>
                    <member name="Domain">
                        <int name="Type" value="1"/>
                        <float name="Period" value="1"/>
                    </member>
                </member>
            </obj>
        </tracklist2>
        """
        
        XCTAssertEqual(xmlString, expectedXMLString)
    }
    
    func testXMLString_NonZeroStartTime() throws {
        var trackArchive = Cubase.TrackArchive()
        
        // main
        trackArchive.main.startTimecode = try Timecode(.components(h: 23, m: 00, s: 00, f: 00), at: .fps24)
        trackArchive.main.frameRate = .fps24
        
        // markers
        var markerTrack = Cubase.TrackArchive.MarkerTrack()
        
        let marker1 = Cubase.TrackArchive.Marker(name: "Marker1", startTimecode: try Timecode(.components(h: 23, s: 1), at: .fps24), startRealTime: nil)
        markerTrack.events.append(.marker(marker1))
        
        let marker2 = Cubase.TrackArchive.Marker(name: "Marker2", startTimecode: try Timecode(.components(h: 00), at: .fps24), startRealTime: nil)
        markerTrack.events.append(.marker(marker2))
        
        let marker3 = Cubase.TrackArchive.Marker(name: "Marker3", startTimecode: try Timecode(.components(h: 00, s: 1), at: .fps24), startRealTime: nil)
        markerTrack.events.append(.marker(marker3))
        
        trackArchive.tracks = [.marker(markerTrack)]
        
        let (xmlString, messages) = try trackArchive.xmlString()
        
        // messages
        
        XCTAssertEqual(messages.errors.count, 0)
        if !messages.errors.isEmpty {
            dump(messages.errors)
        }
        
        let expectedXMLString = """
        <?xml version="1.0" encoding="utf-8"?>
        <tracklist2>
            <list name="track" type="obj">
                <obj class="MMarkerTrackEvent" ID="2">
                    <int name="Flags" value="1"/>
                    <float name="Start" value="0"/>
                    <obj class="MListNode" name="Node" ID="1">
                        <string name="Name" value=""/>
                        <member name="Domain">
                            <int name="Type" value="1"/>
                            <float name="Period" value="1"/>
                        </member>
                        <list name="Events" type="obj">
                            <obj class="MMarkerEvent" ID="3">
                                <float name="Start" value="1"/>
                                <string name="Name" value="Marker1"/>
                                <int name="ID" value="1"/>
                            </obj>
                            <obj class="MMarkerEvent" ID="4">
                                <float name="Start" value="3600"/>
                                <string name="Name" value="Marker2"/>
                                <int name="ID" value="2"/>
                            </obj>
                            <obj class="MMarkerEvent" ID="5">
                                <float name="Start" value="3601"/>
                                <string name="Name" value="Marker3"/>
                                <int name="ID" value="3"/>
                            </obj>
                        </list>
                    </obj>
                    <obj class="MTrack" name="Track Device" ID="6">
                        <int name="Connection Type" value="2"/>
                    </obj>
                </obj>
            </list>
            <obj class="PArrangeSetup" name="Setup" ID="7">
                <int name="FrameType" value="2"/>
                <member name="Start">
                    <float name="Time" value="82800"/>
                    <member name="Domain">
                        <int name="Type" value="1"/>
                        <float name="Period" value="1"/>
                    </member>
                </member>
            </obj>
        </tracklist2>
        """
        
        XCTAssertEqual(xmlString, expectedXMLString)
    }
}

#endif
