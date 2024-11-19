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
    
    // MARK: - Common Elements
    
    func testAudioChannelSource() throws {
        let source = FinalCutPro.FCPXML.AudioChannelSource(
            sourceChannels: "1, 2",
            outputChannels: "L, R",
            role: .init(rawValue: "music.music-1")!,
            start: Fraction(3600, 1),
            duration: Fraction(30, 1),
            enabled: false,
            active: false
        )
        
        XCTAssertEqual(source.sourceChannels, "1, 2")
        XCTAssertEqual(source.outputChannels, "L, R")
        XCTAssertEqual(source.role, .init(rawValue: "music.music-1")!)
        XCTAssertEqual(source.start, Fraction(3600, 1))
        XCTAssertEqual(source.duration, Fraction(30, 1))
        XCTAssertEqual(source.enabled, false)
        XCTAssertEqual(source.active, false)
    }
    
    func testAudioRoleSource() throws {
        let source = FinalCutPro.FCPXML.AudioRoleSource(
            role: .init(rawValue: "music.music-1")!,
            active: false
        )
        
        XCTAssertEqual(source.role, .init(rawValue: "music.music-1")!)
        XCTAssertEqual(source.active, false)
    }
    
    // MARK: - Annotations
    
    func testCaption() {
        let caption = FinalCutPro.FCPXML.Caption(
            role: .init(rawValue: "iTT?captionFormat=ITT.fr")!,
            note: "Some notes",
            lane: 2,
            offset: Fraction(10, 1),
            name: "Caption name",
            start: Fraction(20, 1),
            duration: Fraction(100, 1),
            enabled: false
        )
        
        XCTAssertEqual(caption.role, .init(rawValue: "iTT?captionFormat=ITT.fr")!)
        XCTAssertEqual(caption.note, "Some notes")
        XCTAssertEqual(caption.lane, 2)
        XCTAssertEqual(caption.offset, Fraction(10, 1))
        XCTAssertEqual(caption.name, "Caption name")
        XCTAssertEqual(caption.start, Fraction(20, 1))
        XCTAssertEqual(caption.duration, Fraction(100, 1))
        XCTAssertEqual(caption.enabled, false)
    }
    
    func testKeyword() {
        let keyword = FinalCutPro.FCPXML.Keyword(
            keywords: ["keyword1", "keyword2"],
            start: Fraction(10, 1),
            duration: Fraction(25, 1),
            note: "Some notes"
        )
        
        XCTAssertEqual(keyword.keywords, ["keyword1", "keyword2"])
        XCTAssertEqual(keyword.note, "Some notes")
        XCTAssertEqual(keyword.start, Fraction(10, 1))
        XCTAssertEqual(keyword.duration, Fraction(25, 1))
    }
    
    func testMarker() {
        let keyword = FinalCutPro.FCPXML.Marker(
            name: "Marker name",
            configuration: .chapter(posterOffset: Fraction(2,1)),
            start: Fraction(10, 1),
            duration: Fraction(25, 1),
            note: "Some notes"
        )
        
        XCTAssertEqual(keyword.name, "Marker name")
        XCTAssertEqual(keyword.configuration, .chapter(posterOffset: Fraction(2,1)))
        XCTAssertEqual(keyword.start, Fraction(10, 1))
        XCTAssertEqual(keyword.duration, Fraction(25, 1))
        XCTAssertEqual(keyword.note, "Some notes")
        
        // extra checks
        XCTAssertEqual(keyword.element.fcpPosterOffset, Fraction(2,1))
    }
    
    // MARK: - Clips
    
    func testAssetClip() {
        let assetClip = FinalCutPro.FCPXML.AssetClip(
            ref: "r2",
            srcEnable: .audio,
            format: "r3",
            tcStart: Fraction(3600, 1),
            tcFormat: .dropFrame,
            audioRole: .init(rawValue: "music.music-1")!,
            videoRole: .init(rawValue: "video.video-1")!,
            audioStart: Fraction(10, 1),
            audioDuration: Fraction(20, 1),
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            modDate: "2022-12-30 20:47:39 -0800",
            note: "Notes here",
            metadata: metadata
        )
        
        XCTAssertEqual(assetClip.ref, "r2")
        XCTAssertEqual(assetClip.srcEnable, .audio)
        XCTAssertEqual(assetClip.format, "r3")
        XCTAssertEqual(assetClip.tcStart, Fraction(3600, 1))
        XCTAssertEqual(assetClip.tcFormat, .dropFrame)
        XCTAssertEqual(assetClip.audioRole, .init(rawValue: "music.music-1")!)
        XCTAssertEqual(assetClip.videoRole, .init(rawValue: "video.video-1")!)
        XCTAssertEqual(assetClip.audioStart, Fraction(10, 1))
        XCTAssertEqual(assetClip.audioDuration, Fraction(20, 1))
        XCTAssertEqual(assetClip.lane, 2)
        XCTAssertEqual(assetClip.offset, Fraction(4, 1))
        XCTAssertEqual(assetClip.name, "Clip name")
        XCTAssertEqual(assetClip.start, Fraction(2, 1))
        XCTAssertEqual(assetClip.duration, Fraction(100, 1))
        XCTAssertEqual(assetClip.enabled, false)
        XCTAssertEqual(assetClip.modDate, "2022-12-30 20:47:39 -0800")
        XCTAssertEqual(assetClip.note, "Notes here")
        XCTAssertEqual(assetClip.metadata, metadata)
    }
    
    func testAudio() {
        let audio = FinalCutPro.FCPXML.Audio(
            ref: "r2",
            role: .init(rawValue: "music.music-1")!,
            srcID: "3",
            sourceChannels: "3, 4",
            outputChannels: "L, R",
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            note: "Notes here"
        )
        
        XCTAssertEqual(audio.ref, "r2")
        XCTAssertEqual(audio.role, .init(rawValue: "music.music-1")!)
        XCTAssertEqual(audio.srcID, "3")
        XCTAssertEqual(audio.sourceChannels, "3, 4")
        XCTAssertEqual(audio.outputChannels, "L, R")
        XCTAssertEqual(audio.lane, 2)
        XCTAssertEqual(audio.offset, Fraction(4, 1))
        XCTAssertEqual(audio.name, "Clip name")
        XCTAssertEqual(audio.start, Fraction(2, 1))
        XCTAssertEqual(audio.duration, Fraction(100, 1))
        XCTAssertEqual(audio.enabled, false)
        XCTAssertEqual(audio.note, "Notes here")
    }
    
    func testAudition() {
        let audition = FinalCutPro.FCPXML.Audition(
            lane: 2,
            offset: Fraction(4, 1),
            modDate: "2022-12-30 20:47:39 -0800"
        )
        
        XCTAssertEqual(audition.lane, 2)
        XCTAssertEqual(audition.offset, Fraction(4, 1))
        XCTAssertEqual(audition.modDate, "2022-12-30 20:47:39 -0800")
    }
    
    func testClip() {
        let clip = FinalCutPro.FCPXML.Clip(
            format: "r3",
            tcStart: Fraction(3600, 1),
            tcFormat: .dropFrame,
            audioStart: Fraction(10, 1),
            audioDuration: Fraction(20, 1),
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            modDate: "2022-12-30 20:47:39 -0800",
            note: "Notes here",
            metadata: metadata
        )
        
        XCTAssertEqual(clip.format, "r3")
        XCTAssertEqual(clip.tcStart, Fraction(3600, 1))
        XCTAssertEqual(clip.tcFormat, .dropFrame)
        XCTAssertEqual(clip.audioStart, Fraction(10, 1))
        XCTAssertEqual(clip.audioDuration, Fraction(20, 1))
        XCTAssertEqual(clip.lane, 2)
        XCTAssertEqual(clip.offset, Fraction(4, 1))
        XCTAssertEqual(clip.name, "Clip name")
        XCTAssertEqual(clip.start, Fraction(2, 1))
        XCTAssertEqual(clip.duration, Fraction(100, 1))
        XCTAssertEqual(clip.enabled, false)
        XCTAssertEqual(clip.modDate, "2022-12-30 20:47:39 -0800")
        XCTAssertEqual(clip.note, "Notes here")
        XCTAssertEqual(clip.metadata, metadata)
    }
    
    func testGap() {
        let gap = FinalCutPro.FCPXML.Gap(
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            note: "Notes here",
            metadata: metadata
        )
        
        XCTAssertEqual(gap.offset, Fraction(4, 1))
        XCTAssertEqual(gap.name, "Clip name")
        XCTAssertEqual(gap.start, Fraction(2, 1))
        XCTAssertEqual(gap.duration, Fraction(100, 1))
        XCTAssertEqual(gap.enabled, false)
        XCTAssertEqual(gap.note, "Notes here")
        XCTAssertEqual(gap.metadata, metadata)
    }
    
    func testMCClip() {
        let mcClip = FinalCutPro.FCPXML.MCClip(
            ref: "r2",
            srcEnable: .audio,
            audioStart: Fraction(10, 1),
            audioDuration: Fraction(20, 1),
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            modDate: "2022-12-30 20:47:39 -0800",
            note: "Notes here",
            metadata: metadata
        )
        
        XCTAssertEqual(mcClip.ref, "r2")
        XCTAssertEqual(mcClip.srcEnable, .audio)
        XCTAssertEqual(mcClip.audioStart, Fraction(10, 1))
        XCTAssertEqual(mcClip.audioDuration, Fraction(20, 1))
        XCTAssertEqual(mcClip.lane, 2)
        XCTAssertEqual(mcClip.offset, Fraction(4, 1))
        XCTAssertEqual(mcClip.name, "Clip name")
        XCTAssertEqual(mcClip.start, Fraction(2, 1))
        XCTAssertEqual(mcClip.duration, Fraction(100, 1))
        XCTAssertEqual(mcClip.enabled, false)
        XCTAssertEqual(mcClip.modDate, "2022-12-30 20:47:39 -0800")
        XCTAssertEqual(mcClip.note, "Notes here")
        XCTAssertEqual(mcClip.metadata, metadata)
    }
    
    func testMulticamSource() {
        let mcSource = FinalCutPro.FCPXML.MulticamSource(
            angleID: "as9dn8oadnof",
            sourceEnable: .video
        )
        
        XCTAssertEqual(mcSource.angleID, "as9dn8oadnof")
        XCTAssertEqual(mcSource.sourceEnable, .video)
    }
    
    func testRefClip() {
        let refClip = FinalCutPro.FCPXML.RefClip(
            ref: "r2",
            srcEnable: .audio,
            useAudioSubroles: true,
            audioStart: Fraction(10, 1),
            audioDuration: Fraction(20, 1),
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            modDate: "2022-12-30 20:47:39 -0800",
            note: "Notes here",
            metadata: metadata
        )
        
        XCTAssertEqual(refClip.ref, "r2")
        XCTAssertEqual(refClip.srcEnable, .audio)
        XCTAssertEqual(refClip.useAudioSubroles, true)
        XCTAssertEqual(refClip.audioStart, Fraction(10, 1))
        XCTAssertEqual(refClip.audioDuration, Fraction(20, 1))
        XCTAssertEqual(refClip.lane, 2)
        XCTAssertEqual(refClip.offset, Fraction(4, 1))
        XCTAssertEqual(refClip.name, "Clip name")
        XCTAssertEqual(refClip.start, Fraction(2, 1))
        XCTAssertEqual(refClip.duration, Fraction(100, 1))
        XCTAssertEqual(refClip.enabled, false)
        XCTAssertEqual(refClip.modDate, "2022-12-30 20:47:39 -0800")
        XCTAssertEqual(refClip.note, "Notes here")
        XCTAssertEqual(refClip.metadata, metadata)
    }
    
    func testSyncClip() {
        let syncClip = FinalCutPro.FCPXML.SyncClip(
            format: "r2",
            tcStart: Fraction(3600, 1),
            tcFormat: .dropFrame,
            audioStart: Fraction(10, 1),
            audioDuration: Fraction(20, 1),
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            modDate: "2022-12-30 20:47:39 -0800",
            note: "Notes here",
            metadata: metadata
        )
        
        XCTAssertEqual(syncClip.format, "r2")
        XCTAssertEqual(syncClip.tcStart, Fraction(3600, 1))
        XCTAssertEqual(syncClip.tcFormat, .dropFrame)
        XCTAssertEqual(syncClip.audioStart, Fraction(10, 1))
        XCTAssertEqual(syncClip.audioDuration, Fraction(20, 1))
        XCTAssertEqual(syncClip.lane, 2)
        XCTAssertEqual(syncClip.offset, Fraction(4, 1))
        XCTAssertEqual(syncClip.name, "Clip name")
        XCTAssertEqual(syncClip.start, Fraction(2, 1))
        XCTAssertEqual(syncClip.duration, Fraction(100, 1))
        XCTAssertEqual(syncClip.enabled, false)
        XCTAssertEqual(syncClip.modDate, "2022-12-30 20:47:39 -0800")
        XCTAssertEqual(syncClip.note, "Notes here")
        XCTAssertEqual(syncClip.metadata, metadata)
    }
    
    func testSyncSource() {
        let syncSource = FinalCutPro.FCPXML.SyncClip.SyncSource(
            sourceID: .connected
        )
        
        XCTAssertEqual(syncSource.sourceID, .connected)
    }
    
    func testTitle() {
        let title = FinalCutPro.FCPXML.Title(
            ref: "r2",
            role: .init(rawValue: "video.video-1")!,
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            note: "Notes here",
            metadata: metadata
        )
        
        XCTAssertEqual(title.ref, "r2")
        XCTAssertEqual(title.role, .init(rawValue: "video.video-1")!)
        XCTAssertEqual(title.lane, 2)
        XCTAssertEqual(title.offset, Fraction(4, 1))
        XCTAssertEqual(title.name, "Clip name")
        XCTAssertEqual(title.start, Fraction(2, 1))
        XCTAssertEqual(title.duration, Fraction(100, 1))
        XCTAssertEqual(title.enabled, false)
        XCTAssertEqual(title.note, "Notes here")
        XCTAssertEqual(title.metadata, metadata)
    }
    
    func testVideo() {
        let title = FinalCutPro.FCPXML.Video(
            ref: "r2",
            role: .init(rawValue: "video.video-1")!,
            srcID: "3",
            lane: 2,
            offset: Fraction(4, 1),
            name: "Clip name",
            start: Fraction(2, 1),
            duration: Fraction(100, 1),
            enabled: false,
            note: "Notes here"
        )
        
        XCTAssertEqual(title.ref, "r2")
        XCTAssertEqual(title.role, .init(rawValue: "video.video-1")!)
        XCTAssertEqual(title.srcID, "3")
        XCTAssertEqual(title.lane, 2)
        XCTAssertEqual(title.offset, Fraction(4, 1))
        XCTAssertEqual(title.name, "Clip name")
        XCTAssertEqual(title.start, Fraction(2, 1))
        XCTAssertEqual(title.duration, Fraction(100, 1))
        XCTAssertEqual(title.enabled, false)
        XCTAssertEqual(title.note, "Notes here")
    }
    
    // MARK: - Story
    
    func testSequence() throws {
        let sequence = FinalCutPro.FCPXML.Sequence(
            spine: spine,
            audioLayout: .stereo,
            audioRate: .rate48kHz,
            renderFormat: "fmt",
            keywords: "keyword1,keyword2",
            format: "r2",
            duration: Fraction(100, 1),
            tcStart: Fraction(3600, 1),
            tcFormat: .dropFrame,
            note: "Some notes",
            metadata: metadata
        )
        
        XCTAssertEqual(sequence.spine, spine)
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        XCTAssertEqual(sequence.renderFormat, "fmt")
        XCTAssertEqual(sequence.keywords, "keyword1,keyword2")
        XCTAssertEqual(sequence.format, "r2")
        XCTAssertEqual(sequence.duration, Fraction(100, 1))
        XCTAssertEqual(sequence.tcStart, Fraction(3600, 1))
        XCTAssertEqual(sequence.tcFormat, .dropFrame)
        XCTAssertEqual(sequence.note, "Some notes")
        XCTAssertEqual(sequence.metadata, metadata)
    }
    
    let spine = FinalCutPro.FCPXML.Spine(
        name: "Spine name",
        format: "r2",
        lane: 2,
        offset: Fraction(4, 1)
    )
    
    func testSpine() {
        XCTAssertEqual(spine.name, "Spine name")
        XCTAssertEqual(spine.format, "r2")
        XCTAssertEqual(spine.lane, 2)
        XCTAssertEqual(spine.offset, Fraction(4, 1))
    }
                                         
    // MARK: - Resources
    
    let mediaRep = FinalCutPro.FCPXML.MediaRep(
        kind: .originalMedia,
        sig: "978BD3B254D68A6FA69E87D0D90544FD",
        src: URL(string: "file:///Volumes/Workspace/Dropbox/_coding/MarkersExtractor/FCP/Media/Is%20This%20The%20Land%20of%20Fire%20or%20Ice.mp4")!,
        bookmark: "Ym9va5QEAAAAAAQQMAAAAFVzgSnK8/ycBhhs90R/FSAWmWSsEtn07NRJDmX1V9MVtAMAAAQAAAADAwAAABgAKAcAAAABAQAAVm9sdW1lcwAJAAAAAQEAAFdvcmtzcGFjZQAAAAcAAAABAQAARHJvcGJveAAHAAAAAQEAAF9jb2RpbmcAEAAAAAEBAABNYXJrZXJzRXh0cmFjdG9yAwAAAAEBAABGQ1AABQAAAAEBAABNZWRpYQAAACMAAAABAQAASXMgVGhpcyBUaGUgTGFuZCBvZiBGaXJlIG9yIEljZS5tcDQAIAAAAAEGAAAQAAAAIAAAADQAAABEAAAAVAAAAGwAAAB4AAAAiAAAAAgAAAAEAwAAIwAAAAAAAAAIAAAABAMAAAIAAAAAAAAACAAAAAQDAADkAAAAAAAAAAgAAAAEAwAA6AAAAAAAAAAIAAAABAMAAMVPAQAAAAAACAAAAAQDAAB0UAEAAAAAAAgAAAAEAwAAi1ABAAAAAAAIAAAABAMAAJxTAQAAAAAAIAAAAAEGAADcAAAA7AAAAPwAAAAMAQAAHAEAACwBAAA8AQAATAEAAAgAAAAABAAAQcRNZNcAAAAYAAAAAQIAAAEAAAAAAAAADwAAAAAAAAAAAAAAAAAAABoAAAABCQAAZmlsZTovLy9Wb2x1bWVzL1dvcmtzcGFjZS8AAAgAAAAEAwAAAMBa1OgAAAAIAAAAAAQAAEHEzixfQGbMJAAAAAEBAAA0QTEzQkU5NS1GN0Y2LTRBRUYtQjUzRC1FQjdDODFGREQ1OEQYAAAAAQIAAAEBAAABAAAA7xMAAAEAAAAAAAAAAAAAABIAAAABAQAAL1ZvbHVtZXMvV29ya3NwYWNlAAAIAAAAAQkAAGZpbGU6Ly8vDAAAAAEBAABNYWNpbnRvc2ggSEQIAAAABAMAAADgAePoAAAACAAAAAAEAABBxXou9AAAACQAAAABAQAANTY4QUU1RjEtMzg1Ny00M0Q0LUIyOEMtNDcyRUQ1QjNDODYwGAAAAAECAACBAAAAAQAAAO8TAAABAAAAAAAAAAAAAAABAAAAAQEAAC8AAABgAAAA/v///wDwAAAAAAAABwAAAAIgAADwAgAAAAAAAAUgAABgAgAAAAAAABAgAABwAgAAAAAAABEgAACkAgAAAAAAABIgAACEAgAAAAAAABMgAACUAgAAAAAAACAgAADQAgAAAAAAAAQAAAADAwAAAPAAAAQAAAADAwAAAAAAAAQAAAADAwAAAQAAACQAAAABBgAAZAMAAHADAAB8AwAAcAMAAHADAABwAwAAcAMAAHADAABwAwAAqAAAAP7///8BAAAA/AIAAA0AAAAEEAAAtAAAAAAAAAAFEAAAXAEAAAAAAAAQEAAAlAEAAAAAAABAEAAAhAEAAAAAAAAAIAAAiAMAAAAAAAACIAAARAIAAAAAAAAFIAAAtAEAAAAAAAAQIAAAIAAAAAAAAAARIAAA+AEAAAAAAAASIAAA2AEAAAAAAAATIAAA6AEAAAAAAAAgIAAAJAIAAAAAAAAQ0AAABAAAAAAAAAA="
    )
    
    func testMediaRep() throws {
        XCTAssertEqual(mediaRep.kind, .originalMedia)
        XCTAssertEqual(mediaRep.sig, "978BD3B254D68A6FA69E87D0D90544FD")
        XCTAssertEqual(
            mediaRep.src,
            URL(string: "file:///Volumes/Workspace/Dropbox/_coding/MarkersExtractor/FCP/Media/Is%20This%20The%20Land%20of%20Fire%20or%20Ice.mp4")!
        )
        XCTAssertEqual(
            mediaRep.bookmarkData, 
            "Ym9va5QEAAAAAAQQMAAAAFVzgSnK8/ycBhhs90R/FSAWmWSsEtn07NRJDmX1V9MVtAMAAAQAAAADAwAAABgAKAcAAAABAQAAVm9sdW1lcwAJAAAAAQEAAFdvcmtzcGFjZQAAAAcAAAABAQAARHJvcGJveAAHAAAAAQEAAF9jb2RpbmcAEAAAAAEBAABNYXJrZXJzRXh0cmFjdG9yAwAAAAEBAABGQ1AABQAAAAEBAABNZWRpYQAAACMAAAABAQAASXMgVGhpcyBUaGUgTGFuZCBvZiBGaXJlIG9yIEljZS5tcDQAIAAAAAEGAAAQAAAAIAAAADQAAABEAAAAVAAAAGwAAAB4AAAAiAAAAAgAAAAEAwAAIwAAAAAAAAAIAAAABAMAAAIAAAAAAAAACAAAAAQDAADkAAAAAAAAAAgAAAAEAwAA6AAAAAAAAAAIAAAABAMAAMVPAQAAAAAACAAAAAQDAAB0UAEAAAAAAAgAAAAEAwAAi1ABAAAAAAAIAAAABAMAAJxTAQAAAAAAIAAAAAEGAADcAAAA7AAAAPwAAAAMAQAAHAEAACwBAAA8AQAATAEAAAgAAAAABAAAQcRNZNcAAAAYAAAAAQIAAAEAAAAAAAAADwAAAAAAAAAAAAAAAAAAABoAAAABCQAAZmlsZTovLy9Wb2x1bWVzL1dvcmtzcGFjZS8AAAgAAAAEAwAAAMBa1OgAAAAIAAAAAAQAAEHEzixfQGbMJAAAAAEBAAA0QTEzQkU5NS1GN0Y2LTRBRUYtQjUzRC1FQjdDODFGREQ1OEQYAAAAAQIAAAEBAAABAAAA7xMAAAEAAAAAAAAAAAAAABIAAAABAQAAL1ZvbHVtZXMvV29ya3NwYWNlAAAIAAAAAQkAAGZpbGU6Ly8vDAAAAAEBAABNYWNpbnRvc2ggSEQIAAAABAMAAADgAePoAAAACAAAAAAEAABBxXou9AAAACQAAAABAQAANTY4QUU1RjEtMzg1Ny00M0Q0LUIyOEMtNDcyRUQ1QjNDODYwGAAAAAECAACBAAAAAQAAAO8TAAABAAAAAAAAAAAAAAABAAAAAQEAAC8AAABgAAAA/v///wDwAAAAAAAABwAAAAIgAADwAgAAAAAAAAUgAABgAgAAAAAAABAgAABwAgAAAAAAABEgAACkAgAAAAAAABIgAACEAgAAAAAAABMgAACUAgAAAAAAACAgAADQAgAAAAAAAAQAAAADAwAAAPAAAAQAAAADAwAAAAAAAAQAAAADAwAAAQAAACQAAAABBgAAZAMAAHADAAB8AwAAcAMAAHADAABwAwAAcAMAAHADAABwAwAAqAAAAP7///8BAAAA/AIAAA0AAAAEEAAAtAAAAAAAAAAFEAAAXAEAAAAAAAAQEAAAlAEAAAAAAABAEAAAhAEAAAAAAAAAIAAAiAMAAAAAAAACIAAARAIAAAAAAAAFIAAAtAEAAAAAAAAQIAAAIAAAAAAAAAARIAAA+AEAAAAAAAASIAAA2AEAAAAAAAATIAAA6AEAAAAAAAAgIAAAJAIAAAAAAAAQ0AAABAAAAAAAAAA="
                .data(using: .utf8)!
        )
    }
    
    // TODO: replace with parameterized init once it's implemented on Metadata model
    let metadataXML = try! XMLElement(xmlString: """
            <metadata>
                <md key="com.apple.proapps.mio.cameraName" value="TestVideo Camera Name"/>
                <md key="com.apple.proapps.studio.rawToLogConversion" value="0"/>
                <md key="com.apple.proapps.spotlight.kMDItemProfileName" value="SD (6-1-6)"/>
                <md key="com.apple.proapps.studio.cameraISO" value="120"/>
                <md key="com.apple.proapps.studio.cameraColorTemperature" value="0"/>
                <md key="com.apple.proapps.spotlight.kMDItemCodecs">
                    <array>
                        <string>'avc1'</string>
                        <string>MPEG-4 AAC</string>
                    </array>
                </md>
                <md key="com.apple.proapps.mio.ingestDate" value="2023-01-01 19:46:28 -0800"/>
                
                <md key="com.apple.proapps.studio.reel" value="TestVideo Reel"/>
                <md key="com.apple.proapps.studio.scene" value="TestVideo Scene"/>
                <md key="com.apple.proapps.studio.shot" value="TestVideo Take"/>
                <md key="com.apple.proapps.studio.angle" value="TestVideo Camera Angle"/>
            </metadata>
            """
    )
    lazy var metadata = FinalCutPro.FCPXML.Metadata(element: metadataXML)!
    
    func testMetadata() throws {
        let md = FinalCutPro.FCPXML.Metadata()
        
        // test initial state
        XCTAssertNil(md.cameraName)
        XCTAssertNil(md.rawToLogConversion)
        XCTAssertNil(md.colorProfile)
        XCTAssertNil(md.cameraISO)
        XCTAssertNil(md.cameraColorTemperature)
        XCTAssertNil(md.codecs)
        XCTAssertNil(md.ingestDate)
        XCTAssertNil(md.reel)
        XCTAssertNil(md.scene)
        XCTAssertNil(md.take)
        XCTAssertNil(md.cameraAngle)
        
        // set new values
        md.cameraName = "TestVideo Camera Name"
        md.rawToLogConversion = "0"
        md.colorProfile = "SD (6-1-6)"
        md.cameraISO = "120"
        md.cameraColorTemperature = "0"
        md.codecs = ["'avc1'", "MPEG-4 AAC"]
        md.ingestDate = "2023-01-01 19:46:28 -0800"
        md.reel = "TestVideo Reel"
        md.scene = "TestVideo Scene"
        md.take = "TestVideo Take"
        md.cameraAngle = "TestVideo Camera Angle"
        
        // test new values
        XCTAssertEqual(md.cameraName, "TestVideo Camera Name")
        XCTAssertEqual(md.rawToLogConversion, "0")
        XCTAssertEqual(md.colorProfile, "SD (6-1-6)")
        XCTAssertEqual(md.cameraISO, "120")
        XCTAssertEqual(md.cameraColorTemperature, "0")
        XCTAssertEqual(md.codecs, ["'avc1'", "MPEG-4 AAC"])
        XCTAssertEqual(md.ingestDate, "2023-01-01 19:46:28 -0800")
        XCTAssertEqual(md.reel, "TestVideo Reel")
        XCTAssertEqual(md.scene, "TestVideo Scene")
        XCTAssertEqual(md.take, "TestVideo Take")
        XCTAssertEqual(md.cameraAngle, "TestVideo Camera Angle")
        
        // remove values
        md.cameraName = nil
        md.rawToLogConversion = nil
        md.colorProfile = nil
        md.cameraISO = nil
        md.cameraColorTemperature = nil
        md.codecs = nil
        md.ingestDate = nil
        md.reel = nil
        md.scene = nil
        md.take = nil
        md.cameraAngle = nil
        
        // test removed values
        XCTAssertNil(md.cameraName)
        XCTAssertNil(md.rawToLogConversion)
        XCTAssertNil(md.colorProfile)
        XCTAssertNil(md.cameraISO)
        XCTAssertNil(md.cameraColorTemperature)
        XCTAssertNil(md.codecs)
        XCTAssertNil(md.ingestDate)
        XCTAssertNil(md.reel)
        XCTAssertNil(md.scene)
        XCTAssertNil(md.take)
        XCTAssertNil(md.cameraAngle)
        
        // check codecs with empty array; should remove key entirely.
        md.codecs = []
        XCTAssertNil(md.codecs)
    }
    
    func testMetadata_FromXML() throws {
        XCTAssertEqual(metadata.cameraName, "TestVideo Camera Name")
        XCTAssertEqual(metadata.rawToLogConversion, "0") // TODO: should be `Bool` instead of `String`?
        XCTAssertEqual(metadata.colorProfile, "SD (6-1-6)")
        XCTAssertEqual(metadata.cameraISO, "120")
        XCTAssertEqual(metadata.cameraColorTemperature, "0")
        XCTAssertEqual(metadata.codecs, ["'avc1'", "MPEG-4 AAC"])
        XCTAssertEqual(metadata.ingestDate, "2023-01-01 19:46:28 -0800")
        XCTAssertEqual(metadata.reel, "TestVideo Reel")
        XCTAssertEqual(metadata.scene, "TestVideo Scene")
        XCTAssertEqual(metadata.take, "TestVideo Take")
        XCTAssertEqual(metadata.cameraAngle, "TestVideo Camera Angle")
    }
    
    func testMetadatum() throws {
        let metadatum = FinalCutPro.FCPXML.Metadata.Metadatum()
        
        metadatum.key = .ingestDate
        XCTAssertEqual(metadatum.key, .ingestDate)
        
        metadatum.keyString = "com.domain.some.key"
        XCTAssertEqual(metadatum.keyString, "com.domain.some.key")
        XCTAssertEqual(metadatum.key, nil) // will be nil since the key isn't recognized
        
        metadatum.value = "Value String"
        XCTAssertEqual(metadatum.value, "Value String")
        
        metadatum.editable = true
        XCTAssertEqual(metadatum.editable, true)
        
        metadatum.type = .timecode
        XCTAssertEqual(metadatum.type, .timecode)
        
        metadatum.displayName = "Some MD Name"
        XCTAssertEqual(metadatum.displayName, "Some MD Name")
        
        metadatum.displayDescription = "Description of some MD."
        XCTAssertEqual(metadatum.displayDescription, "Description of some MD.")
    }
    
    func testAsset() throws {
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
            frameDuration: Fraction(200, 5000),
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
        XCTAssertEqual(format.frameDuration, Fraction(200, 5000))
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
    
    // MARK: - Textual
    
    func testText() {
        let text = FinalCutPro.FCPXML.Text(
            displayStyle: .rollUp,
            rollUpHeight: "20",
            position: "50 200",
            placement: .left,
            alignment: .right
        )
        
        XCTAssertEqual(text.displayStyle, .rollUp)
        XCTAssertEqual(text.rollUpHeight, "20")
        XCTAssertEqual(text.position, "50 200")
        XCTAssertEqual(text.placement, .left)
        XCTAssertEqual(text.alignment, .right)
    }
    
    // MARK: - Structure
    
    func testLibrary() throws {
        let url = try XCTUnwrap(URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/"))
        
        let library = FinalCutPro.FCPXML.Library(
            location: url
        )
        
        XCTAssertEqual(library.location, url)
    }
    
    func testEvent() {
        let event = FinalCutPro.FCPXML.Event(
            name: "Event name",
            uid: "a98msduf8masdu8f"
        )
        
        XCTAssertEqual(event.name, "Event name")
        XCTAssertEqual(event.uid, "a98msduf8masdu8f")
    }
    
    func testProject() {
        let project = FinalCutPro.FCPXML.Project(
            name: "Project name",
            id: "asd8fn08n",
            uid: "js9ajdf9dj",
            modDate: "2022-12-30 20:47:39 -0800"
        )
        
        XCTAssertEqual(project.name, "Project name")
        XCTAssertEqual(project.id, "asd8fn08n")
        XCTAssertEqual(project.uid, "js9ajdf9dj")
        XCTAssertEqual(project.modDate, "2022-12-30 20:47:39 -0800")
    }
    
    // MARK: - Misc.
    
    func testConformRateA() {
        let conformRate = FinalCutPro.FCPXML.ConformRate(
            scaleEnabled: true,
            srcFrameRate: .fps24,
            frameSampling: .frameBlending
        )
        
        XCTAssertEqual(conformRate.scaleEnabled, true)
        XCTAssertEqual(conformRate.srcFrameRate, .fps24)
        XCTAssertEqual(conformRate.frameSampling, .frameBlending)
    }
    
    func testConformRateB() {
        let conformRate = FinalCutPro.FCPXML.ConformRate(
            scaleEnabled: false,
            srcFrameRate: nil,
            frameSampling: .floor
        )
        
        XCTAssertEqual(conformRate.scaleEnabled, false)
        XCTAssertEqual(conformRate.srcFrameRate, nil)
        XCTAssertEqual(conformRate.frameSampling, .floor)
    }
    
    func testTimeMapA() {
        let timeMap = FinalCutPro.FCPXML.TimeMap(
            frameSampling: .nearestNeighbor,
            preservesPitch: false
        )
        
        XCTAssertEqual(timeMap.frameSampling, .nearestNeighbor)
        XCTAssertEqual(timeMap.preservesPitch, false)
        
        let readTimePoints = Array(timeMap.timePoints)
        XCTAssertEqual(readTimePoints.count, 0)
    }
    
    func testTimeMapB() {
        let timePoints: [FinalCutPro.FCPXML.TimeMap.TimePoint] = [timePoint]
        
        let timeMap = FinalCutPro.FCPXML.TimeMap(
            frameSampling: .floor,
            preservesPitch: true,
            timePoints: timePoints
        )
        
        XCTAssertEqual(timeMap.frameSampling, .floor)
        XCTAssertEqual(timeMap.preservesPitch, true)
        
        let readTimePoints = Array(timeMap.timePoints)
        XCTAssertEqual(readTimePoints.count, 1)
        XCTAssertEqual(readTimePoints, timePoints)
    }
    
    let timePoint = FinalCutPro.FCPXML.TimeMap.TimePoint(
        time: Fraction(2, 1),
        originalTime: Fraction(1, 1),
        interpolation: .linear,
        transitionInTime: Fraction(3, 1),
        transitionOutTime: Fraction(4, 1)
    )
    
    func testTimePoint() {
        XCTAssertEqual(timePoint.time, Fraction(2, 1))
        XCTAssertEqual(timePoint.originalTime, Fraction(1, 1))
        XCTAssertEqual(timePoint.interpolation, .linear)
        XCTAssertEqual(timePoint.transitionInTime, Fraction(3, 1))
        XCTAssertEqual(timePoint.transitionOutTime, Fraction(4, 1))
    }
}

#endif
