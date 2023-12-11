//
//  FinalCutPro FCPXML Element Init Tests.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
import Foundation
@testable import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_ElementInit: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testAsset() throws {
        let mediaRep = FinalCutPro.FCPXML.MediaRep(
            kind: .originalMedia,
            sig: "978BD3B254D68A6FA69E87D0D90544FD",
            src: URL(string: "file:///Volumes/Workspace/Dropbox/_coding/MarkersExtractor/FCP/Media/Is%20This%20The%20Land%20of%20Fire%20or%20Ice.mp4")!,
            bookmark: "Ym9va5QEAAAAAAQQMAAAAFVzgSnK8/ycBhhs90R/FSAWmWSsEtn07NRJDmX1V9MVtAMAAAQAAAADAwAAABgAKAcAAAABAQAAVm9sdW1lcwAJAAAAAQEAAFdvcmtzcGFjZQAAAAcAAAABAQAARHJvcGJveAAHAAAAAQEAAF9jb2RpbmcAEAAAAAEBAABNYXJrZXJzRXh0cmFjdG9yAwAAAAEBAABGQ1AABQAAAAEBAABNZWRpYQAAACMAAAABAQAASXMgVGhpcyBUaGUgTGFuZCBvZiBGaXJlIG9yIEljZS5tcDQAIAAAAAEGAAAQAAAAIAAAADQAAABEAAAAVAAAAGwAAAB4AAAAiAAAAAgAAAAEAwAAIwAAAAAAAAAIAAAABAMAAAIAAAAAAAAACAAAAAQDAADkAAAAAAAAAAgAAAAEAwAA6AAAAAAAAAAIAAAABAMAAMVPAQAAAAAACAAAAAQDAAB0UAEAAAAAAAgAAAAEAwAAi1ABAAAAAAAIAAAABAMAAJxTAQAAAAAAIAAAAAEGAADcAAAA7AAAAPwAAAAMAQAAHAEAACwBAAA8AQAATAEAAAgAAAAABAAAQcRNZNcAAAAYAAAAAQIAAAEAAAAAAAAADwAAAAAAAAAAAAAAAAAAABoAAAABCQAAZmlsZTovLy9Wb2x1bWVzL1dvcmtzcGFjZS8AAAgAAAAEAwAAAMBa1OgAAAAIAAAAAAQAAEHEzixfQGbMJAAAAAEBAAA0QTEzQkU5NS1GN0Y2LTRBRUYtQjUzRC1FQjdDODFGREQ1OEQYAAAAAQIAAAEBAAABAAAA7xMAAAEAAAAAAAAAAAAAABIAAAABAQAAL1ZvbHVtZXMvV29ya3NwYWNlAAAIAAAAAQkAAGZpbGU6Ly8vDAAAAAEBAABNYWNpbnRvc2ggSEQIAAAABAMAAADgAePoAAAACAAAAAAEAABBxXou9AAAACQAAAABAQAANTY4QUU1RjEtMzg1Ny00M0Q0LUIyOEMtNDcyRUQ1QjNDODYwGAAAAAECAACBAAAAAQAAAO8TAAABAAAAAAAAAAAAAAABAAAAAQEAAC8AAABgAAAA/v///wDwAAAAAAAABwAAAAIgAADwAgAAAAAAAAUgAABgAgAAAAAAABAgAABwAgAAAAAAABEgAACkAgAAAAAAABIgAACEAgAAAAAAABMgAACUAgAAAAAAACAgAADQAgAAAAAAAAQAAAADAwAAAPAAAAQAAAADAwAAAAAAAAQAAAADAwAAAQAAACQAAAABBgAAZAMAAHADAAB8AwAAcAMAAHADAABwAwAAcAMAAHADAABwAwAAqAAAAP7///8BAAAA/AIAAA0AAAAEEAAAtAAAAAAAAAAFEAAAXAEAAAAAAAAQEAAAlAEAAAAAAABAEAAAhAEAAAAAAAAAIAAAiAMAAAAAAAACIAAARAIAAAAAAAAFIAAAtAEAAAAAAAAQIAAAIAAAAAAAAAARIAAA+AEAAAAAAAASIAAA2AEAAAAAAAATIAAA6AEAAAAAAAAgIAAAJAIAAAAAAAAQ0AAABAAAAAAAAAA="
        )
        
        let metadataXML = try! XMLElement(xmlString: """
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
        let metadata = FinalCutPro.FCPXML.Metadata(element: metadataXML)
        
        let asset = FinalCutPro.FCPXML.Asset(
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
            auxVideoFlags: "flags",
            mediaRep: mediaRep,
            metadata: metadata
        )
        
        XCTAssertEqual(asset.id, "r5")
        XCTAssertEqual(asset.name, "Is This The Land of Fire or Ice")
        XCTAssertEqual(asset.start, .zero)
        XCTAssertEqual(asset.duration, Fraction(205800, 1000))
        XCTAssertEqual(asset.format, "r1")
        XCTAssertEqual(asset.uid, "978BD3B254D68A6FA69E87D0D90544FD")
        XCTAssertEqual(asset.hasAudio, true)
        XCTAssertEqual(asset.hasVideo, true)
        XCTAssertEqual(asset.audioSources, 1)
        XCTAssertEqual(asset.audioChannels, 2)
        XCTAssertEqual(asset.audioRate, .rate44_1kHz)
        XCTAssertEqual(asset.videoSources, 1)
        XCTAssertEqual(asset.auxVideoFlags, "flags")
        XCTAssertEqual(asset.mediaRep, mediaRep)
        XCTAssertEqual(asset.metadata, metadata)
    }
    
    func testEffect() {
        let effect = FinalCutPro.FCPXML.Effect(
            id: "r6",
            name: "Basic Title",
            uid: ".../Titles.localized/Bumper:Opener.localized/Basic Title.localized/Basic Title.moti",
            src: "source"
        )
        
        XCTAssertEqual(effect.id, "r6")
        XCTAssertEqual(effect.name, "Basic Title")
        XCTAssertEqual(effect.uid, ".../Titles.localized/Bumper:Opener.localized/Basic Title.localized/Basic Title.moti")
        XCTAssertEqual(effect.src, "source")
    }
    
    func testFormat() {
        let format = FinalCutPro.FCPXML.Format(
            id: "r1",
            name: "FFVideoFormat1080p25",
            frameDuration: Fraction(100, 2500),
            fieldOrder: nil,
            width: 1920,
            height: 1080,
            paspH: nil,
            paspV: nil,
            colorSpace: "1-1-1 (Rec. 709)",
            projection: nil,
            stereoscopic: nil
        )
        
        XCTAssertEqual(format.id, "r1")
        XCTAssertEqual(format.name, "FFVideoFormat1080p25")
        XCTAssertEqual(format.frameDuration, Fraction(100, 2500))
        XCTAssertEqual(format.fieldOrder, nil)
        XCTAssertEqual(format.width, 1920)
        XCTAssertEqual(format.height, 1080)
        XCTAssertEqual(format.paspH, nil)
        XCTAssertEqual(format.paspV, nil)
        XCTAssertEqual(format.colorSpace, "1-1-1 (Rec. 709)")
        XCTAssertEqual(format.projection, nil)
        XCTAssertEqual(format.stereoscopic, nil)
    }
    
    func testLocator() {
        let locator = FinalCutPro.FCPXML.Locator(
            id: "blah",
            url: URL(string: "file:///Users/user/movie.mov")!
        )
        
        XCTAssertEqual(locator.id, "blah")
        XCTAssertEqual(locator.url, URL(string: "file:///Users/user/movie.mov")!)
    }
    
    func testMedia() {
        let media = FinalCutPro.FCPXML.Media(
            id: "r2",
            name: "Some Media",
            uid: "9asdfyna9d8fnyads8",
            projectRef: "Project reference ahoy",
            modDate: "2022-12-30 20:47:39 -0800"
        )
        
        XCTAssertEqual(media.id, "r2")
        XCTAssertEqual(media.name, "Some Media")
        XCTAssertEqual(media.uid, "9asdfyna9d8fnyads8")
        XCTAssertEqual(media.projectRef, "Project reference ahoy")
        XCTAssertEqual(media.modDate, "2022-12-30 20:47:39 -0800")
    }
    
    func testObjectTracker() {
        #warning("> TODO: write unit test")
        
        let tracker = FinalCutPro.FCPXML.ObjectTracker(trackingShapes: [
            .init(),
            .init()
        ])
        
        // TODO: add equality check for tracking shapes once properties have been implemented for them
        // for now, just check that child count is correct
        XCTAssertEqual(tracker.trackingShapes.count, 2)
    }
}

#endif
