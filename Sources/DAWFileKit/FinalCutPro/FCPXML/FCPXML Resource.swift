//
//  FCPXML Resource.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    // TODO: additional resource types need to be added
    
    /// Resource
    public enum Resource: Equatable, Hashable {
        case asset(Asset)
        case effect(Effect)
        case format(Format)
    }
}

extension FinalCutPro.FCPXML.Resource {
    public enum ResourceType: String {
        case asset
        case effect
        case format
    }
}

extension FinalCutPro.FCPXML.Resource {
    public struct Asset: Equatable, Hashable {
        public let name: String
        public let uid: String
        public let start: String
        public let duration: String
        public let hasAudio: Bool
        public let hasVideo: Bool
        public let format: String?
        public let audioSources: Int
        public let videoSources: Int
        public let audioChannels: Int
        public let audioRate: Int?
        
        internal init(
            name: String,
            uid: String,
            start: String,
            duration: String,
            hasAudio: Bool,
            hasVideo: Bool,
            format: String?,
            audioSources: Int,
            videoSources: Int,
            audioChannels: Int,
            audioRate: Int?
        ) {
            self.name = name
            self.uid = uid
            self.start = start
            self.duration = duration
            self.hasAudio = hasAudio
            self.hasVideo = hasVideo
            self.format = format
            self.audioSources = audioSources
            self.videoSources = videoSources
            self.audioChannels = audioChannels
            self.audioRate = audioRate
        }
        
        init(from xmlLeaf: XMLElement) {
            name = xmlLeaf.attributeStringValue(forName: Attributes.name.rawValue) ?? ""
            
            uid = xmlLeaf.attributeStringValue(forName: Attributes.uid.rawValue) ?? ""
            
            start = xmlLeaf.attributeStringValue(forName: Attributes.start.rawValue) ?? ""
            
            duration = xmlLeaf.attributeStringValue(forName: Attributes.duration.rawValue) ?? ""
            
            hasAudio = xmlLeaf.attributeStringValue(forName: Attributes.hasAudio.rawValue) ?? "0" == "1"
            
            hasVideo = xmlLeaf.attributeStringValue(forName: Attributes.hasVideo.rawValue) ?? "0" == "1"
            
            format = xmlLeaf.attributeStringValue(forName: Attributes.format.rawValue)
            
            audioSources = Int(xmlLeaf.attributeStringValue(forName: Attributes.audioSources.rawValue) ?? "0") ?? 0
            
            videoSources = Int(xmlLeaf.attributeStringValue(forName: Attributes.videoSources.rawValue) ?? "0") ?? 0
            
            audioChannels = Int(xmlLeaf.attributeStringValue(forName: Attributes.audioChannels.rawValue) ?? "0") ?? 0
            
            audioRate = xmlLeaf.attributeStringValue(forName: Attributes.audioRate.rawValue)?.int
        }
        
        public enum Attributes: String {
            case name
            case uid
            case start
            case duration
            case hasAudio
            case hasVideo
            case format
            case audioSources
            case videoSources
            case audioChannels
            case audioRate
        }
    }
    
    public struct Effect: Equatable, Hashable {
        let name: String
        let uid: String
        
        internal init(name: String, uid: String) {
            self.name = name
            self.uid = uid
        }
        
        init(from xmlLeaf: XMLElement) {
            name = xmlLeaf.attributeStringValue(forName: Attributes.name.rawValue) ?? ""
            
            uid = xmlLeaf.attributeStringValue(forName: Attributes.uid.rawValue) ?? ""
        }
        
        public enum Attributes: String {
            case name
            case uid
        }
    }
    
    public struct Format: Equatable, Hashable {
        public let name: String
        public let frameDuration: String
        public let fieldOrder: String?
        public let width: Int
        public let height: Int
        public let colorSpace: String
        
        internal init(
            name: String,
            frameDuration: String,
            fieldOrder: String?,
            width: Int,
            height: Int,
            colorSpace: String
        ) {
            self.name = name
            self.frameDuration = frameDuration
            self.fieldOrder = fieldOrder
            self.width = width
            self.height = height
            self.colorSpace = colorSpace
        }
        
        init(from xmlLeaf: XMLElement) {
            name = xmlLeaf.attributeStringValue(forName: Attributes.name.rawValue) ?? ""
            
            frameDuration = xmlLeaf.attributeStringValue(forName: Attributes.frameDuration.rawValue) ?? ""
            
            fieldOrder = xmlLeaf.attributeStringValue(forName: Attributes.fieldOrder.rawValue)
            
            width = Int(xmlLeaf.attributeStringValue(forName: Attributes.width.rawValue) ?? "") ?? 0
            
            height = Int(xmlLeaf.attributeStringValue(forName: Attributes.height.rawValue) ?? "") ?? 0
            
            colorSpace = xmlLeaf.attributeStringValue(forName: Attributes.colorSpace.rawValue) ?? ""
        }
        
        public enum Attributes: String {
            case name
            case frameDuration
            case fieldOrder // only present if video is interlaced
            case width
            case height
            case colorSpace
        }
    }
}

#endif
