//
//  SRTFile Subtitle.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import OTCore
import TimecodeKit

extension SRTFile {
    /// An individual subtitle (caption) contained within an SRT file.
    ///
    /// Example:
    ///
    /// ```
    /// 1
    /// 00:00:05,217 --> 00:00:10,854
    /// This is the first subtitle.
    /// ```
    public struct Subtitle {
        /// Timestamp range (in and out times).
        ///
        /// Note that these are wall-clock timestamps and not timecodes (which need to be converted to timestamps).
        public var timeRange: ClosedRange<Time>
        
        /// Subtitle (caption) text to display on-screen.
        public var text: String
        
        /// Unofficially, text coordinates can be specified at the end of the timestamp line as `X1:… X2:… Y1:… Y2:…`.
        public var textCoordinates: TextCoordinates?
        
        public init(
            timeRange: ClosedRange<Time>,
            text: String,
            textCoordinates: TextCoordinates?
        ) {
            self.timeRange = timeRange
            self.text = text
            self.textCoordinates = textCoordinates
        }
    }
}

extension SRTFile.Subtitle: Equatable { }

extension SRTFile.Subtitle: Hashable { }

extension SRTFile.Subtitle: Sendable { }

// MARK: - Time Conversions

extension SRTFile.Subtitle {
    /// Initialize by converting a timecode range to a wall-clock time range which the SRT format uses.
    public init(
        timeRange: ClosedRange<Timecode>,
        text: String,
        textCoordinates: TextCoordinates?
    ) {
        let inTime = Time(seconds: timeRange.lowerBound.realTimeValue)
        let outTime = Time(seconds: timeRange.upperBound.realTimeValue)
        self.timeRange = inTime ... outTime
        
        self.text = text
        
        self.textCoordinates = textCoordinates
    }
    
    /// Returns the wall-clock time range converted to a timecode range.
    public func timeRangeAsTimecode(
        at frameRate: TimecodeFrameRate,
        base: Timecode.SubFramesBase = .max100SubFrames,
        limit: Timecode.UpperLimit = .max24Hours
    ) throws -> ClosedRange<Timecode> {
        let inTime = try Timecode(
            .realTime(seconds: timeRange.lowerBound.interval),
            at: frameRate,
            base: base,
            limit: limit
        )
        let outTime = try Timecode(
            .realTime(seconds: timeRange.upperBound.interval),
            at: frameRate,
            base: base,
            limit: limit
        )
        return inTime ... outTime
    }
}

// MARK: - Raw Data

extension SRTFile.Subtitle {
    /// Initialize by parsing raw subtitle data block from an SRT file.
    public init(string: String) throws {
        // accommodate text coordinates at the end of the timestamp line
        
        let lines = string
            .trimmingCharacters(in: .newlines)
            .split(separator: "\n")
        
        guard lines.count == 3 else {
            throw SRTFile.DecodeError.unexpectedLineCount
        }
        
        guard let sequenceNumber = lines[0].int else {
            throw SRTFile.DecodeError.invalidSequenceNumber
        }
        _ = sequenceNumber // don't store seq number, since it's regenerated on file write
        
        let timeStampPattern = #"^(\d{2}:\d{2}:\d{2},\d{3}) --> (\d{2}:\d{2}:\d{2},\d{3})(.*)$"#
        let timeStampMatches = lines[1].regexMatches(captureGroupsFromPattern: timeStampPattern)
        guard timeStampMatches.count == 4,
              let timeInString = timeStampMatches[1],
              let timeIn = Time(srtEncodedString: timeInString),
              let timeOutString = timeStampMatches[2],
              let timeOut = Time(srtEncodedString: timeOutString)
        else {
            throw SRTFile.DecodeError.invalidTimeStamps
        }
        
        // validation: ensure time range is chronological
        guard timeIn <= timeOut else {
            throw SRTFile.DecodeError.invalidTimeStamps
        }
        
        timeRange = timeIn ... timeOut
        
        if let textCoordinatesString = timeStampMatches[3]?.trimmed,
           !textCoordinatesString.isEmpty
        {
            let coordPattern = #"x1:(\d{1,5}) x2:(\d{1,5}) y1:(\d{1,5}) y2:(\d{1,5})"#
            let coordMatches = textCoordinatesString.regexMatches(
                captureGroupsFromPattern: coordPattern,
                options: .caseInsensitive,
                matchesOptions: []
            )
            if coordMatches.count == 5,
               let x1 = coordMatches[1]?.int,
               let x2 = coordMatches[2]?.int,
               let y1 = coordMatches[3]?.int,
               let y2 = coordMatches[4]?.int
            {
                textCoordinates = TextCoordinates(x1: x1, x2: x2, y1: y1, y2: y2)
            }
            
        } else {
            textCoordinates = nil
        }
        
        text = String(lines[2])
    }
    
    /// Returns the subtitle data encoded for an SRT file.
    public func rawData(
        sequenceNumber: Int
    ) -> String {
        var output = ""
        
        output += "\(sequenceNumber)\n"
        
        let inTime = timeRange.lowerBound.srtEncodedString()
        let outTime = timeRange.upperBound.srtEncodedString()
        output += "\(inTime) --> \(outTime)"
        
        if let c = textCoordinates {
            output += " X1:\(c.x1) X2:\(c.x2) Y1:\(c.y1) Y2:\(c.y2)"
        }
        output += "\n"
        
        output += text
        
        return output
    }
}
