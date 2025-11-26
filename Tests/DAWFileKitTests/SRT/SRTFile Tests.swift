//
//  SRTFile Tests.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileKit
import SwiftExtensions
import Testing
import TimecodeKit

@Suite struct SRTFileDecodeTests {
    @Test
    func decodeSRT_EmptyFile() throws {
        let srtFile = try SRTFile(fileContent: "", encoding: .utf8)
        
        #expect(srtFile.encoding == .utf8)
        #expect(srtFile.subtitles.count == 0)
    }
    
    @Test
    func decodeSRT_OneSubtitle() throws {
        let encoded = """
            1
            00:00:05,217 --> 00:00:10,854
            This is the first subtitle.
            """
        
        let srtFile = try SRTFile(fileContent: encoded)
        
        #expect(srtFile.encoding == .windowsCP1252) // default
        try #require(srtFile.subtitles.count == 1)
        
        let subtitle = srtFile.subtitles[0]
        #expect(subtitle.timeRange.lowerBound == Time(hours: 0, minutes: 0, seconds: 5, milliseconds: 217))
        #expect(subtitle.timeRange.upperBound == Time(hours: 0, minutes: 0, seconds: 10, milliseconds: 854))
        #expect(subtitle.text == "This is the first subtitle.")
        #expect(subtitle.textCoordinates == nil)
    }
    
    @Test
    func decodeSRT_TwoSubtitles() throws {
        let encoded = """
            1
            00:00:05,217 --> 00:00:10,854
            This is the first subtitle.
            
            2
            00:00:12,100 --> 00:00:13,200 X1:100 X2:200 Y1:300 Y2:400
            This is the second subtitle.
            """
        
        let srtFile = try SRTFile(fileContent: encoded)
        
        #expect(srtFile.encoding == .windowsCP1252) // default
        try #require(srtFile.subtitles.count == 2)
        
        let subtitle1 = srtFile.subtitles[0]
        #expect(subtitle1.timeRange.lowerBound == Time(hours: 0, minutes: 0, seconds: 5, milliseconds: 217))
        #expect(subtitle1.timeRange.upperBound == Time(hours: 0, minutes: 0, seconds: 10, milliseconds: 854))
        #expect(subtitle1.text == "This is the first subtitle.")
        #expect(subtitle1.textCoordinates == nil)
        
        let subtitle2 = srtFile.subtitles[1]
        #expect(subtitle2.timeRange.lowerBound == Time(hours: 0, minutes: 0, seconds: 12, milliseconds: 100))
        #expect(subtitle2.timeRange.upperBound == Time(hours: 0, minutes: 0, seconds: 13, milliseconds: 200))
        #expect(subtitle2.text == "This is the second subtitle.")
        #expect(subtitle2.textCoordinates == SRTFile.Subtitle.TextCoordinates(x1: 100, x2: 200, y1: 300, y2: 400))
    }
    
    @Test
    func decodeSRT_TwoSubtitlesMultiline() throws {
        let encoded = """
            1
            00:00:05,217 --> 00:00:10,854
            This is the first subtitle
            with another line here.
            
            2
            00:00:12,100 --> 00:00:13,200 X1:100 X2:200 Y1:300 Y2:400
            This is the second subtitle
            with yet another line here.
            """
        
        let srtFile = try SRTFile(fileContent: encoded)
        
        #expect(srtFile.encoding == .windowsCP1252) // default
        try #require(srtFile.subtitles.count == 2)
        
        let subtitle1 = srtFile.subtitles[0]
        #expect(subtitle1.timeRange.lowerBound == Time(hours: 0, minutes: 0, seconds: 5, milliseconds: 217))
        #expect(subtitle1.timeRange.upperBound == Time(hours: 0, minutes: 0, seconds: 10, milliseconds: 854))
        #expect(subtitle1.text == "This is the first subtitle\nwith another line here.")
        #expect(subtitle1.textCoordinates == nil)
        
        let subtitle2 = srtFile.subtitles[1]
        #expect(subtitle2.timeRange.lowerBound == Time(hours: 0, minutes: 0, seconds: 12, milliseconds: 100))
        #expect(subtitle2.timeRange.upperBound == Time(hours: 0, minutes: 0, seconds: 13, milliseconds: 200))
        #expect(subtitle2.text == "This is the second subtitle\nwith yet another line here.")
        #expect(subtitle2.textCoordinates == SRTFile.Subtitle.TextCoordinates(x1: 100, x2: 200, y1: 300, y2: 400))
    }
    
    @Test
    func decodeSRT_TwoSubtitles_NonConsecutiveSequenceNumbers() throws {
        let encoded = """
            2
            00:00:05,217 --> 00:00:10,854
            This is the first subtitle.
            
            4
            00:00:12,100 --> 00:00:13,200 X1:100 X2:200 Y1:300 Y2:400
            This is the second subtitle.
            """
        
        let srtFile = try SRTFile(fileContent: encoded)
        
        #expect(srtFile.encoding == .windowsCP1252) // default
        try #require(srtFile.subtitles.count == 2)
        
        let subtitle1 = srtFile.subtitles[0]
        #expect(subtitle1.timeRange.lowerBound == Time(hours: 0, minutes: 0, seconds: 5, milliseconds: 217))
        #expect(subtitle1.timeRange.upperBound == Time(hours: 0, minutes: 0, seconds: 10, milliseconds: 854))
        #expect(subtitle1.text == "This is the first subtitle.")
        #expect(subtitle1.textCoordinates == nil)
        
        let subtitle2 = srtFile.subtitles[1]
        #expect(subtitle2.timeRange.lowerBound == Time(hours: 0, minutes: 0, seconds: 12, milliseconds: 100))
        #expect(subtitle2.timeRange.upperBound == Time(hours: 0, minutes: 0, seconds: 13, milliseconds: 200))
        #expect(subtitle2.text == "This is the second subtitle.")
        #expect(subtitle2.textCoordinates == SRTFile.Subtitle.TextCoordinates(x1: 100, x2: 200, y1: 300, y2: 400))
    }
    
    @Test
    func decodeSRT_TwoSubtitles_NonOrderedSequenceNumbers() throws {
        let encoded = """
            2
            00:00:05,217 --> 00:00:10,854
            This is the first subtitle.
            
            1
            00:00:12,100 --> 00:00:13,200 X1:100 X2:200 Y1:300 Y2:400
            This is the second subtitle.
            """
        
        let srtFile = try SRTFile(fileContent: encoded)
        
        #expect(srtFile.encoding == .windowsCP1252) // default
        try #require(srtFile.subtitles.count == 2)
        
        let subtitle1 = srtFile.subtitles[0]
        #expect(subtitle1.timeRange.lowerBound == Time(hours: 0, minutes: 0, seconds: 12, milliseconds: 100))
        #expect(subtitle1.timeRange.upperBound == Time(hours: 0, minutes: 0, seconds: 13, milliseconds: 200))
        #expect(subtitle1.text == "This is the second subtitle.")
        #expect(subtitle1.textCoordinates == SRTFile.Subtitle.TextCoordinates(x1: 100, x2: 200, y1: 300, y2: 400))
        
        let subtitle2 = srtFile.subtitles[1]
        #expect(subtitle2.timeRange.lowerBound == Time(hours: 0, minutes: 0, seconds: 5, milliseconds: 217))
        #expect(subtitle2.timeRange.upperBound == Time(hours: 0, minutes: 0, seconds: 10, milliseconds: 854))
        #expect(subtitle2.text == "This is the first subtitle.")
        #expect(subtitle2.textCoordinates == nil)
    }
    
    @Test
    func decodeSRT_ExtraLineBreaks1() throws {
        let encoded = """
            1
            00:00:05,000 --> 00:00:10,000
            This is the first subtitle.
            
            
            2
            00:00:12,100 --> 00:00:13,200
            This is the second subtitle.
            """
        
        let srtFile = try SRTFile(fileContent: encoded)
        
        #expect(srtFile.encoding == .windowsCP1252) // default
        #expect(srtFile.subtitles.count == 2)
    }
    
    @Test
    func decodeSRT_ExtraLineBreaks2() throws {
        let encoded = """
            
            1
            00:00:05,000 --> 00:00:10,000
            This is the first subtitle.
            
            2
            00:00:12,100 --> 00:00:13,200
            This is the second subtitle.
            """
        
        let srtFile = try SRTFile(fileContent: encoded)
        
        #expect(srtFile.encoding == .windowsCP1252) // default
        #expect(srtFile.subtitles.count == 2)
    }
    
    @Test
    func decodeSRT_ExtraLineBreaks3() throws {
        let encoded = """
            
            
            1
            00:00:05,000 --> 00:00:10,000
            This is the first subtitle.
            
            2
            00:00:12,100 --> 00:00:13,200
            This is the second subtitle.
            """
        
        let srtFile = try SRTFile(fileContent: encoded)
        
        #expect(srtFile.encoding == .windowsCP1252) // default
        #expect(srtFile.subtitles.count == 2)
    }
    
    // TODO: write additional tests
}

@Suite struct SRTFileEncodeTests {
    @Test
    func encodeSRT_EmptyFile() throws {
        let srtFile = SRTFile(subtitles: [])
        
        let data = try srtFile.rawData()
        
        #expect(data.isEmpty)
    }
    
    @Test
    func encodeSRT_OneSubtitle() throws {
        let inTime1 = Time(hours: 0, minutes: 0, seconds: 5, milliseconds: 217)
        let outTime1 = Time(hours: 0, minutes: 0, seconds: 10, milliseconds: 854)
        let subtitle1 = SRTFile.Subtitle(
            timeRange: inTime1 ... outTime1,
            text: "This is the first subtitle.",
            textCoordinates: nil
        )
        
        let srtFile = SRTFile(subtitles: [subtitle1])
        
        let rawText = try srtFile.rawString()
        
        let encoded = """
            1
            00:00:05,217 --> 00:00:10,854
            This is the first subtitle.
            """
        
        #expect(rawText == encoded)
    }
    
    @Test
    func encodeSRT_TwoSubtitles() throws {
        let inTime1 = Time(hours: 0, minutes: 0, seconds: 5, milliseconds: 217)
        let outTime1 = Time(hours: 0, minutes: 0, seconds: 10, milliseconds: 854)
        let subtitle1 = SRTFile.Subtitle(
            timeRange: inTime1 ... outTime1,
            text: "This is the first subtitle.",
            textCoordinates: nil
        )
        
        let inTime2 = Time(hours: 0, minutes: 0, seconds: 12, milliseconds: 100)
        let outTime2 = Time(hours: 0, minutes: 0, seconds: 13, milliseconds: 200)
        let subtitle2 = SRTFile.Subtitle(
            timeRange: inTime2 ... outTime2,
            text: "This is the second subtitle.",
            textCoordinates: SRTFile.Subtitle.TextCoordinates(x1: 100, x2: 200, y1: 300, y2: 400)
        )
        
        let srtFile = SRTFile(subtitles: [subtitle1, subtitle2])
        
        let rawText = try srtFile.rawString()
        
        let encoded = """
            1
            00:00:05,217 --> 00:00:10,854
            This is the first subtitle.
            
            2
            00:00:12,100 --> 00:00:13,200 X1:100 X2:200 Y1:300 Y2:400
            This is the second subtitle.
            """
        
        #expect(rawText == encoded)
    }
    
    @Test
    func encodeSRT_TwoSubtitlesMultiline() throws {
        let inTime1 = Time(hours: 0, minutes: 0, seconds: 5, milliseconds: 217)
        let outTime1 = Time(hours: 0, minutes: 0, seconds: 10, milliseconds: 854)
        let subtitle1 = SRTFile.Subtitle(
            timeRange: inTime1 ... outTime1,
            text: "This is the first subtitle\nwith another line here.",
            textCoordinates: nil
        )
        
        let inTime2 = Time(hours: 0, minutes: 0, seconds: 12, milliseconds: 100)
        let outTime2 = Time(hours: 0, minutes: 0, seconds: 13, milliseconds: 200)
        let subtitle2 = SRTFile.Subtitle(
            timeRange: inTime2 ... outTime2,
            text: "This is the second subtitle\nwith yet another line here.",
            textCoordinates: SRTFile.Subtitle.TextCoordinates(x1: 100, x2: 200, y1: 300, y2: 400)
        )
        
        let srtFile = SRTFile(subtitles: [subtitle1, subtitle2])
        
        let rawText = try srtFile.rawString()
        
        let encoded = """
            1
            00:00:05,217 --> 00:00:10,854
            This is the first subtitle
            with another line here.
            
            2
            00:00:12,100 --> 00:00:13,200 X1:100 X2:200 Y1:300 Y2:400
            This is the second subtitle
            with yet another line here.
            """
        
        #expect(rawText == encoded)
    }
}
