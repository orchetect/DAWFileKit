//
//  DAWMarker.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

/// DAW-agnostic timeline marker.
public struct DAWMarker {
    // MARK: Contents
    
    /// The core time value storage.
    /// Regardless of type, the value must always represent time elapsed from zero (00:00:00:00).
    public var timeStorage: Storage? = nil
    
    /// Main text of the marker.
    public var name: String = ""
    
    /// Comment associated with marker. Not all DAWs support comments; mainly Pro Tools.
    public var comment: String?
    
    // MARK: Init
    
    public init() { }
    
    public init(
        storage: Storage? = nil,
        name: String = "",
        comment: String? = nil
    ) {
        timeStorage = storage
        self.name = name
        self.comment = comment
    }
}

extension DAWMarker: Equatable {
    public static func == (lhs: DAWMarker, rhs: DAWMarker) -> Bool {
        guard let lhsTC = lhs.convertToTimecodeForComparison(limit: .max100Days),
              let rhsTC = rhs.convertToTimecodeForComparison(limit: .max100Days)
        else { return false }
        
        return lhsTC == rhsTC
    }
}

extension DAWMarker: Comparable {
    // useful for sorting markers or comparing markers chronologically
    // this is purely linear, and does not consider 24-hour wrap around.
    public static func < (lhs: DAWMarker, rhs: DAWMarker) -> Bool {
        guard let lhsTC = lhs.convertToTimecodeForComparison(limit: .max100Days),
              let rhsTC = rhs.convertToTimecodeForComparison(limit: .max100Days)
        else { return false }
        
        return lhsTC < rhsTC
    }
}

extension DAWMarker: Hashable { }

extension DAWMarker: Sendable { }

extension DAWMarker: Codable { }
