//
//  DAWMarker.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

/// DAW-agnostic timeline marker.
public struct DAWMarker: Codable {
    // MARK: Contents
    
    /// The core time value storage.
    /// Regardless of type, the value must always represent time elapsed from zero (00:00:00:00).
    public var timeStorage: Storage? = nil
    
    /// Main text of the marker.
    public var name: String = ""
    
    /// Comment associated with marker. Not all DAWs support comments; mainly Pro Tools.
    public var comment: String?
    
    // MARK: init
    
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

extension DAWMarker: Sendable { }
