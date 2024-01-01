//
//  FCPXML ElementType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

extension FinalCutPro.FCPXML {
    // TODO: this list is by no means complete, the DTD contains more element names we're not utilizing yet
    
    /// FCPXML element types.
    public enum ElementType: String, Equatable, Hashable, CaseIterable, Sendable {
        // root
        case fcpxml
        
        // structure element
        case resources
        case library
        case event
        case project
        
        // resources
        case asset
        case media
        case format
        case effect
        case locator
        case objectTracker = "object-tracker"
        // asset sub-elements
        case mediaRep = "media-rep"
        // media sub-elements
        case multicam
        // media.multicam sub-elements
        case mcAngle = "mc-angle"
        // object-tracker sub-elements
        case trackingShape = "tracking-shape"
        
        // sequence
        case sequence
        case spine
        
        // clips
        case assetClip = "asset-clip"
        case audio
        case audition
        case clip
        case gap
        case liveDrawing = "live-drawing"
        case mcClip = "mc-clip"
        case refClip = "ref-clip"
        case syncClip = "sync-clip"
        case title
        case video
        // asset-clip sub-elements
        case audioChannelSource = "audio-channel-source"
        // mcClip sub-elements
        case mcSource = "mc-source"
        // sync-clip/ref-clip sub-elements
        case syncSource = "sync-source"
        case audioRoleSource = "audio-role-source"
        
        // annotations
        case caption
        case keyword
        case marker
        case chapterMarker = "chapter-marker"
        
        // textual
        case note
        case text
        case textStyle = "text-style"
        case textStyleDef = "text-style-def"
        
        // metadata
        case metadata
        
        // collections
        case collectionFolder = "collection-folder"
        case keywordCollection = "keyword-collection"
        case smartCollection = "smart-collection"
        
        // misc.
        case bookmark
        case conformRate
    }
}

extension FinalCutPro.FCPXML.ElementType {
    /// Initialize from an XML element.
    public init?(from xmlLeaf: XMLElement) {
        guard let name = xmlLeaf.name else { return nil }
        self.init(rawValue: name)
    }
}

extension XMLElement {
    /// Returns the ``FinalCutPro/FCPXML/ElementType`` case for the XML element.
    public var fcpElementType: FinalCutPro.FCPXML.ElementType? {
        guard let name = name else { return nil }
        return .init(rawValue: name)
    }
}

// MARK: - Meta
// these methods are conveniences to help in filtering and classifying elements

// swiftformat:options --wrapcollections preserve
extension Set<FinalCutPro.FCPXML.ElementType> {
    public static let allStructureCases: Self = [
        .fcpxml, .resources, .library, .event, .project
    ]
    
    public static let allResourceCases: Self = [
        .asset, .media, .format, .effect, .locator, .objectTracker
    ]
    
    public static let allClipCases: Self = [
        .assetClip, .audio, .audition, .clip, .gap, .liveDrawing,
        .mcClip, .refClip, .syncClip, .title, .video
    ]
    
    public static let allAnnotationCases: Self = [
        .caption, .keyword, .marker, .chapterMarker
    ]
    
    public static let allStoryElementCases: Self =
        [.sequence, .spine]
            + allClipCases
            + allAnnotationCases
    
    public static let allTimelineCases: Self = [
        .assetClip, .audio, /* not audition */ .clip, .gap, .liveDrawing,
            .mcClip, .refClip, .syncClip, .title, .video,
            .mcAngle, .sequence
    ]
}

extension FinalCutPro.FCPXML.ElementType {
    
    // structure elements
    public static let allStructureCases: Set<Self> = .allStructureCases
    public var isStructure: Bool {
        Self.allStructureCases.contains(self)
    }
    
    // resources
    public static let allResourceCases: Set<Self> = .allResourceCases
    public var isResource: Bool {
        Self.allResourceCases.contains(self)
    }
    
    // clips
    public static let allClipCases: Set<Self> = .allClipCases
    public var isClip: Bool {
        Self.allClipCases.contains(self)
    }
    
    // annotations
    public static let allAnnotationCases: Set<Self> = .allAnnotationCases
    public var isAnnotation: Bool {
        Self.allAnnotationCases.contains(self)
    }
    
    // story elements
    public static let allStoryElementCases: Set<Self> = .allStoryElementCases
    public var isStoryElement: Bool {
        Self.allStoryElementCases.contains(self)
    }
    
    // logical containers with a timeline that can contain story elements
    // and/or other nested containers.
    // (not "can it contain child elements?", but is it a container as far
    // as the user is concerned within Final Cut Pro?)
    public static let allTimelineCases: Set<Self> = .allTimelineCases
    public var isTimeline: Bool {
        Self.allTimelineCases.contains(self)
    }
}

#endif
