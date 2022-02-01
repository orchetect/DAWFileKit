//
//  SessionInfo Init.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

// MARK: - Parse methods

extension ProTools.SessionInfo {
    
    /// Parse text file contents exported from Pro Tools.
    public init?(data: Data) {
        guard let dataToString = String(data: data, encoding: .ascii) else {
            logger.debug("Error: could not convert document file data to String.")
            return nil
        }
        
        logger.debug("Successfully loaded file. Total byte count:", dataToString.count)
        
        if let parsed = Self(string: dataToString) {
            self = parsed
        } else {
            return nil
        }
        
    }
    
    /// Parse text file contents exported from Pro Tools.
    public init?(string: String) {
        
        guard let parsed = Self.parse(string: string) else {
            return nil
        }
        
        self = parsed
        
    }
    
}
