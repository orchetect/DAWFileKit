//
//  SRTFile Subtitle Tests.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileKit
import OTCore
import Testing
import TimecodeKit

@Suite struct SRTFileSubtitleDecodeTests {
    @Test
    func decodeSubtitle() throws {
        let encoded = """
            1
            00:00:05,217 --> 00:00:10,854
            This is the first subtitle.
            """
        
        let subtitle = try SRTFile.Subtitle(string: encoded)
        
        #expect(subtitle.timeRange.lowerBound == Time(hours: 0, minutes: 0, seconds: 5, milliseconds: 217))
        #expect(subtitle.timeRange.upperBound == Time(hours: 0, minutes: 0, seconds: 10, milliseconds: 854))
        #expect(subtitle.text == "This is the first subtitle.")
        #expect(subtitle.textCoordinates == nil)
    }
    
    @Test
    func decodeSubtitle_InvalidSequenceNumber_A() throws {
        let encoded = """
            A
            00:00:05,217 --> 00:00:10,854
            This is the first subtitle.
            """
        
        #expect(throws: SRTFile.DecodeError.invalidSequenceNumber) {
            try SRTFile.Subtitle(string: encoded)
        }
    }
    
    @Test
    func decodeSubtitle_InvalidSequenceNumber_Empty() throws {
        let encoded = """
            
            00:00:05,217 --> 00:00:10,854
            This is the first subtitle.
            """
        
        #expect(throws: SRTFile.DecodeError.invalidSequenceNumber) {
            try SRTFile.Subtitle(string: encoded)
        }
    }
    
    @Test
    func decodeSubtitle_InvalidSequenceNumber_0() throws {
        let encoded = """
            0
            00:00:05,217 --> 00:00:10,854
            This is the first subtitle.
            """
        
        // even though sequence numbers should start at 1, we won't consider 0 an error case
        _ = try SRTFile.Subtitle(string: encoded)
    }
    
    /// Technically, identical in and out timestamps are allowed.
    @Test
    func decodeSubtitle_IdenticalInOutTimestamps() throws {
        let encoded = """
            1
            00:00:05,217 --> 00:00:05,217
            This is the first subtitle.
            """
        
        let subtitle = try SRTFile.Subtitle(string: encoded)
        
        #expect(subtitle.timeRange.lowerBound == Time(hours: 0, minutes: 0, seconds: 5, milliseconds: 217))
        #expect(subtitle.timeRange.upperBound == Time(hours: 0, minutes: 0, seconds: 5, milliseconds: 217))
        #expect(subtitle.text == "This is the first subtitle.")
        #expect(subtitle.textCoordinates == nil)
    }
    
    @Test
    func decodeSubtitle_NonChronologicalTimestamps() throws {
        let encoded = """
            1
            00:00:10,854 --> 00:00:05,217
            This is the first subtitle.
            """
        
        #expect(throws: SRTFile.DecodeError.invalidTimeStamps) {
            try SRTFile.Subtitle(string: encoded)
        }
    }
    
    @Test
    func decodeSubtitle_WithUnofficialTextCoordinates() throws {
        let encoded = """
            1
            01:12:14,850 --> 01:12:22,074 X1:100 X2:200 Y1:300 Y2:400
            This is the first subtitle.
            """
        
        let subtitle = try SRTFile.Subtitle(string: encoded)
        
        #expect(subtitle.timeRange.lowerBound == Time(hours: 1, minutes: 12, seconds: 14, milliseconds: 850))
        #expect(subtitle.timeRange.upperBound == Time(hours: 1, minutes: 12, seconds: 22, milliseconds: 074))
        #expect(subtitle.text == "This is the first subtitle.")
        #expect(subtitle.textCoordinates == SRTFile.Subtitle.TextCoordinates(x1: 100, x2: 200, y1: 300, y2: 400))
    }
    
    // TODO: write additional tests
}

@Suite struct SRTFileSubtitleEncodeTests {
    @Test
    func encodeSubtitle() throws {
        let inTime = Time(hours: 0, minutes: 0, seconds: 5, milliseconds: 217)
        let outTime = Time(hours: 0, minutes: 0, seconds: 10, milliseconds: 854)
        let subtitle = SRTFile.Subtitle(
            timeRange: inTime ... outTime,
            text: "This is the second subtitle.",
            textCoordinates: nil
        )
        
        let expectedEncoded = """
            2
            00:00:05,217 --> 00:00:10,854
            This is the second subtitle.
            """
        
        let encoded = subtitle.rawData(sequenceNumber: 2)
        
        #expect(encoded == expectedEncoded)
    }
    
    @Test
    func encodeSubtitle_WithUnofficialTextCoordinates() throws {
        let inTime = Time(hours: 0, minutes: 0, seconds: 5, milliseconds: 217)
        let outTime = Time(hours: 0, minutes: 0, seconds: 10, milliseconds: 854)
        let subtitle = SRTFile.Subtitle(
            timeRange: inTime ... outTime,
            text: "This is the third subtitle.",
            textCoordinates: SRTFile.Subtitle.TextCoordinates(x1: 100, x2: 200, y1: 300, y2: 400)
        )
        
        let expectedEncoded = """
            3
            00:00:05,217 --> 00:00:10,854 X1:100 X2:200 Y1:300 Y2:400
            This is the third subtitle.
            """
        
        let encoded = subtitle.rawData(sequenceNumber: 3)
        
        #expect(encoded == expectedEncoded)
    }
}
