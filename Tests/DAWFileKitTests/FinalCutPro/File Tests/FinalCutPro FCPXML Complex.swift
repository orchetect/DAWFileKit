//
//  FinalCutPro FCPXML Complex.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_Complex: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "Complex",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    // MARK: Resources
    
    let r1 = FinalCutPro.FCPXML.Format(
        id: "r1",
        name: "FFVideoFormat1080p25",
        frameDuration: Fraction(100,2500),
        fieldOrder: nil,
        width: 1920,
        height: 1080,
        paspH: nil,
        paspV: nil,
        colorSpace: "1-1-1 (Rec. 709)",
        projection: nil,
        stereoscopic: nil
    )
    
    let r2MediaRep = FinalCutPro.FCPXML.MediaRep(
        kind: .originalMedia,
        sig: "53308E84E2E696489DF41ECEFBB51E41",
        src: URL(string: "file:///Volumes/Workspace/Dropbox/_coding/MarkersExtractor/FCP/Media/Nature%20Makes%20You%20Happy.mp4")!,
        bookmark: "Ym9va4wEAAAAAAQQMAAAAA9nZ86w8toDV1iRWhW7F3FnXf4R/JaQHTsjUwmr7RbnrAMAAAQAAAADAwAAABgAKAcAAAABAQAAVm9sdW1lcwAJAAAAAQEAAFdvcmtzcGFjZQAAAAcAAAABAQAARHJvcGJveAAHAAAAAQEAAF9jb2RpbmcAEAAAAAEBAABNYXJrZXJzRXh0cmFjdG9yAwAAAAEBAABGQ1AABQAAAAEBAABNZWRpYQAAABoAAAABAQAATmF0dXJlIE1ha2VzIFlvdSBIYXBweS5tcDQAACAAAAABBgAAEAAAACAAAAA0AAAARAAAAFQAAABsAAAAeAAAAIgAAAAIAAAABAMAACMAAAAAAAAACAAAAAQDAAACAAAAAAAAAAgAAAAEAwAA5AAAAAAAAAAIAAAABAMAAOgAAAAAAAAACAAAAAQDAADFTwEAAAAAAAgAAAAEAwAAdFABAAAAAAAIAAAABAMAAItQAQAAAAAACAAAAAQDAACYUwEAAAAAACAAAAABBgAA1AAAAOQAAAD0AAAABAEAABQBAAAkAQAANAEAAEQBAAAIAAAAAAQAAEHETWSSAAAAGAAAAAECAAABAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAAaAAAAAQkAAGZpbGU6Ly8vVm9sdW1lcy9Xb3Jrc3BhY2UvAAAIAAAABAMAAADAWtToAAAACAAAAAAEAABBxM4sX0BmzCQAAAABAQAANEExM0JFOTUtRjdGNi00QUVGLUI1M0QtRUI3QzgxRkRENThEGAAAAAECAAABAQAAAQAAAO8TAAABAAAAAAAAAAAAAAASAAAAAQEAAC9Wb2x1bWVzL1dvcmtzcGFjZQAACAAAAAEJAABmaWxlOi8vLwwAAAABAQAATWFjaW50b3NoIEhECAAAAAQDAAAA4AHj6AAAAAgAAAAABAAAQcV6LvQAAAAkAAAAAQEAADU2OEFFNUYxLTM4NTctNDNENC1CMjhDLTQ3MkVENUIzQzg2MBgAAAABAgAAgQAAAAEAAADvEwAAAQAAAAAAAAAAAAAAAQAAAAEBAAAvAAAAYAAAAP7///8A8AAAAAAAAAcAAAACIAAA6AIAAAAAAAAFIAAAWAIAAAAAAAAQIAAAaAIAAAAAAAARIAAAnAIAAAAAAAASIAAAfAIAAAAAAAATIAAAjAIAAAAAAAAgIAAAyAIAAAAAAAAEAAAAAwMAAADwAAAEAAAAAwMAAAAAAAAEAAAAAwMAAAEAAAAkAAAAAQYAAFwDAABoAwAAdAMAAGgDAABoAwAAaAMAAGgDAABoAwAAaAMAAKgAAAD+////AQAAAPQCAAANAAAABBAAAKwAAAAAAAAABRAAAFQBAAAAAAAAEBAAAIwBAAAAAAAAQBAAAHwBAAAAAAAAACAAAIADAAAAAAAAAiAAADwCAAAAAAAABSAAAKwBAAAAAAAAECAAACAAAAAAAAAAESAAAPABAAAAAAAAEiAAANABAAAAAAAAEyAAAOABAAAAAAAAICAAABwCAAAAAAAAENAAAAQAAAAAAAAA"
    )
    let r2MetadataXML = try! XMLElement(xmlString: """
        <metadata>
            <md key="com.apple.proapps.studio.rawToLogConversion" value="0"/>
            <md key="com.apple.proapps.spotlight.kMDItemProfileName" value="HD (1-1-1)"/>
            <md key="com.apple.proapps.studio.cameraISO" value="0"/>
            <md key="com.apple.proapps.studio.cameraColorTemperature" value="0"/>
            <md key="com.apple.proapps.spotlight.kMDItemCodecs">
                <array>
                    <string>'avc1'</string>
                    <string>MPEG-4 AAC</string>
                </array>
            </md>
            <md key="com.apple.proapps.mio.ingestDate" value="2022-12-25 22:06:44 -0800"/>
        </metadata>
        """
    )
    lazy var r2Metadata = FinalCutPro.FCPXML.Metadata(element: r2MetadataXML)
    lazy var r2 = FinalCutPro.FCPXML.Asset(
        id: "r2",
        name: "Nature Makes You Happy",
        start: .zero,
        duration: Fraction(142040,1000),
        format: "r1",
        uid: "53308E84E2E696489DF41ECEFBB51E41",
        hasAudio: true,
        hasVideo: true,
        audioSources: 1,
        audioChannels: 2,
        audioRate: .rate44_1kHz,
        videoSources: 1,
        auxVideoFlags: nil,
        mediaRep: r2MediaRep,
        metadata: r2Metadata
    )
    
    let r3MediaRep = FinalCutPro.FCPXML.MediaRep(
        kind: .originalMedia,
        sig: "7B6E7477652CFB3F66E2520EA95F18E2",
        src: URL(string: "file:///Volumes/Workspace/Dropbox/_coding/MarkersExtractor/FCP/Media/Interstellar%20Soundtrack%20-%20No%20Time%20for%20Caution.wav")!,
        bookmark: "Ym9va6QEAAAAAAQQMAAAAE6qgbBgG4byngsLQqoJGDtfjd2pAQE/Ck8H9jUa6XcAxAMAAAQAAAADAwAAABgAKAcAAAABAQAAVm9sdW1lcwAJAAAAAQEAAFdvcmtzcGFjZQAAAAcAAAABAQAARHJvcGJveAAHAAAAAQEAAF9jb2RpbmcAEAAAAAEBAABNYXJrZXJzRXh0cmFjdG9yAwAAAAEBAABGQ1AABQAAAAEBAABNZWRpYQAAADEAAAABAQAASW50ZXJzdGVsbGFyIFNvdW5kdHJhY2sgLSBObyBUaW1lIGZvciBDYXV0aW9uLndhdgAAACAAAAABBgAAEAAAACAAAAA0AAAARAAAAFQAAABsAAAAeAAAAIgAAAAIAAAABAMAACMAAAAAAAAACAAAAAQDAAACAAAAAAAAAAgAAAAEAwAA5AAAAAAAAAAIAAAABAMAAOgAAAAAAAAACAAAAAQDAADFTwEAAAAAAAgAAAAEAwAAdFABAAAAAAAIAAAABAMAAItQAQAAAAAACAAAAAQDAACZUwEAAAAAACAAAAABBgAA7AAAAPwAAAAMAQAAHAEAACwBAAA8AQAATAEAAFwBAAAIAAAAAAQAAEHEU1ZsAAAAGAAAAAECAAABAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAAaAAAAAQkAAGZpbGU6Ly8vVm9sdW1lcy9Xb3Jrc3BhY2UvAAAIAAAABAMAAADAWtToAAAACAAAAAAEAABBxM4sX0BmzCQAAAABAQAANEExM0JFOTUtRjdGNi00QUVGLUI1M0QtRUI3QzgxRkRENThEGAAAAAECAAABAQAAAQAAAO8TAAABAAAAAAAAAAAAAAASAAAAAQEAAC9Wb2x1bWVzL1dvcmtzcGFjZQAACAAAAAEJAABmaWxlOi8vLwwAAAABAQAATWFjaW50b3NoIEhECAAAAAQDAAAA4AHj6AAAAAgAAAAABAAAQcV6LvQAAAAkAAAAAQEAADU2OEFFNUYxLTM4NTctNDNENC1CMjhDLTQ3MkVENUIzQzg2MBgAAAABAgAAgQAAAAEAAADvEwAAAQAAAAAAAAAAAAAAAQAAAAEBAAAvAAAAYAAAAP7///8A8AAAAAAAAAcAAAACIAAAAAMAAAAAAAAFIAAAcAIAAAAAAAAQIAAAgAIAAAAAAAARIAAAtAIAAAAAAAASIAAAlAIAAAAAAAATIAAApAIAAAAAAAAgIAAA4AIAAAAAAAAEAAAAAwMAAADwAAAEAAAAAwMAAAAAAAAEAAAAAwMAAAEAAAAkAAAAAQYAAHQDAACAAwAAjAMAAIADAACAAwAAgAMAAIADAACAAwAAgAMAAKgAAAD+////AQAAAAwDAAANAAAABBAAAMQAAAAAAAAABRAAAGwBAAAAAAAAEBAAAKQBAAAAAAAAQBAAAJQBAAAAAAAAACAAAJgDAAAAAAAAAiAAAFQCAAAAAAAABSAAAMQBAAAAAAAAECAAACAAAAAAAAAAESAAAAgCAAAAAAAAEiAAAOgBAAAAAAAAEyAAAPgBAAAAAAAAICAAADQCAAAAAAAAENAAAAQAAAAAAAAA"
    )
    let r3MetadataXML = try! XMLElement(xmlString: """
        <metadata>
            <md key="com.apple.proapps.mio.ingestDate" value="2022-12-25 22:06:44 -0800"/>
        </metadata>
        """
    )
    lazy var r3Metadata = FinalCutPro.FCPXML.Metadata(element: r3MetadataXML)
    lazy var r3 = FinalCutPro.FCPXML.Asset(
        id: "r3",
        name: "Interstellar Soundtrack - No Time for Caution",
        start: .zero,
        duration: Fraction(10860590, 44100),
        format: nil,
        uid: "7B6E7477652CFB3F66E2520EA95F18E2",
        hasAudio: true,
        hasVideo: false,
        audioSources: 1,
        audioChannels: 2,
        audioRate: .rate44_1kHz,
        videoSources: 0,
        auxVideoFlags: nil,
        mediaRep: r3MediaRep,
        metadata: r3Metadata
    )
    
    let r4 = FinalCutPro.FCPXML.Format(
        id: "r4",
        name: "FFVideoFormatRateUndefined",
        frameDuration: nil,
        fieldOrder: nil,
        width: nil,
        height: nil,
        paspH: nil,
        paspV: nil,
        colorSpace: nil,
        projection: nil,
        stereoscopic: nil
    )
    
    let r5MediaRep = FinalCutPro.FCPXML.MediaRep(
        kind: .originalMedia,
        sig: "978BD3B254D68A6FA69E87D0D90544FD",
        src: URL(string: "file:///Volumes/Workspace/Dropbox/_coding/MarkersExtractor/FCP/Media/Is%20This%20The%20Land%20of%20Fire%20or%20Ice.mp4")!,
        bookmark: "Ym9va5QEAAAAAAQQMAAAAFVzgSnK8/ycBhhs90R/FSAWmWSsEtn07NRJDmX1V9MVtAMAAAQAAAADAwAAABgAKAcAAAABAQAAVm9sdW1lcwAJAAAAAQEAAFdvcmtzcGFjZQAAAAcAAAABAQAARHJvcGJveAAHAAAAAQEAAF9jb2RpbmcAEAAAAAEBAABNYXJrZXJzRXh0cmFjdG9yAwAAAAEBAABGQ1AABQAAAAEBAABNZWRpYQAAACMAAAABAQAASXMgVGhpcyBUaGUgTGFuZCBvZiBGaXJlIG9yIEljZS5tcDQAIAAAAAEGAAAQAAAAIAAAADQAAABEAAAAVAAAAGwAAAB4AAAAiAAAAAgAAAAEAwAAIwAAAAAAAAAIAAAABAMAAAIAAAAAAAAACAAAAAQDAADkAAAAAAAAAAgAAAAEAwAA6AAAAAAAAAAIAAAABAMAAMVPAQAAAAAACAAAAAQDAAB0UAEAAAAAAAgAAAAEAwAAi1ABAAAAAAAIAAAABAMAAJxTAQAAAAAAIAAAAAEGAADcAAAA7AAAAPwAAAAMAQAAHAEAACwBAAA8AQAATAEAAAgAAAAABAAAQcRNZNcAAAAYAAAAAQIAAAEAAAAAAAAADwAAAAAAAAAAAAAAAAAAABoAAAABCQAAZmlsZTovLy9Wb2x1bWVzL1dvcmtzcGFjZS8AAAgAAAAEAwAAAMBa1OgAAAAIAAAAAAQAAEHEzixfQGbMJAAAAAEBAAA0QTEzQkU5NS1GN0Y2LTRBRUYtQjUzRC1FQjdDODFGREQ1OEQYAAAAAQIAAAEBAAABAAAA7xMAAAEAAAAAAAAAAAAAABIAAAABAQAAL1ZvbHVtZXMvV29ya3NwYWNlAAAIAAAAAQkAAGZpbGU6Ly8vDAAAAAEBAABNYWNpbnRvc2ggSEQIAAAABAMAAADgAePoAAAACAAAAAAEAABBxXou9AAAACQAAAABAQAANTY4QUU1RjEtMzg1Ny00M0Q0LUIyOEMtNDcyRUQ1QjNDODYwGAAAAAECAACBAAAAAQAAAO8TAAABAAAAAAAAAAAAAAABAAAAAQEAAC8AAABgAAAA/v///wDwAAAAAAAABwAAAAIgAADwAgAAAAAAAAUgAABgAgAAAAAAABAgAABwAgAAAAAAABEgAACkAgAAAAAAABIgAACEAgAAAAAAABMgAACUAgAAAAAAACAgAADQAgAAAAAAAAQAAAADAwAAAPAAAAQAAAADAwAAAAAAAAQAAAADAwAAAQAAACQAAAABBgAAZAMAAHADAAB8AwAAcAMAAHADAABwAwAAcAMAAHADAABwAwAAqAAAAP7///8BAAAA/AIAAA0AAAAEEAAAtAAAAAAAAAAFEAAAXAEAAAAAAAAQEAAAlAEAAAAAAABAEAAAhAEAAAAAAAAAIAAAiAMAAAAAAAACIAAARAIAAAAAAAAFIAAAtAEAAAAAAAAQIAAAIAAAAAAAAAARIAAA+AEAAAAAAAASIAAA2AEAAAAAAAATIAAA6AEAAAAAAAAgIAAAJAIAAAAAAAAQ0AAABAAAAAAAAAA="
    )
    let r5MetadataXML = try! XMLElement(xmlString: """
        <metadata>
            <md key="com.apple.proapps.studio.rawToLogConversion" value="0"/>
            <md key="com.apple.proapps.spotlight.kMDItemProfileName" value="HD (1-1-1)"/>
            <md key="com.apple.proapps.studio.cameraISO" value="0"/>
            <md key="com.apple.proapps.studio.cameraColorTemperature" value="0"/>
            <md key="com.apple.proapps.spotlight.kMDItemCodecs">
                <array>
                    <string>'avc1'</string>
                    <string>MPEG-4 AAC</string>
                </array>
            </md>
            <md key="com.apple.proapps.mio.ingestDate" value="2022-12-25 22:06:44 -0800"/>
        </metadata>
        """
    )
    lazy var r5Metadata = FinalCutPro.FCPXML.Metadata(element: r5MetadataXML)
    lazy var r5 = FinalCutPro.FCPXML.Asset(
        id: "r5",
        name: "Is This The Land of Fire or Ice",
        start: .zero,
        duration: Fraction(205800, 1000),
        format: "r1",
        uid: "978BD3B254D68A6FA69E87D0D90544FD",
        hasAudio: true,
        hasVideo: true,
        audioSources: 1,
        audioChannels: 2,
        audioRate: .rate44_1kHz,
        videoSources: 1,
        auxVideoFlags: nil,
        mediaRep: r5MediaRep,
        metadata: r5Metadata
    )
    
    let r6 = FinalCutPro.FCPXML.Effect(
        id: "r6",
        name: "Basic Title",
        uid: ".../Titles.localized/Bumper:Opener.localized/Basic Title.localized/Basic Title.moti",
        src: nil
    )
    
    let r7 = FinalCutPro.FCPXML.Effect(
        id: "r7",
        name: "Clouds",
        uid: ".../Generators.localized/Backgrounds.localized/Clouds.localized/Clouds.motn",
        src: nil
    )
    
    lazy var resourcesCollection: [XMLElement] = [
        r1.element,
        r2.element,
        r3.element,
        r4.element,
        r5.element,
        r6.element,
        r7.element
    ]
    
    lazy var resources: XMLElement = {
        let r = XMLElement(name: "resources")
        resourcesCollection.forEach { r.addChild($0) }
        return r
    }()
    
    // MARK: Clip info
    
    struct ClipInfo: Equatable, Hashable, FCPXMLUtilities {
        var elementType: FinalCutPro.FCPXML.ElementType
        var name: String?
        var absoluteStart: Timecode?
        var duration: Timecode?
        var markerDuration: MarkerDuration
        
        static let nature = ClipInfo(
            elementType: .assetClip,
            name: "Nature Makes You Happy",
            absoluteStart: tc("00:00:00:00", .fps25),
            duration: tc("00:02:22:01", .fps25),
            markerDuration: .frame
        )
        
        static let land = ClipInfo(
            elementType: .assetClip,
            name: "Is This The Land of Fire or Ice",
            absoluteStart: tc("00:02:22:01", .fps25),
            duration: tc("00:03:25:20", .fps25),
            markerDuration: .frame
        )
        
        static let clouds = ClipInfo(
            elementType: .video,
            name: "Clouds",
            absoluteStart: tc("00:05:47:21", .fps25),
            duration: tc("00:01:40:03", .fps25),
            markerDuration: .frame
        )
        
        static let title1 = ClipInfo(
            elementType: .title,
            name: "Basic Title - Basic Title",
            absoluteStart: tc("00:03:09:15", .fps25),
            duration: tc("00:00:17:05", .fps25),
            markerDuration: .frame
        )
        
        static let title2 = ClipInfo(
            elementType: .title,
            name: "Basic Title 2 - Basic Title",
            absoluteStart: tc("00:03:32:08", .fps25),
            duration: tc("00:00:12:09", .fps25),
            markerDuration: .frame
        )
        
        static let audio1 = ClipInfo(
            elementType: .assetClip,
            name: "Interstellar Soundtrack - No Time for Caution",
            absoluteStart: tc("00:00:00:00", .fps25),
            duration: tc("00:04:06:06.63", .fps25),
            markerDuration: .audioSample
        )
        
        static let audio2 = ClipInfo(
            elementType: .assetClip,
            name: "Interstellar Soundtrack - No Time for Caution",
            absoluteStart: tc("00:03:56:09.52", .fps25),
            duration: tc("00:03:31:14.27", .fps25),
            markerDuration: .audioSample
        )
    }
    
    enum MarkerDuration {
        case frame
        case audioSample
        
        var duration: Timecode {
            switch self {
            case .frame: 
                return tc("00:00:00:01", .fps25)
            case .audioSample:
                // even though Final Cut Pro shows 44.1kHz as the audio sample rate for these clips,
                // the XML is using 48kHz as the rational fraction denominator to define the marker length
                return try! Timecode(.samples(1, sampleRate: 48000), at: .fps25, base: .max80SubFrames)
            }
        }
    }
    
    typealias MarkerDatum = (
        timecode: Timecode,
        name: String,
        note: String?,
        config: FinalCutPro.FCPXML.Marker.Configuration,
        clip: ClipInfo
        // inheritedRoles: [FinalCutPro.FCPXML.Role]
    )
    
    // TODO: test roles
    static let titlesRole = FinalCutPro.FCPXML.VideoRole(rawValue: "Titles")
    static let videoRole = FinalCutPro.FCPXML.VideoRole(rawValue: "Video")
    static let customRole = FinalCutPro.FCPXML.VideoRole(rawValue: "Sample Role.Sample Role-1")
    
    // swiftformat:options --maxwidth none
    static let markerData: [MarkerDatum] = [
        (tc("00:00:20:16.00", .fps25), "(To-Do) Penguin", "Note Test 1", .toDo(completed: false), .nature),
        (tc("00:00:25:05.00", .fps25), "(Standard) Flamingo Bird", "Colour Fix", .standard, .nature),
        (tc("00:00:35:23.00", .fps25), "Chapter 1", "Note Test 2", .chapter(posterOffset: fraction(frames: 11, .fps25)), .nature),
        (tc("00:00:55:00.00", .fps25), "(To-Do) Red Crabs", "Note Test 3", .toDo(completed: false), .nature),
        (tc("00:01:17:20.00", .fps25), "(To-Do) Giraffe", "Note Test 4", .toDo(completed: false), .nature),
        (tc("00:01:33:10.35", .fps25), "Marker on Audio", "Audio Fix", .standard, .audio1),
        (tc("00:01:44:16.00", .fps25), "(Standard) Mountains", "VFX Shot", .standard, .nature),
        (tc("00:01:57:02.00", .fps25), "(Completed) Frog Jump", "Note Test 5", .toDo(completed: true), .nature),
        (tc("00:02:29:00.00", .fps25), "It is necessary", nil, .toDo(completed: false), .audio1),
        (tc("00:02:39:17.00", .fps25), "(To-Do) Red Giant", "Note Test 6", .toDo(completed: false), .land),
        (tc("00:02:53:23.29", .fps25), "Cooper!", nil, .toDo(completed: true), .audio1),
        (tc("00:03:03:14.00", .fps25), "(Standard) Kepler-36", "Explosion Shot", .standard, .land),
        (tc("00:03:12:20.00", .fps25), "Marker on Title 1", nil, .standard, .title1),
        (tc("00:03:22:10.00", .fps25), "Marker on Title 2", nil, .toDo(completed: false), .title1),
        (tc("00:03:32:08.00", .fps25), "Chapter 7", nil, .chapter(posterOffset: Fraction(11, 60)), .audio1),
        (tc("00:03:35:13.00", .fps25), "Marker on Title", nil, .toDo(completed: true), .title2),
        (tc("00:03:40:07.00", .fps25), "Chapter 5", nil, .chapter(posterOffset: fraction(frames: 11, .fps25)), .title2),
        (tc("00:03:45:03.00", .fps25), "Marker on Title Out of Bounds", nil, .toDo(completed: false), .title2),
        (tc("00:03:48:16.00", .fps25), "(Standard) Surface Temperatures", "Too Bright", .standard, .land),
        (tc("00:04:12:15.00", .fps25), "(Completed) Lava", "Nice Lava", .toDo(completed: true), .land),
        (tc("00:04:29:03.23", .fps25), "Sound FX 1", nil, .standard, .audio2),
        (tc("00:04:49:11.00", .fps25), "Chapter 2", "Note Test 7", .chapter(posterOffset: fraction(frames: 11, .fps25)), .land),
        (tc("00:05:13:16.00", .fps25), "Chapter 3", "Note Test 8", .chapter(posterOffset: fraction(frames: 11, .fps25)), .land),
        (tc("00:05:24:18.35", .fps25), "Sound FX 2", nil, .toDo(completed: false), .audio2),
        (tc("00:06:02:02.00", .fps25), "Cloud 1", nil, .standard, .clouds),
        (tc("00:06:15:11.20", .fps25), "SFX Completed", nil, .toDo(completed: true), .audio2),
        (tc("00:06:28:08.00", .fps25), "Cloud 2", nil, .toDo(completed: false), .clouds),
        (tc("00:06:39:00.53", .fps25), "Chapter 8", nil, .chapter(posterOffset: Fraction(11, 60)), .audio2),
        (tc("00:06:48:09.00", .fps25), "Cloud 3", nil, .toDo(completed: true), .clouds),
        (tc("00:07:08:20.00", .fps25), "Chapter 6", nil, .chapter(posterOffset: fraction(frames: 11, .fps25)), .clouds)
    ]
    // swiftformat:options --maxwidth 100
    
    // MARK: - Tests
    
//    func testParse() throws {
//        // load file
//        
//        let rawData = try fileContents
//        
//        // parse file
//        
//        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
//        
//        // version
//        
//        XCTAssertEqual(fcpxml.version, .ver1_11)
//        
//        // resources
//        
//        let resources = fcpxml.resources()
//        
//        XCTAssertEqual(resources.count, 7)
//        
//        XCTAssertEqual(resources["r1"], .format(r1))
//        
//        XCTAssertEqual(resources["r2"], .asset(r2))
//        
//        XCTAssertEqual(resources["r3"], .asset(r3))
//        
//        XCTAssertEqual(resources["r4"], .format(r4))
//        
//        XCTAssertEqual(resources["r5"], .asset(r5))
//        
//        XCTAssertEqual(resources["r6"], .effect(r6))
//        
//        XCTAssertEqual(resources["r7"], .effect(r7))
//        
//        // library
//        
//        let library = try XCTUnwrap(fcpxml.library())
//        
//        let libraryURL = URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/")
//        XCTAssertEqual(library.location, libraryURL)
//        
//        // events
//        
//        let events = fcpxml.allEvents()
//        XCTAssertEqual(events.count, 1)
//        
//        let event = try XCTUnwrap(events.first)
//        XCTAssertEqual(event.name, "Example A")
//        
//        // projects
//        
//        let projects = event.projects
//        XCTAssertEqual(projects.count, 1)
//        
//        let project = try XCTUnwrap(projects.first)
//        XCTAssertEqual(project.name, "Marker Data Demo_V2")
//        XCTAssertEqual(project.startTimecode, Self.tc("00:00:00:00", .fps25))
//        
//        // sequence
//        
//        let sequence = project.sequence
//        XCTAssertEqual(sequence.formatID, "r1")
//        XCTAssertEqual(sequence.startTimecode, Self.tc("00:00:00:00", .fps25))
//        XCTAssertEqual(sequence.startTimecode?.frameRate, .fps25)
//        XCTAssertEqual(sequence.startTimecode?.subFramesBase, .max80SubFrames)
//        XCTAssertEqual(sequence.duration, Self.tc("00:07:27:24", .fps25))
//        XCTAssertEqual(sequence.audioLayout, .stereo)
//        XCTAssertEqual(sequence.audioRate, .rate48kHz)
//        
//        // story elements (clips etc.)
//        
//        let spine = sequence.spine
//        XCTAssertEqual(spine.contents.count, 3)
//                
//        guard case let .anyClip(.assetClip(element1)) = spine.contents[0] 
//        else { XCTFail("Clip was not expected type.") ; return }
//        XCTAssertEqual(element1.ref, "r2")
//        XCTAssertEqual(element1.offset, Self.tc("00:00:00:00", .fps25))
//        XCTAssertEqual(element1.offset?.frameRate, .fps25)
//        XCTAssertEqual(element1.name, "Nature Makes You Happy")
//        XCTAssertEqual(element1.start, nil)
//        XCTAssertEqual(element1.duration, Self.tc("00:02:22:01", .fps25))
//        XCTAssertEqual(element1.duration?.frameRate, .fps25)
//        XCTAssertEqual(element1.audioRole?.rawValue, "dialogue")
//        
//        guard case let .anyClip(.assetClip(element2)) = spine.contents[1] 
//        else { XCTFail("Clip was not expected type.") ; return }
//        XCTAssertEqual(element2.ref, "r5")
//        XCTAssertEqual(element2.offset, Self.tc("00:02:22:01", .fps25))
//        XCTAssertEqual(element2.offset?.frameRate, .fps25)
//        XCTAssertEqual(element2.name, "Is This The Land of Fire or Ice")
//        XCTAssertEqual(element2.start, nil)
//        XCTAssertEqual(element2.duration, Self.tc("00:03:25:20", .fps25))
//        XCTAssertEqual(element2.duration?.frameRate, .fps25)
//        XCTAssertEqual(element2.audioRole?.rawValue, "dialogue")
//        
//        guard case let .anyClip(.video(element3)) = spine.contents[2] 
//        else { XCTFail("Clip was not expected type.") ; return }
//        XCTAssertEqual(element3.ref, "r7")
//        XCTAssertEqual(element3.offset, Self.tc("00:05:47:21", .fps25))
//        XCTAssertEqual(element3.offset?.frameRate, .fps25)
//        XCTAssertEqual(element3.start, Self.tc("01:00:00:00", .fps25))
//        XCTAssertEqual(element3.start?.frameRate, .fps25)
//        XCTAssertEqual(element3.duration, Self.tc("00:01:40:03", .fps25))
//        XCTAssertEqual(element3.duration?.frameRate, .fps25)
//        XCTAssertEqual(element3.role?.rawValue, "Sample Role.Sample Role-1")
//        
//        // markers
//        
//        let element1Markers = element1.contents.annotations().markers()
//        XCTAssertEqual(element1Markers.count, 7)
//        
//        let expectedE1Marker0 = FinalCutPro.FCPXML.Marker(
//            start: Self.tc("00:00:20:16", .fps25),
//            duration: Self.tc("00:00:00:01", .fps25),
//            name: "(To-Do) Penguin",
//            metaData: .toDo(completed: false),
//            note: "Note Test 1"
//        )
//        XCTAssertEqual(element1Markers[safe: 0], expectedE1Marker0)
//        
//        
//        
//        let element2Markers = element2.contents.annotations().markers()
//        XCTAssertEqual(element2Markers.count, 6) // shallow at clip level, there are more in nested title clips
//        
//        
//        
//        
//        let element3Markers = element3.contents.annotations().markers()
//        XCTAssertEqual(element3Markers.count, 4)
//        
//        
//        
//        #warning("> TODO: finish writing unit test")
//    }
    
    func testExtractMarkers() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event.extract(preset: .markers, scope: .deep())
        XCTAssertEqual(extractedMarkers.count, Self.markerData.count)
        
        // print(debugString(for: extractedMarkers))
        
        // compare markers
        for md in Self.markerData {
            guard let em = extractedMarkers.first(where: { $0.element.fcpAsMarker?.name == md.name })
            else {
                let tcString = md.timecode.stringValue(format: [.showSubFrames])
                let nameString = md.name.quoted
                XCTFail("Marker not extracted: \(tcString) \(nameString)")
                continue
            }
            XCTAssertEqual(em.name, md.name, md.name)
            XCTAssertEqual(em.configuration, md.config, md.name)
            XCTAssertEqual(em.note, md.note, md.name)
            XCTAssertEqual(em.duration(), md.clip.markerDuration.duration, md.name)
            
            XCTAssertEqual(em.value(forContext: .absoluteStartAsTimecode()), md.timecode, md.name)
            XCTAssertEqual(em.value(forContext: .parentType), md.clip.elementType, md.name)
            XCTAssertEqual(em.value(forContext: .parentName), md.clip.name, md.name)
            XCTAssertEqual(em.value(forContext: .parentAbsoluteStartAsTimecode()), md.clip.absoluteStart, md.name)
            XCTAssertEqual(em.value(forContext: .parentDurationAsTimecode()), md.clip.duration, md.name)
            
            XCTAssertEqual(em.value(forContext: .ancestorEventName), "Example A")
            XCTAssertEqual(em.value(forContext: .ancestorProjectName), "Marker Data Demo_V2")
            
            // `marker` can't contain roles
            XCTAssertEqual(em.value(forContext: .localRoles), [])
            // every marker should have a role inherited from an ancestor
            XCTAssertNotEqual(em.value(forContext: .inheritedRoles), [])
            
            // print(extractedMarker.name, extractedMarker.context[.ancestorsRoles] ?? [])
        }
        
        #warning("> TODO: finish writing unit test")
    }
}

extension FinalCutPro_FCPXML_Complex {
    // MARK: Helpers
    
    private func bareSequence(children: [XMLElement] = []) -> XMLElement {
        let xml = try! XMLElement(xmlString: """
            <sequence format="r1" duration="1119900/2500s" tcStart="0s" tcFormat="NDF" audioLayout="stereo" audioRate="48k">
            </sequence>
            """
        )
        xml.setChildren(children)
        return xml
    }
    
    private func bareSpine(children: [XMLElement] = []) -> XMLElement {
        let xml = try! XMLElement(xmlString: """
            <spine>
            </spine>
            """
        )
        xml.setChildren(children)
        return xml
    }
    
    // MARK: Shallow Asset Clip Tests
    
    func testParseFormat_AssetClip() throws {
        // test data
        let clip = try XMLElement(xmlString: """
            <asset-clip ref="r2" offset="0s" name="Nature Makes You Happy" duration="355100/2500s" tcFormat="NDF" audioRole="dialogue">
            </asset-clip>
            """
        )
        let spine = bareSpine(children: [clip])
        let sequence = bareSequence(children: [spine])
        
        // asset clip's ref r2 is an asset resource which in turn uses format r1
        XCTAssertEqual(clip._fcpFirstFormatResourceForElementOrAncestors(in: resources), r1)
        
        // sequence links directly to format r1
        XCTAssertEqual(sequence._fcpFirstFormatResourceForElementOrAncestors(in: resources), r1)
    }
    
    func testParseFormat_AssetClip_Isolated() throws {
        // test data
        let clip = try XMLElement(xmlString: """
            <asset-clip ref="r2" offset="0s" name="Nature Makes You Happy" duration="355100/2500s" tcFormat="NDF" audioRole="dialogue">
            </asset-clip>
            """
        )
        
        // asset clip's ref r2 is an asset resource which in turn uses format r1, and asset clip contains its own tcFormat
        XCTAssertEqual(clip._fcpFirstFormatResourceForElementOrAncestors(in: resources), r1)
    }
    
    // MARK: Deep Asset Clip Tests
    
    func testParseFormat_AssetClip_Deep() throws {
        // test data
        let innerClip = try XMLElement(xmlString: """
            <asset-clip ref="r3" lane="-1" offset="0s" name="Interstellar Soundtrack - No Time for Caution" duration="177315755/720000s" format="r4" audioRole="dialogue">
                <audio-channel-source srcCh="1, 2" role="music.music-1"/>
            </asset-clip>
            """
        )
        let outerClip = try XMLElement(xmlString: """
            <asset-clip ref="r2" offset="0s" name="Nature Makes You Happy" duration="355100/2500s" tcFormat="NDF" audioRole="dialogue">
                <audio-channel-source srcCh="1, 2" role="dialogue.dialogue-1"/>
            </asset-clip>
            """
        )
        outerClip.addChild(innerClip)
        let spine = bareSpine(children: [outerClip])
        let sequence = bareSequence(children: [spine])
        
        // format r4 is undefined.
        // ref r3 is an asset resource containing only audio. it does not have a format attribute.
        // to succeed, this would need to continue traversing ancestors when it encountered the undefined r4 format,
        // (which is what the `firstDefinedFormat()` method does).
        XCTAssertEqual(innerClip._fcpFirstFormatResourceForElementOrAncestors(in: resources), r4)
        
        // has no format attribute.
        // ref r2 is an asset resource containing video and audio. it has a format attribute with value "r1".
        XCTAssertEqual(outerClip._fcpFirstFormatResourceForElementOrAncestors(in: resources), r1)
        
        // sequence links directly to format r1
        XCTAssertEqual(sequence._fcpFirstFormatResourceForElementOrAncestors(in: resources), r1)
    }
    
    func testParseDefinedFormat_AssetClip_Deep() throws {
        // test data
        let innerClip = try XMLElement(xmlString: """
            <asset-clip ref="r3" lane="-1" offset="0s" name="Interstellar Soundtrack - No Time for Caution" duration="177315755/720000s" format="r4" audioRole="dialogue">
                <audio-channel-source srcCh="1, 2" role="music.music-1"/>
            </asset-clip>
            """
        )
        let outerClip = try XMLElement(xmlString: """
            <asset-clip ref="r2" offset="0s" name="Nature Makes You Happy" duration="355100/2500s" tcFormat="NDF" audioRole="dialogue">
                <audio-channel-source srcCh="1, 2" role="dialogue.dialogue-1"/>
            </asset-clip>
            """
        )
        outerClip.addChild(innerClip)
        let spine = bareSpine(children: [outerClip])
        let sequence = bareSequence(children: [spine])
        
        // format r4 is undefined.
        // ref r3 is an asset resource containing only audio. it does not have a format attribute.
        // this needs to continue traversing ancestors when it encountered the undefined r4 format.
        XCTAssertEqual(innerClip._fcpFirstDefinedFormatResourceForElementOrAncestors(in: resources), r1)
        
        // has no format attribute.
        // ref r2 is an asset resource containing video and audio. it has a format attribute with value "r1".
        XCTAssertEqual(outerClip._fcpFirstDefinedFormatResourceForElementOrAncestors(in: resources), r1)
        
        // sequence links directly to format r1
        XCTAssertEqual(sequence._fcpFirstDefinedFormatResourceForElementOrAncestors(in: resources), r1)
    }
    
    // MARK: Shallow Video Clip Tests
    
    func testParseFrameRate_VideoClip() throws {
        // test data
        let clip = try XMLElement(xmlString: """
            <video ref="r7" offset="869600/2500s" name="Clouds" start="3600s" duration="250300/2500s" role="Sample Role.Sample Role-1">
            </video>
            """
        )
        let spine = bareSpine(children: [clip])
        let sequence = bareSequence(children: [spine])
        
        // video clip's ref r7 doesn't contain any info, so it needs to traverse ancestors to find r1 in sequence
        XCTAssertEqual(clip._fcpTimecodeFrameRate(in: resources), .fps25)
        
        XCTAssertEqual(sequence._fcpTimecodeFrameRate(in: resources), .fps25)
    }
    
    func testParseFrameRate_VideoClip_Isolated() throws {
        // test data
        let clip = try XMLElement(xmlString: """
            <video ref="r7" offset="869600/2500s" name="Clouds" start="3600s" duration="250300/2500s" role="Sample Role.Sample Role-1">
            </video>
            """
        )
        
        // video clip's ref r7 doesn't contain any info, so it needs to traverse ancestors to find r1 in sequence
        XCTAssertEqual(clip._fcpTimecodeFrameRate(in: resources), nil)
    }
    
    func testParseFormat_VideoClip() throws {
        // test data
        let clip = try XMLElement(xmlString: """
            <video ref="r7" offset="869600/2500s" name="Clouds" start="3600s" duration="250300/2500s" role="Sample Role.Sample Role-1">
            </video>
            """
        )
        let spine = bareSpine(children: [clip])
        let sequence = bareSequence(children: [spine])
        
        // video clip's ref r7 doesn't contain any info, so it needs to traverse ancestors to find r1 in sequence
        XCTAssertEqual(clip._fcpFirstFormatResourceForElementOrAncestors(in: resources), r1)
        
        // sequence links directly to format r1
        XCTAssertEqual(sequence._fcpFirstFormatResourceForElementOrAncestors(in: resources), r1)
    }
    
    func testParseTCFormat_VideoClip() throws {
        // test data
        let clip = try XMLElement(xmlString: """
            <video ref="r7" offset="869600/2500s" name="Clouds" start="3600s" duration="250300/2500s" role="Sample Role.Sample Role-1">
            </video>
            """
        )
        let spine = bareSpine(children: [clip])
        let sequence = bareSequence(children: [spine])
        
        XCTAssertEqual(clip._fcpTCFormatForElementOrAncestors(), .nonDropFrame)
        
        XCTAssertEqual(sequence._fcpTCFormatForElementOrAncestors(), .nonDropFrame)
    }
}

#endif
