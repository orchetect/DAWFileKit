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

final class FinalCutPro_FCPXML_Complex: XCTestCase {
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
        frameDuration: "100/2500s",
        fieldOrder: nil,
        width: 1920,
        height: 1080,
        paspH: nil,
        paspV: nil,
        colorSpace: "1-1-1 (Rec. 709)",
        projection: nil,
        stereoscopic: nil
    )
    
    let r2Child1 = try! XMLElement(xmlString: """
        <media-rep kind="original-media" sig="53308E84E2E696489DF41ECEFBB51E41" src="file:///Volumes/Workspace/Dropbox/_coding/MarkersExtractor/FCP/Media/Nature%20Makes%20You%20Happy.mp4">
            <bookmark>Ym9va4wEAAAAAAQQMAAAAA9nZ86w8toDV1iRWhW7F3FnXf4R/JaQHTsjUwmr7RbnrAMAAAQAAAADAwAAABgAKAcAAAABAQAAVm9sdW1lcwAJAAAAAQEAAFdvcmtzcGFjZQAAAAcAAAABAQAARHJvcGJveAAHAAAAAQEAAF9jb2RpbmcAEAAAAAEBAABNYXJrZXJzRXh0cmFjdG9yAwAAAAEBAABGQ1AABQAAAAEBAABNZWRpYQAAABoAAAABAQAATmF0dXJlIE1ha2VzIFlvdSBIYXBweS5tcDQAACAAAAABBgAAEAAAACAAAAA0AAAARAAAAFQAAABsAAAAeAAAAIgAAAAIAAAABAMAACMAAAAAAAAACAAAAAQDAAACAAAAAAAAAAgAAAAEAwAA5AAAAAAAAAAIAAAABAMAAOgAAAAAAAAACAAAAAQDAADFTwEAAAAAAAgAAAAEAwAAdFABAAAAAAAIAAAABAMAAItQAQAAAAAACAAAAAQDAACYUwEAAAAAACAAAAABBgAA1AAAAOQAAAD0AAAABAEAABQBAAAkAQAANAEAAEQBAAAIAAAAAAQAAEHETWSSAAAAGAAAAAECAAABAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAAaAAAAAQkAAGZpbGU6Ly8vVm9sdW1lcy9Xb3Jrc3BhY2UvAAAIAAAABAMAAADAWtToAAAACAAAAAAEAABBxM4sX0BmzCQAAAABAQAANEExM0JFOTUtRjdGNi00QUVGLUI1M0QtRUI3QzgxRkRENThEGAAAAAECAAABAQAAAQAAAO8TAAABAAAAAAAAAAAAAAASAAAAAQEAAC9Wb2x1bWVzL1dvcmtzcGFjZQAACAAAAAEJAABmaWxlOi8vLwwAAAABAQAATWFjaW50b3NoIEhECAAAAAQDAAAA4AHj6AAAAAgAAAAABAAAQcV6LvQAAAAkAAAAAQEAADU2OEFFNUYxLTM4NTctNDNENC1CMjhDLTQ3MkVENUIzQzg2MBgAAAABAgAAgQAAAAEAAADvEwAAAQAAAAAAAAAAAAAAAQAAAAEBAAAvAAAAYAAAAP7///8A8AAAAAAAAAcAAAACIAAA6AIAAAAAAAAFIAAAWAIAAAAAAAAQIAAAaAIAAAAAAAARIAAAnAIAAAAAAAASIAAAfAIAAAAAAAATIAAAjAIAAAAAAAAgIAAAyAIAAAAAAAAEAAAAAwMAAADwAAAEAAAAAwMAAAAAAAAEAAAAAwMAAAEAAAAkAAAAAQYAAFwDAABoAwAAdAMAAGgDAABoAwAAaAMAAGgDAABoAwAAaAMAAKgAAAD+////AQAAAPQCAAANAAAABBAAAKwAAAAAAAAABRAAAFQBAAAAAAAAEBAAAIwBAAAAAAAAQBAAAHwBAAAAAAAAACAAAIADAAAAAAAAAiAAADwCAAAAAAAABSAAAKwBAAAAAAAAECAAACAAAAAAAAAAESAAAPABAAAAAAAAEiAAANABAAAAAAAAEyAAAOABAAAAAAAAICAAABwCAAAAAAAAENAAAAQAAAAAAAAA</bookmark>
        </media-rep>
        """
    )
    let r2Child2 = try! XMLElement(xmlString: """
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
    lazy var r2 = FinalCutPro.FCPXML.Asset(
        id: "r2",
        name: "Nature Makes You Happy",
        start: "0s",
        duration: "142040/1000s",
        format: "r1",
        uid: "53308E84E2E696489DF41ECEFBB51E41",
        hasVideo: true,
        hasAudio: true,
        audioSources: 1,
        audioChannels: 2,
        audioRate: 44100,
        videoSources: 1,
        auxVideoFlags: nil,
        xmlChildren: [r2Child1, r2Child2] // TODO: refactor out XML children
    )
    
    let r3Child1 = try! XMLElement(xmlString: """
        <media-rep kind="original-media" sig="7B6E7477652CFB3F66E2520EA95F18E2" src="file:///Volumes/Workspace/Dropbox/_coding/MarkersExtractor/FCP/Media/Interstellar%20Soundtrack%20-%20No%20Time%20for%20Caution.wav">
            <bookmark>Ym9va6QEAAAAAAQQMAAAAE6qgbBgG4byngsLQqoJGDtfjd2pAQE/Ck8H9jUa6XcAxAMAAAQAAAADAwAAABgAKAcAAAABAQAAVm9sdW1lcwAJAAAAAQEAAFdvcmtzcGFjZQAAAAcAAAABAQAARHJvcGJveAAHAAAAAQEAAF9jb2RpbmcAEAAAAAEBAABNYXJrZXJzRXh0cmFjdG9yAwAAAAEBAABGQ1AABQAAAAEBAABNZWRpYQAAADEAAAABAQAASW50ZXJzdGVsbGFyIFNvdW5kdHJhY2sgLSBObyBUaW1lIGZvciBDYXV0aW9uLndhdgAAACAAAAABBgAAEAAAACAAAAA0AAAARAAAAFQAAABsAAAAeAAAAIgAAAAIAAAABAMAACMAAAAAAAAACAAAAAQDAAACAAAAAAAAAAgAAAAEAwAA5AAAAAAAAAAIAAAABAMAAOgAAAAAAAAACAAAAAQDAADFTwEAAAAAAAgAAAAEAwAAdFABAAAAAAAIAAAABAMAAItQAQAAAAAACAAAAAQDAACZUwEAAAAAACAAAAABBgAA7AAAAPwAAAAMAQAAHAEAACwBAAA8AQAATAEAAFwBAAAIAAAAAAQAAEHEU1ZsAAAAGAAAAAECAAABAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAAaAAAAAQkAAGZpbGU6Ly8vVm9sdW1lcy9Xb3Jrc3BhY2UvAAAIAAAABAMAAADAWtToAAAACAAAAAAEAABBxM4sX0BmzCQAAAABAQAANEExM0JFOTUtRjdGNi00QUVGLUI1M0QtRUI3QzgxRkRENThEGAAAAAECAAABAQAAAQAAAO8TAAABAAAAAAAAAAAAAAASAAAAAQEAAC9Wb2x1bWVzL1dvcmtzcGFjZQAACAAAAAEJAABmaWxlOi8vLwwAAAABAQAATWFjaW50b3NoIEhECAAAAAQDAAAA4AHj6AAAAAgAAAAABAAAQcV6LvQAAAAkAAAAAQEAADU2OEFFNUYxLTM4NTctNDNENC1CMjhDLTQ3MkVENUIzQzg2MBgAAAABAgAAgQAAAAEAAADvEwAAAQAAAAAAAAAAAAAAAQAAAAEBAAAvAAAAYAAAAP7///8A8AAAAAAAAAcAAAACIAAAAAMAAAAAAAAFIAAAcAIAAAAAAAAQIAAAgAIAAAAAAAARIAAAtAIAAAAAAAASIAAAlAIAAAAAAAATIAAApAIAAAAAAAAgIAAA4AIAAAAAAAAEAAAAAwMAAADwAAAEAAAAAwMAAAAAAAAEAAAAAwMAAAEAAAAkAAAAAQYAAHQDAACAAwAAjAMAAIADAACAAwAAgAMAAIADAACAAwAAgAMAAKgAAAD+////AQAAAAwDAAANAAAABBAAAMQAAAAAAAAABRAAAGwBAAAAAAAAEBAAAKQBAAAAAAAAQBAAAJQBAAAAAAAAACAAAJgDAAAAAAAAAiAAAFQCAAAAAAAABSAAAMQBAAAAAAAAECAAACAAAAAAAAAAESAAAAgCAAAAAAAAEiAAAOgBAAAAAAAAEyAAAPgBAAAAAAAAICAAADQCAAAAAAAAENAAAAQAAAAAAAAA</bookmark>
        </media-rep>
        """
    )
    let r3Child2 = try! XMLElement(xmlString: """
        <metadata>
            <md key="com.apple.proapps.mio.ingestDate" value="2022-12-25 22:06:44 -0800"/>
        </metadata>
        """
    )
    lazy var r3 = FinalCutPro.FCPXML.Asset(
        id: "r3",
        name: "Interstellar Soundtrack - No Time for Caution",
        start: "0s",
        duration: "10860590/44100s",
        format: nil,
        uid: "7B6E7477652CFB3F66E2520EA95F18E2",
        hasVideo: false,
        hasAudio: true,
        audioSources: 1,
        audioChannels: 2,
        audioRate: 44100,
        videoSources: 0,
        auxVideoFlags: nil,
        xmlChildren: [r3Child1, r3Child2] // TODO: refactor out XML children
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
    
    let r5Child1 = try! XMLElement(xmlString: """
        <media-rep kind="original-media" sig="978BD3B254D68A6FA69E87D0D90544FD" src="file:///Volumes/Workspace/Dropbox/_coding/MarkersExtractor/FCP/Media/Is%20This%20The%20Land%20of%20Fire%20or%20Ice.mp4">
            <bookmark>Ym9va5QEAAAAAAQQMAAAAFVzgSnK8/ycBhhs90R/FSAWmWSsEtn07NRJDmX1V9MVtAMAAAQAAAADAwAAABgAKAcAAAABAQAAVm9sdW1lcwAJAAAAAQEAAFdvcmtzcGFjZQAAAAcAAAABAQAARHJvcGJveAAHAAAAAQEAAF9jb2RpbmcAEAAAAAEBAABNYXJrZXJzRXh0cmFjdG9yAwAAAAEBAABGQ1AABQAAAAEBAABNZWRpYQAAACMAAAABAQAASXMgVGhpcyBUaGUgTGFuZCBvZiBGaXJlIG9yIEljZS5tcDQAIAAAAAEGAAAQAAAAIAAAADQAAABEAAAAVAAAAGwAAAB4AAAAiAAAAAgAAAAEAwAAIwAAAAAAAAAIAAAABAMAAAIAAAAAAAAACAAAAAQDAADkAAAAAAAAAAgAAAAEAwAA6AAAAAAAAAAIAAAABAMAAMVPAQAAAAAACAAAAAQDAAB0UAEAAAAAAAgAAAAEAwAAi1ABAAAAAAAIAAAABAMAAJxTAQAAAAAAIAAAAAEGAADcAAAA7AAAAPwAAAAMAQAAHAEAACwBAAA8AQAATAEAAAgAAAAABAAAQcRNZNcAAAAYAAAAAQIAAAEAAAAAAAAADwAAAAAAAAAAAAAAAAAAABoAAAABCQAAZmlsZTovLy9Wb2x1bWVzL1dvcmtzcGFjZS8AAAgAAAAEAwAAAMBa1OgAAAAIAAAAAAQAAEHEzixfQGbMJAAAAAEBAAA0QTEzQkU5NS1GN0Y2LTRBRUYtQjUzRC1FQjdDODFGREQ1OEQYAAAAAQIAAAEBAAABAAAA7xMAAAEAAAAAAAAAAAAAABIAAAABAQAAL1ZvbHVtZXMvV29ya3NwYWNlAAAIAAAAAQkAAGZpbGU6Ly8vDAAAAAEBAABNYWNpbnRvc2ggSEQIAAAABAMAAADgAePoAAAACAAAAAAEAABBxXou9AAAACQAAAABAQAANTY4QUU1RjEtMzg1Ny00M0Q0LUIyOEMtNDcyRUQ1QjNDODYwGAAAAAECAACBAAAAAQAAAO8TAAABAAAAAAAAAAAAAAABAAAAAQEAAC8AAABgAAAA/v///wDwAAAAAAAABwAAAAIgAADwAgAAAAAAAAUgAABgAgAAAAAAABAgAABwAgAAAAAAABEgAACkAgAAAAAAABIgAACEAgAAAAAAABMgAACUAgAAAAAAACAgAADQAgAAAAAAAAQAAAADAwAAAPAAAAQAAAADAwAAAAAAAAQAAAADAwAAAQAAACQAAAABBgAAZAMAAHADAAB8AwAAcAMAAHADAABwAwAAcAMAAHADAABwAwAAqAAAAP7///8BAAAA/AIAAA0AAAAEEAAAtAAAAAAAAAAFEAAAXAEAAAAAAAAQEAAAlAEAAAAAAABAEAAAhAEAAAAAAAAAIAAAiAMAAAAAAAACIAAARAIAAAAAAAAFIAAAtAEAAAAAAAAQIAAAIAAAAAAAAAARIAAA+AEAAAAAAAASIAAA2AEAAAAAAAATIAAA6AEAAAAAAAAgIAAAJAIAAAAAAAAQ0AAABAAAAAAAAAA=</bookmark>
        </media-rep>
        """
    )
    let r5Child2 = try! XMLElement(xmlString: """
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
    lazy var r5 = FinalCutPro.FCPXML.Asset(
        id: "r5",
        name: "Is This The Land of Fire or Ice",
        start: "0s",
        duration: "205800/1000s",
        format: "r1",
        uid: "978BD3B254D68A6FA69E87D0D90544FD",
        hasVideo: true,
        hasAudio: true,
        audioSources: 1,
        audioChannels: 2,
        audioRate: 44100,
        videoSources: 1,
        auxVideoFlags: nil,
        xmlChildren: [r5Child1, r5Child2] // TODO: refactor out XML children
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
    
    lazy var resources: [String: FinalCutPro.FCPXML.AnyResource] = [
        r1.id: r1.asAnyResource(),
        r2.id: r2.asAnyResource(),
        r3.id: r3.asAnyResource(),
        r4.id: r4.asAnyResource(),
        r5.id: r5.asAnyResource(),
        r6.id: r6.asAnyResource(),
        r7.id: r7.asAnyResource()
    ]
    
    // MARK: Clip info
    
    struct ClipInfo: Equatable, Hashable {
        var clipType: FinalCutPro.FCPXML.ClipType
        var name: String?
        var absoluteStart: Timecode?
        var duration: Timecode?
        var markerDuration: MarkerDuration
        
        static let nature = ClipInfo(
            clipType: .assetClip,
            name: "Nature Makes You Happy",
            absoluteStart: tc("00:00:00:00"),
            duration: tc("00:02:22:01"),
            markerDuration: .frame
        )
        
        static let land = ClipInfo(
            clipType: .assetClip,
            name: "Is This The Land of Fire or Ice",
            absoluteStart: tc("00:02:22:01"),
            duration: tc("00:03:25:20"),
            markerDuration: .frame
        )
        
        static let clouds = ClipInfo(
            clipType: .video,
            name: "Clouds",
            absoluteStart: tc("00:05:47:21"),
            duration: tc("00:01:40:03"),
            markerDuration: .frame
        )
        
        static let title1 = ClipInfo(
            clipType: .title,
            name: "Basic Title - Basic Title",
            absoluteStart: tc("00:03:09:15"),
            duration: tc("00:00:17:05"),
            markerDuration: .frame
        )
        
        static let title2 = ClipInfo(
            clipType: .title,
            name: "Basic Title 2 - Basic Title",
            absoluteStart: tc("00:03:32:08"),
            duration: tc("00:00:12:09"),
            markerDuration: .frame
        )
        
        static let audio1 = ClipInfo(
            clipType: .assetClip,
            name: "Interstellar Soundtrack - No Time for Caution",
            absoluteStart: tc("00:00:00:00"),
            duration: tc("00:04:06:06.63"),
            markerDuration: .audioSample
        )
        
        static let audio2 = ClipInfo(
            clipType: .assetClip,
            name: "Interstellar Soundtrack - No Time for Caution",
            absoluteStart: tc("00:03:56:09.52"),
            duration: tc("00:03:31:14.27"),
            markerDuration: .audioSample
        )
    }
    
    enum MarkerDuration {
        case frame
        case audioSample
        
        var duration: Timecode {
            switch self {
            case .frame: 
                return tc("00:00:00:01")
            case .audioSample:
                // even though Final Cut Pro shows 44.1kHz as the audio sample rate for these clips,
                // the XML is using 48kHz as the rational fraction denominator to define the marker length
                return try! Timecode(.samples(1, sampleRate: 48000), at: frameRate, base: .max80SubFrames)
            }
        }
    }
    
    typealias MarkerDatum = (
        timecode: Timecode,
        name: String,
        note: String?,
        md: FinalCutPro.FCPXML.Marker.MarkerMetaData,
        clip: ClipInfo
    )
    
    // NOTE:
    // markers with "***" trialing comment are 1 subframe higher than what Final Cut Pro shows in
    // the marker list. this may be due to intra-subframe rounding when Final Cut Pro exports the XML.
    // a potential cause of this is if Final Cut Pro projects with mismatched frame rates are merged and
    // time positions have to be converted between frame rates.
    // for our purposes, this 1 subframe rounding issue is not ideal but it's not crucial to be perfect
    // in this instance.
    
    // swiftformat:options --maxwidth none
    static var markerData: [MarkerDatum] = [
        (tc("00:00:20:16.00"), "(To-Do) Penguin", "Note Test 1", .toDo(completed: false), .nature),
        (tc("00:00:25:05.00"), "(Standard) Flamingo Bird", "Colour Fix", .standard, .nature),
        (tc("00:00:35:23.00"), "Chapter 1", "Note Test 2", .chapter(posterOffset: tcInterval(frames: 11)), .nature),
        (tc("00:00:55:00.00"), "(To-Do) Red Crabs", "Note Test 3", .toDo(completed: false), .nature),
        (tc("00:01:17:20.00"), "(To-Do) Giraffe", "Note Test 4", .toDo(completed: false), .nature),
        (tc("00:01:33:10.35"), "Marker on Audio", "Audio Fix", .standard, .audio1),
        (tc("00:01:44:16.00"), "(Standard) Mountains", "VFX Shot", .standard, .nature),
        (tc("00:01:57:02.00"), "(Completed) Frog Jump", "Note Test 5", .toDo(completed: true), .nature),
        (tc("00:02:29:00.00"), "It is necessary", nil, .toDo(completed: false), .audio1),
        (tc("00:02:39:17.00"), "(To-Do) Red Giant", "Note Test 6", .toDo(completed: false), .land),
        (tc("00:02:53:23.29"), "Cooper!", nil, .toDo(completed: true), .audio1),
        (tc("00:03:03:14.00"), "(Standard) Kepler-36", "Explosion Shot", .standard, .land),
        (tc("00:03:12:20.00"), "Marker on Title 1", nil, .standard, .title1),
        (tc("00:03:22:10.00"), "Marker on Title 2", nil, .toDo(completed: false), .title1),
        (tc("00:03:32:08.00"), "Chapter 7", nil, .chapter(posterOffset: +tc(Fraction(11, 60))), .audio1),
        (tc("00:03:35:13.00"), "Marker on Title", nil, .toDo(completed: true), .title2),
        (tc("00:03:40:07.00"), "Chapter 5", nil, .chapter(posterOffset: tcInterval(frames: 11)), .title2),
        (tc("00:03:48:16.00"), "(Standard) Surface Temperatures", "Too Bright", .standard, .land),
        (tc("00:04:12:15.00"), "(Completed) Lava", "Nice Lava", .toDo(completed: true), .land),
        (tc("00:04:29:03.24"), "Sound FX 1", nil, .standard, .audio2),
        (tc("00:04:49:11.00"), "Chapter 2", "Note Test 7", .chapter(posterOffset: tcInterval(frames: 11)), .land),
        (tc("00:05:13:16.00"), "Chapter 3", "Note Test 8", .chapter(posterOffset: tcInterval(frames: 11)), .land),
        (tc("00:05:24:18.36"), "Sound FX 2", nil, .toDo(completed: false), .audio2),
        (tc("00:06:02:02.00"), "Cloud 1", nil, .standard, .clouds),
        (tc("00:06:15:11.20"), "SFX Completed", nil, .toDo(completed: true), .audio2),
        (tc("00:06:28:08.00"), "Cloud 2", nil, .toDo(completed: false), .clouds),
        (tc("00:06:39:00.54"), "Chapter 8", nil, .chapter(posterOffset: +tc(Fraction(11, 60))), .audio2), // ***
        (tc("00:06:48:09.00"), "Cloud 3", nil, .toDo(completed: true), .clouds),
        (tc("00:07:08:20.00"), "Chapter 6", nil, .chapter(posterOffset: tcInterval(frames: 11)), .clouds)
    ]
    // swiftformat:options --maxwidth 100
    
    static let frameRate: TimecodeFrameRate = .fps25
    
    static func tc(_ timecodeString: String) -> Timecode {
        try! Timecode(.string(timecodeString), at: frameRate, base: .max80SubFrames)
    }
    
    static func tc(frames: Int) -> Timecode {
        try! Timecode(.frames(frames), at: frameRate, base: .max80SubFrames)
    }
    
    static func tc(_ rational: Fraction) -> Timecode {
        try! Timecode(.rational(rational), at: frameRate, base: .max80SubFrames)
    }
    
    static func tcInterval(frames: Int) -> TimecodeInterval {
        if frames < 0 {
            return .negative(tc(frames: abs(frames)))
        } else {
            return .positive(tc(frames: frames))
        }
    }
    
    func debugString(for em: FinalCutPro.FCPXML.ExtractedMarker) -> String {
        let absTC = em.absoluteStart?.stringValue(format: [.showSubFrames]) ?? "??:??:??:??.??"
        let name = em.marker.name.quoted
        let note = em.marker.note != nil ? " note:\(em.marker.note!.quoted)" : ""
        let durTC = em.marker.duration?.stringValue(format: [.showSubFrames]) ?? "?"
        return "\(absTC) \(name)\(note) dur:\(durTC)"
    }
    
    func debugString(for extractedMarkers: some Collection<FinalCutPro.FCPXML.ExtractedMarker>) -> String {
        extractedMarkers.map { debugString(for: $0) }.joined(separator: "\n")
    }
    
    // MARK: - Tests
    
    func testParse() throws {
        // load file
        
        let rawData = try fileContents
        
        // parse file
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        
        XCTAssertEqual(fcpxml.version, .ver1_11)
        
        // resources
        
        let resources = fcpxml.resources()
        
        XCTAssertEqual(resources.count, 7)
        
        XCTAssertEqual(resources["r1"], .format(r1))
        
        XCTAssertEqual(resources["r2"], .asset(r2))
        
        XCTAssertEqual(resources["r3"], .asset(r3))
        
        XCTAssertEqual(resources["r4"], .format(r4))
        
        XCTAssertEqual(resources["r5"], .asset(r5))
        
        XCTAssertEqual(resources["r6"], .effect(r6))
        
        XCTAssertEqual(resources["r7"], .effect(r7))
        
        // library
        
        let library = try XCTUnwrap(fcpxml.library())
        
        let libraryURL = URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/")
        XCTAssertEqual(library.location, libraryURL)
        
        // events
        
        let events = fcpxml.events()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "Example A")
        
        // projects
        
        let projects = try XCTUnwrap(events[safe: 0]).projects
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        XCTAssertEqual(project.name, "Marker Data Demo_V2")
        XCTAssertEqual(project.startTimecode, Timecode(.zero, at: .fps25, base: .max80SubFrames))
        
        // sequence
        
        let sequence = try XCTUnwrap(projects[safe: 0]).sequence
        XCTAssertEqual(sequence.format, "r1")
        XCTAssertEqual(sequence.startTimecode, Timecode(.zero, at: .fps25, base: .max80SubFrames))
        XCTAssertEqual(sequence.startTimecode?.frameRate, .fps25)
        XCTAssertEqual(sequence.startTimecode?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.duration, Self.tc("00:07:27:24"))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // story elements (clips etc.)
        
        let spine = sequence.spine
        XCTAssertEqual(spine.elements.count, 3)
                
        guard case let .anyClip(.assetClip(element1)) = spine.elements[0] else { XCTFail("Clip was not expected type.") ; return }
        XCTAssertEqual(element1.ref, "r2")
        XCTAssertEqual(element1.offset, Timecode(.zero, at: .fps25, base: .max80SubFrames))
        XCTAssertEqual(element1.offset?.frameRate, .fps25)
        XCTAssertEqual(element1.name, "Nature Makes You Happy")
        XCTAssertEqual(element1.start, nil)
        XCTAssertEqual(element1.duration, Self.tc("00:02:22:01"))
        XCTAssertEqual(element1.duration?.frameRate, .fps25)
        XCTAssertEqual(element1.audioRole, "dialogue")
        
        guard case let .anyClip(.assetClip(element2)) = spine.elements[1] else { XCTFail("Clip was not expected type.") ; return }
        XCTAssertEqual(element2.ref, "r5")
        XCTAssertEqual(element2.offset, Self.tc("00:02:22:01"))
        XCTAssertEqual(element2.offset?.frameRate, .fps25)
        XCTAssertEqual(element2.name, "Is This The Land of Fire or Ice")
        XCTAssertEqual(element2.start, nil)
        XCTAssertEqual(element2.duration, Self.tc("00:03:25:20"))
        XCTAssertEqual(element2.duration?.frameRate, .fps25)
        XCTAssertEqual(element2.audioRole, "dialogue")
        
        guard case let .anyClip(.video(element3)) = spine.elements[2] else { XCTFail("Clip was not expected type.") ; return }
        XCTAssertEqual(element3.ref, "r7")
        XCTAssertEqual(element3.offset, Self.tc("00:05:47:21"))
        XCTAssertEqual(element3.offset?.frameRate, .fps25)
        XCTAssertEqual(element3.start, Self.tc("01:00:00:00"))
        XCTAssertEqual(element3.start?.frameRate, .fps25)
        XCTAssertEqual(element3.duration, Self.tc("00:01:40:03"))
        XCTAssertEqual(element3.duration?.frameRate, .fps25)
        XCTAssertEqual(element3.role, "Sample Role.Sample Role-1")
        
        // markers
        
        let element1Markers = element1.markers
        XCTAssertEqual(element1Markers.count, 7)
        
        let expectedE1Marker0 = FinalCutPro.FCPXML.Marker(
            start: Self.tc("00:00:20:16"),
            duration: Self.tc("00:00:00:01"),
            name: "(To-Do) Penguin",
            metaData: .toDo(completed: false),
            note: "Note Test 1"
        )
        XCTAssertEqual(element1Markers[safe: 0], expectedE1Marker0)
        
        
        
        let element2Markers = element2.markers
        XCTAssertEqual(element2Markers.count, 6) // shallow at clip level, there are more in nested title clips
        
        
        
        
        let element3Markers = element3.markers
        XCTAssertEqual(element3Markers.count, 4)
        
        
        
        #warning("> TODO: finish writing unit test")
    }
    
    func testExtractMarkers() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.events().first)
        
        // extract markers
        let extractedMarkers = event.extractMarkers(
            settings: FCPXMLMarkersExtractionSettings(
                // deep: true,
                excludeTypes: [],
                auditionMask: .activeAudition
            ),
            ancestorsOfParent: []
        )
        XCTAssertEqual(extractedMarkers.count, Self.markerData.count)
        
        // compare markers
        for md in Self.markerData {
            guard let extractedMarker = extractedMarkers.first(where: { $0.marker.name == md.name })
            else {
                let tcString = md.timecode.stringValue(format: [.showSubFrames])
                let nameString = md.name.quoted
                XCTFail("Marker not extracted: \(tcString) \(nameString)")
                continue
            }
            XCTAssertEqual(extractedMarker.absoluteStart, md.timecode, md.name)
            XCTAssertEqual(extractedMarker.marker.name, md.name, md.name)
            XCTAssertEqual(extractedMarker.marker.metaData, md.md, md.name)
            XCTAssertEqual(extractedMarker.marker.note, md.note, md.name)
            XCTAssertEqual(extractedMarker.marker.duration, md.clip.markerDuration.duration, md.name)
            
            XCTAssertEqual(extractedMarker.parentType, .anyClip(md.clip.clipType), md.name)
            XCTAssertEqual(extractedMarker.parentName, md.clip.name, md.name)
            XCTAssertEqual(extractedMarker.parentAbsoluteStart, md.clip.absoluteStart, md.name)
            XCTAssertEqual(extractedMarker.parentDuration, md.clip.duration, md.name)
            
            XCTAssertEqual(extractedMarker.ancestorEventName, "Example A")
            XCTAssertEqual(extractedMarker.ancestorProjectName, "Marker Data Demo_V2")
        }
        
         print(debugString(for: extractedMarkers))
        
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
        XCTAssertEqual(FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: clip, in: resources), r1)
        
        // sequence links directly to format r1
        XCTAssertEqual(FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: sequence, in: resources), r1)
    }
    
    func testParseFormat_AssetClip_Isolated() throws {
        // test data
        let clip = try XMLElement(xmlString: """
            <asset-clip ref="r2" offset="0s" name="Nature Makes You Happy" duration="355100/2500s" tcFormat="NDF" audioRole="dialogue">
            </asset-clip>
            """
        )
        
        // asset clip's ref r2 is an asset resource which in turn uses format r1, and asset clip contains its own tcFormat
        XCTAssertEqual(FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: clip, in: resources), r1)
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
        XCTAssertEqual(FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: innerClip, in: resources), r4)
        
        // has no format attribute.
        // ref r2 is an asset resource containing video and audio. it has a format attribute with value "r1".
        XCTAssertEqual(FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: outerClip, in: resources), r1)
        
        // sequence links directly to format r1
        XCTAssertEqual(FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: sequence, in: resources), r1)
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
        XCTAssertEqual(FinalCutPro.FCPXML.firstDefinedFormat(forElementOrAncestors: innerClip, in: resources), r1)
        
        // has no format attribute.
        // ref r2 is an asset resource containing video and audio. it has a format attribute with value "r1".
        XCTAssertEqual(FinalCutPro.FCPXML.firstDefinedFormat(forElementOrAncestors: outerClip, in: resources), r1)
        
        // sequence links directly to format r1
        XCTAssertEqual(FinalCutPro.FCPXML.firstDefinedFormat(forElementOrAncestors: sequence, in: resources), r1)
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
        XCTAssertEqual(FinalCutPro.FCPXML.timecodeFrameRate(for: clip, in: resources), .fps25)
        
        XCTAssertEqual(FinalCutPro.FCPXML.timecodeFrameRate(for: sequence, in: resources), .fps25)
    }
    
    func testParseFrameRate_VideoClip_Isolated() throws {
        // test data
        let clip = try XMLElement(xmlString: """
            <video ref="r7" offset="869600/2500s" name="Clouds" start="3600s" duration="250300/2500s" role="Sample Role.Sample Role-1">
            </video>
            """
        )
        
        // video clip's ref r7 doesn't contain any info, so it needs to traverse ancestors to find r1 in sequence
        XCTAssertEqual(FinalCutPro.FCPXML.timecodeFrameRate(for: clip, in: resources), nil)
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
        XCTAssertEqual(FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: clip, in: resources), r1)
        
        // sequence links directly to format r1
        XCTAssertEqual(FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: sequence, in: resources), r1)
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
        
        XCTAssertEqual(FinalCutPro.FCPXML.tcFormat(forElementOrAncestors: clip), .nonDropFrame)
        
        XCTAssertEqual(FinalCutPro.FCPXML.tcFormat(forElementOrAncestors: sequence), .nonDropFrame)
    }
}

#endif
