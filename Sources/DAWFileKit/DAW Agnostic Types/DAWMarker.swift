//
//  DAWMarker.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

public struct DAWMarker {
    // MARK: Contents
    
    /// The core time value storage.
    /// Regardless of type, the value must always represent time elapsed from zero (00:00:00:00).
    ///
    /// If the marker was imported from a file, its original format is preserved here.
    /// Conceivably, if the user edits or processes the data, the application can (and probably will) overwrite this with the new data format.
    /// However this should remain intact in its original format as long as possible (while loaded, displayed, and saved back to a file) to retain as much precision as long as possible.
    public var timeStorage: Storage? = nil
    
    /// Main text of the marker.
    public var name: String = ""
    
    /// Comment associated with marker. Not all DAWs support comments, mainly Pro Tools.
    public var comment: String?
    
    // MARK: init
    
    public init() { }
    
    public init(
        storage: Storage,
        name: String = "",
        comment: String? = nil
    ) {
        timeStorage = storage
        
        self.name = name
        self.comment = comment
    }
}
