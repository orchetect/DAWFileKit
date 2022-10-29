//
//  DAWMarker Storage Value.swift
//  MarkerToolShared
//
//  Created by Steffan Andrews on 2020-07-30.
//  Copyright © 2020 Steffan Andrews. All rights reserved.
//

import Foundation
import TimecodeKit

extension DAWMarker.Storage {
    public enum Value {
        case realTime(TimeInterval)
        case timecodeString(String)
        
        /// Returns the backing storage formatted as a string, for use in writing to the document file.
        public var stringValue: String {
            switch self {
            case let .realTime(time):
                return time.stringValueHighPrecision
                
            case let .timecodeString(string):
                return string
            }
        }
        
        /// Returns whether persistent storage of the marker's associated original frame rate is required
        public var requiresOriginalFrameRate: Bool {
            switch self {
            case .realTime: return false
            case .timecodeString: return true
            }
        }
    }
}

extension DAWMarker.Storage.Value: Codable {
    enum CodingKeys: CodingKey {
        case realTime
        case timecodeString
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        var lastError: Error?
        
        // parse
        
        do {
            let value = try container.decode(TimeInterval.self, forKey: .realTime)
            self = .realTime(value)
            return
        } catch { lastError = error }
        
        do {
            let value = try container.decode(String.self, forKey: .timecodeString)
            self = .timecodeString(value)
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
            do {
                try container.encode(value, forKey: .realTime)
            } catch {
                throw error
            }
        case let .timecodeString(value):
            do {
                try container.encode(value, forKey: .timecodeString)
            } catch {
                throw error
            }
        }
    }
}
