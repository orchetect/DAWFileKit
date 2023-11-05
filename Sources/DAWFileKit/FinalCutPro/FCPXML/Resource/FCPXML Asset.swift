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
        public let name: String
        public let id: String
        
        // base attributes
        public let start: String
        public let duration: String
        public let format: String?
        
        // asset attributes
        public let uid: String
        
        // implied asset attributes
        public let hasVideo: Bool
        public let hasAudio: Bool
        public let audioSources: Int
        public let audioChannels: Int
        public let audioRate: Int?
        public let videoSources: Int
        public let auxVideoFlags: String?
        
        // TODO: refactor to strong types
        public let xmlChildren: [XMLElement]
        
        internal init(
            name: String,
            id: String,
            start: String,
            duration: String,
            format: String?,
            uid: String,
            hasVideo: Bool,
            hasAudio: Bool,
            audioSources: Int,
            audioChannels: Int,
            audioRate: Int?,
            videoSources: Int,
            auxVideoFlags: String?,
            xmlChildren: [XMLElement]
        ) {
            // shared resource attributes
            self.name = name
            self.id = id
            
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
            
            self.xmlChildren = xmlChildren
        }
        
        init(from xmlLeaf: XMLElement) {
            // shared resource attributes
            name = xmlLeaf.attributeStringValue(forName: Attributes.name.rawValue) ?? ""
            id = xmlLeaf.attributeStringValue(forName: Attributes.id.rawValue) ?? ""
            
            // base attributes
            start = xmlLeaf.attributeStringValue(forName: Attributes.start.rawValue) ?? ""
            duration = xmlLeaf.attributeStringValue(forName: Attributes.duration.rawValue) ?? ""
            format = xmlLeaf.attributeStringValue(forName: Attributes.format.rawValue)
            
            // asset attributes
            uid = xmlLeaf.attributeStringValue(forName: Attributes.uid.rawValue) ?? ""
            
            // implied asset attributes
            hasVideo = xmlLeaf.attributeStringValue(forName: Attributes.hasVideo.rawValue) ?? "0" == "1"
            hasAudio = xmlLeaf.attributeStringValue(forName: Attributes.hasAudio.rawValue) ?? "0" == "1"
            audioSources = Int(xmlLeaf.attributeStringValue(forName: Attributes.audioSources.rawValue) ?? "0") ?? 0
            audioChannels = Int(xmlLeaf.attributeStringValue(forName: Attributes.audioChannels.rawValue) ?? "0") ?? 0
            audioRate = xmlLeaf.attributeStringValue(forName: Attributes.audioRate.rawValue)?.int
            videoSources = Int(xmlLeaf.attributeStringValue(forName: Attributes.videoSources.rawValue) ?? "0") ?? 0
            auxVideoFlags = xmlLeaf.attributeStringValue(forName: Attributes.auxVideoFlags.rawValue)
            
            // TODO: refactor to strong types
            xmlChildren = xmlLeaf.children?.compactMap { $0 as? XMLElement } ?? []
        }
    }
}

extension FinalCutPro.FCPXML.Asset {
    public enum Attributes: String {
        // shared resource attributes
        case name
        case id
        
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
}

#endif
