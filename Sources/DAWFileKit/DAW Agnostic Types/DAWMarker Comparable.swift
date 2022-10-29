//
//  DAWMarker Comparable.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

// useful for sorting markers or comparing markers chronologically

extension DAWMarker: Comparable {
    public static func < (lhs: DAWMarker, rhs: DAWMarker) -> Bool {
        let lhsSFD = lhs.timeStorage?.base ?? ._80SubFrames
        let rhsSFD = rhs.timeStorage?.base ?? ._80SubFrames
        
        if let lhsTC = lhs.originalTimecode(
            limit: ._100days,
            base: lhsSFD
        ),
           let rhsTC = rhs.originalTimecode(
            limit: ._100days,
            base: rhsSFD
           )
        {
            return lhsTC < rhsTC
            
        } else {
            return false
        }
    }
}

extension DAWMarker: Equatable {
    public static func == (lhs: DAWMarker, rhs: DAWMarker) -> Bool {
        let lhsSFD = lhs.timeStorage?.base ?? ._80SubFrames
        let rhsSFD = rhs.timeStorage?.base ?? ._80SubFrames
        
        if let lhsTC = lhs.originalTimecode(
            limit: ._100days,
            base: lhsSFD
        ),
           let rhsTC = rhs.originalTimecode(
            limit: ._100days,
            base: rhsSFD
           )
        {
            return lhsTC == rhsTC
            
        } else {
            return false
        }
    }
}
