//
//  SRTFile DecodeError.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension SRTFile {
    public enum DecodeError: LocalizedError {
        case unrecognizedTextEncoding
        case unexpectedLineCount
        case invalidSequenceNumber
        case invalidTimeStamps
        
        public var errorDescription: String? {
            switch self {
            case .unrecognizedTextEncoding:
                "Unrecognized text encoding."
            case .unexpectedLineCount:
                "Unexpected number of lines encountered while parsing a subtitle."
            case .invalidSequenceNumber:
                "Invalid sequence number encountered while parsing a subtitle."
            case .invalidTimeStamps:
                "Invalid timestamps encountered while parsing a subtitle."
            }
        }
    }
}
