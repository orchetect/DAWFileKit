//
//  FCPXML Asset.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

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
    public struct Asset: Equatable, Hashable {
        // shared resource attributes
        public var id: String // required
        public var name: String?
        
        // base attributes
        public var start: String?
        public var duration: String?
        public var format: String?
        
        // asset attributes
        public var uid: String?
        
        // implied asset attributes
        public var hasVideo: Bool
        public var hasAudio: Bool
        public var audioSources: Int
        public var audioChannels: Int
        public var audioRate: Int?
        public var videoSources: Int
        public var auxVideoFlags: String?
        public var mediaRep: MediaRep?
        public var metadata: Metadata
        
        public init(
            // shared resource attributes
            id: String,
            name: String?,
            // base attributes
            start: String?,
            duration: String?,
            format: String?,
            // asset attributes
            uid: String?,
            // implied asset attributes
            hasVideo: Bool,
            hasAudio: Bool,
            audioSources: Int,
            audioChannels: Int,
            audioRate: Int?,
            videoSources: Int,
            auxVideoFlags: String?,
            mediaRep: MediaRep?,
            metadata: Metadata
        ) {
            // shared resource attributes
            self.id = id
            self.name = name
            
            // base attributes
            self.start = start
            self.duration = duration
            self.format = format
            
            // asset attributes
            self.uid = uid
            
            // implied asset attributes
            self.hasVideo = hasVideo
            self.hasAudio = hasAudio
            self.audioSources = audioSources
            self.audioChannels = audioChannels
            self.audioRate = audioRate
            self.videoSources = videoSources
            self.auxVideoFlags = auxVideoFlags
            self.mediaRep = mediaRep
            self.metadata = metadata
        }
    }
}

extension FinalCutPro.FCPXML.Asset: FCPXMLResource {
    /// Attributes unique to ``Asset``.
    public enum Attributes: String, XMLParsableAttributesKey {
        // shared resource attributes
        case id
        case name
        
        // base attributes
        case start
        case duration
        case format
        
        // asset attributes
        case uid
        
        // implied asset attributes
        case hasAudio
        case hasVideo
        case audioSources
        case audioChannels
        case audioRate
        case videoSources
        case auxVideoFlags
    }
    
    /// Children unique to ``Asset``.
    public enum Children: String {
        case mediaRep = "media-rep"
        case metadata
    }
    
    public init?(from xmlLeaf: XMLElement) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        // shared resource attributes
        guard let id = rawValues[.id] else { return nil }
        self.id = id
        name = rawValues[.name]
        
        // base attributes
        start = rawValues[.start]
        duration = rawValues[.duration]
        format = rawValues[.format]
        
        // asset attributes
        uid = rawValues[.uid]
        
        // implied asset attributes
        hasVideo = rawValues[.hasVideo] ?? "0" == "1"
        hasAudio = rawValues[.hasAudio] ?? "0" == "1"
        audioSources = Int(rawValues[.audioSources] ?? "0") ?? 0
        audioChannels = Int(rawValues[.audioChannels] ?? "0") ?? 0
        audioRate = rawValues[.audioRate]?.int
        videoSources = Int(rawValues[.videoSources] ?? "0") ?? 0
        auxVideoFlags = rawValues[.auxVideoFlags]
        
        if let mediaRepXML = xmlLeaf.first(childNamed: Children.mediaRep.rawValue) {
            mediaRep = FinalCutPro.FCPXML.MediaRep(from: mediaRepXML)
        }
        
        if let metadataXML = xmlLeaf.first(childNamed: Children.metadata.rawValue) {
            metadata = FinalCutPro.FCPXML.Metadata(fromMetadataElement: metadataXML)
        } else {
            metadata = FinalCutPro.FCPXML.Metadata(xml: [])
        }
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == resourceType.rawValue else { return nil }
    }
    
    public var resourceType: FinalCutPro.FCPXML.ResourceType { .asset }
    public func asAnyResource() -> FinalCutPro.FCPXML.AnyResource { .asset(self) }
}

#endif
