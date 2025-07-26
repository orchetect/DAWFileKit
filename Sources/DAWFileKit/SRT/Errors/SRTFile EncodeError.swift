//
//  SRTFile EncodeError.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension SRTFile {
    public enum EncodeError: LocalizedError {
        case encodeError
        
        public var errorDescription: String? {
            switch self {
            case .encodeError:
                return "Failed to encode SRT file data."
            }
        }
    }
}
