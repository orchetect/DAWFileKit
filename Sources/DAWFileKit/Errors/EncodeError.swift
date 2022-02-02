//
//  ParseError.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

import Foundation

extension Cubase.TrackArchive {
    
    public enum EncodeError: Error {
        
        case general(String)
        
    }
    
}

extension ProTools.SessionInfo {
    
    public enum EncodeError: Error {
        
        case general(String)
        
    }
    
}
