//
//  TrackArchive TrackTimeDomain.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    
    public enum TrackTimeDomain: Int {
        
        /// Bars & beats timebase - computations are against PPQ base and tempo
        case musical = 0
        
        /// Time linear timebase (real / absolute time)
        case linear = 1
        
    }
    
}

#endif
