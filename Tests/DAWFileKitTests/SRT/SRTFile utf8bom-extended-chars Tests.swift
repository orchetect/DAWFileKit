//
//  SRTFile utf8bom-extended-chars Tests.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileKit
import OTCore
import Testing
import TimecodeKit

@Suite struct SRTFile_utf8BOMExtendedCharsTests {
    @Test
    func decodeSRT_BOM_CRLF_ExtendedChars() throws {
        // load file
        
        let filename = "SRT-BOM-CRLF-ExtendedChars"
        guard let rawData = loadFileContents(
            forResource: filename,
            withExtension: "srt",
            subFolder: .srtFiles
        )
        else { Issue.record("Could not form URL, possibly could not find file."); return }
        
        // parse
        
        let srtFile = try SRTFile(fileContent: rawData)
        
        #expect(srtFile.encoding == .utf8)
        try #require(srtFile.subtitles.count == 5)
        
        let subtitle1 = srtFile.subtitles[0]
        #expect(subtitle1.timeRange.lowerBound == Time(hours: 0, minutes: 0, seconds: 36, milliseconds: 038))
        #expect(subtitle1.timeRange.upperBound == Time(hours: 0, minutes: 0, seconds: 40, milliseconds: 944))
        #expect(
            subtitle1.text == ##"- <font color="#D81D1D">Subtitles Author</font> -"##
                + "\n" + ##"-- <font color="#138CE7">www.example.com</font> --"##
        )
        #expect(subtitle1.textCoordinates == nil)
        
        let subtitle2 = srtFile.subtitles[1]
        #expect(subtitle2.timeRange.lowerBound == Time(hours: 0, minutes: 5, seconds: 33, milliseconds: 959))
        #expect(subtitle2.timeRange.upperBound == Time(hours: 0, minutes: 5, seconds: 35, milliseconds: 961))
        #expect(subtitle2.text == "Hello.")
        #expect(subtitle2.textCoordinates == nil)
        
        let subtitle3 = srtFile.subtitles[2]
        #expect(subtitle3.timeRange.lowerBound == Time(hours: 0, minutes: 5, seconds: 38, milliseconds: 005))
        #expect(subtitle3.timeRange.upperBound == Time(hours: 0, minutes: 5, seconds: 40, milliseconds: 130))
        #expect(subtitle3.text == "Where are you?")
        #expect(subtitle3.textCoordinates == nil)
        
        let subtitle4 = srtFile.subtitles[3]
        #expect(subtitle4.timeRange.lowerBound == Time(hours: 0, minutes: 55, seconds: 46, milliseconds: 427))
        #expect(subtitle4.timeRange.upperBound == Time(hours: 0, minutes: 55, seconds: 50, milliseconds: 383))
        #expect(subtitle4.text == "♪ Song lyric ♪")
        #expect(subtitle4.textCoordinates == nil)
        
        let subtitle5 = srtFile.subtitles[4]
        #expect(subtitle5.timeRange.lowerBound == Time(hours: 0, minutes: 55, seconds: 50, milliseconds: 380))
        #expect(subtitle5.timeRange.upperBound == Time(hours: 0, minutes: 55, seconds: 55, milliseconds: 306))
        #expect(subtitle5.text == "♪ Another song lyric ♪")
        #expect(subtitle5.textCoordinates == nil)
    }
}
