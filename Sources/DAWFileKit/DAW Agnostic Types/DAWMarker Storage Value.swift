//
//  DAWMarker Storage Value.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKit

extension DAWMarker.Storage {
    public enum Value: Equatable, Hashable {
        /// Real time in seconds, relative to the start time.
        case realTime(relativeToStart: TimeInterval)
        
        /// Timecode string, absolute timestamp (not an interval from start time).
        case timecodeString(absolute: String)
        
        case rational(relativeToStart: Fraction)
        
        /// Returns the backing storage formatted as a string, for use in writing to the document
        /// file.
        public var stringValue: String {
            switch self {
            case let .realTime(time):
                return time.stringValueHighPrecision
                
            case let .timecodeString(string):
                return string
                
            case let .rational(fraction):
                return fraction.fcpxmlStringValue
            }
        }
        
        /// Returns whether persistent storage of the marker's associated original frame rate is
        /// required to convert to real time.
        public var requiresOriginalFrameRate: Bool {
            switch self {
            case .realTime: return false
            case .timecodeString: return true
            case .rational: return false
            }
        }
    }
}

extension DAWMarker.Storage.Value: Codable {
    enum CodingKeys: CodingKey {
        case realTime
        case timecodeString
        case rational
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        var lastError: Error?
        
        // parse
        
        do {
            let value = try container.decode(TimeInterval.self, forKey: .realTime)
            self = .realTime(relativeToStart: value)
            return
        } catch { lastError = error }
        
        do {
            let value = try container.decode(String.self, forKey: .timecodeString)
            // framerate is inconsequential for testing string format, so arbitrary 30fps is fine
            let isTimecode = (try? Timecode(.string(value), at: .fps30, by: .allowingInvalid)) != nil
            guard isTimecode else {
                throw DecodingError
                    .dataCorrupted(.init(
                        codingPath: container.codingPath,
                        debugDescription: "Timecode string was stored but could not be parsed. The string may not be formatted as valid timecode."
                    ))
            }
            self = .timecodeString(absolute: value)
            return
        } catch { lastError = error }
        
        do {
            let value = try container.decode(String.self, forKey: .rational)
            guard let fraction = Fraction(fcpxmlString: value) else {
                throw DecodingError
                    .dataCorrupted(.init(
                        codingPath: container.codingPath,
                        debugDescription: "Rational fraction value was stored but could not be parsed. The string may not be encoded correctly."
                    ))
            }
            
            self = .rational(relativeToStart: fraction)
            return
        } catch { lastError = error }
        
        // if no known keys are found, throw the last error that was stored
        if let lastError = lastError {
            throw lastError
        }
        
        // if no error was stored, throw a generic failure
        throw DecodingError
            .dataCorrupted(.init(
                codingPath: container.codingPath,
                debugDescription: "Key not found, or wrong value type."
            ))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .realTime(value):
            try container.encode(value, forKey: .realTime)
        case let .timecodeString(value):
            try container.encode(value, forKey: .timecodeString)
        case let .rational(fraction):
            try container.encode(fraction.fcpxmlStringValue, forKey: .rational)
        }
    }
}
