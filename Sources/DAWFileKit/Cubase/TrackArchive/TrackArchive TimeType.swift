//
//  TrackArchive TimeType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    
    public enum TimeType: Int {
        
        case secondsOrBarsAndBeats = 0 // seconds and bars+beats both show up as 0
        case timecode = 4 // and 13?
        case samples = 10
        case user = 11
        
    }
    
}

#endif
