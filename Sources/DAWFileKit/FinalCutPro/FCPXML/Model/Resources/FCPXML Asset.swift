//
//  FCPXML Asset.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Asset shared resource.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Define file-based media managed in a Final Cut Pro library.
    /// >
    /// > Use the `asset` element to define a file-based media. A file-based media can have an
    /// > original media representation and a proxy media representation. Describe those using the
    /// > `media-rep` element along with file URLs for the media files.
    /// >
    /// > See [`asset`](https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/asset).
    public enum Asset { }
}

extension FinalCutPro.FCPXML.Asset {
    public static let resourceType: FinalCutPro.FCPXML.ResourceType = .asset
    
    public enum Attributes {
        // shared resource attributes
        case id // required
        case name
        
        // base attributes
        case start
        case duration
        case format
        
        // asset attributes
        case uid
        
        // implied asset attributes
        case hasAudio // default false
        case hasVideo // default false
        case audioSources // default 0
        case audioChannels // default 0
        case audioRate // Int Hz
        case videoSources // default 0
        case auxVideoFlags
    }
    
    public enum Children: String {
        case mediaRep = "media-rep"
        case metadata
    }
}

#endif
