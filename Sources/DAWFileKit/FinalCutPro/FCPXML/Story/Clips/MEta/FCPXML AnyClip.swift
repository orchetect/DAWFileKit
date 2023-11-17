//
//  FCPXML AnyClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Type-erased box containing a specialized clip instance.
    public enum AnyClip {
        case assetClip(AssetClip)
        case audio(Audio)
        case audition(Audition)
        case clip(Clip)
        case gap(Gap)
        case mcClip(MCClip)
        case refClip(RefClip)
        case syncClip(SyncClip)
        case title(Title)
        case video(Video)
    }
}

extension FinalCutPro.FCPXML.AnyClip: FCPXMLClip {
    public init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        guard let name = xmlLeaf.name else { return nil }
        guard let clipType = FinalCutPro.FCPXML.ClipType(rawValue: name) else {
            print("Unrecognized FCPXML clip type: \(name)")
            return nil
        }
        
        switch clipType {
        case .assetClip:
            guard let clip = FinalCutPro.FCPXML.AssetClip(from: xmlLeaf, resources: resources) else { return nil }
            self = .assetClip(clip)
            
        case .audio:
            guard let clip = FinalCutPro.FCPXML.Audio(from: xmlLeaf, resources: resources) else { return nil }
            self = .audio(clip)
            
        case .audition:
            guard let element = FinalCutPro.FCPXML.Audition(from: xmlLeaf, resources: resources) else { return nil }
            self = .audition(element)
            
        case .clip:
            guard let clip = FinalCutPro.FCPXML.Clip(from: xmlLeaf, resources: resources) else { return nil }
            self = .clip(clip)
            
        case .gap:
            guard let element = FinalCutPro.FCPXML.Gap(from: xmlLeaf, resources: resources) else { return nil }
            self = .gap(element)
            
        case .mcClip:
            guard let clip = FinalCutPro.FCPXML.MCClip(from: xmlLeaf, resources: resources) else { return nil }
            self = .mcClip(clip)
            
        case .refClip:
            guard let clip = FinalCutPro.FCPXML.RefClip(from: xmlLeaf, resources: resources) else { return nil }
            self = .refClip(clip)
            
        case .syncClip:
            guard let clip = FinalCutPro.FCPXML.SyncClip(from: xmlLeaf, resources: resources) else { return nil }
            self = .syncClip(clip)
            
        case .title:
            guard let clip = FinalCutPro.FCPXML.Title(from: xmlLeaf, resources: resources) else { return nil }
            self = .title(clip)
            
        case .video:
            guard let clip = FinalCutPro.FCPXML.Video(from: xmlLeaf, resources: resources) else { return nil }
            self = .video(clip)
            
        case .liveDrawing:
            // TODO: implement this clip type
            print("Unhandled FCPXML clip type: \(name)")
            return nil
        }
    }
    
    public var clipType: FinalCutPro.FCPXML.ClipType {
        wrapped.clipType
    }
    
    /// Redundant, but required to fulfill `FCPXMLClip` protocol requirements.
    public func asAnyClip() -> FinalCutPro.FCPXML.AnyClip {
        self
    }
}

extension FinalCutPro.FCPXML.AnyClip {
    /// Returns the unwrapped clip typed as ``FCPXMLClip``.
    public var wrapped: any FCPXMLClip {
        switch self {
        case let .assetClip(clip): return clip
        case let .audio(clip): return clip
        case let .audition(clip): return clip
        case let .clip(clip): return clip
        case let .gap(clip): return clip
        case let .mcClip(clip): return clip
        case let .refClip(clip): return clip
        case let .syncClip(clip): return clip
        case let .title(clip): return clip
        case let .video(clip): return clip
        }
    }
}

extension FinalCutPro.FCPXML.AnyClip: FCPXMLClipAttributes {
    public var asFCPXMLClipAttributes: FCPXMLClipAttributes {
        switch self {
        case let .assetClip(clip): return clip
        case let .audio(clip): return clip
        case let .audition(clip): return clip
        case let .clip(clip): return clip
        case let .gap(clip): return clip
        case let .mcClip(clip): return clip
        case let .refClip(clip): return clip
        case let .syncClip(clip): return clip
        case let .title(clip): return clip
        case let .video(clip): return clip
        }
    }
    
    // FCPXMLAnchorableAttributes
    
    /// Convenience to return the lane of the clip.
    public var lane: Int? {
        asFCPXMLClipAttributes.lane
    }
    
    /// Convenience to return the offset of the clip.
    public var offset: Timecode? {
        asFCPXMLClipAttributes.offset
    }
    
    // FCPXMLClipAttributes
    
    /// Convenience to return the name of the clip.
    public var name: String? {
        asFCPXMLClipAttributes.name
    }
    
    /// Convenience to return the start of the clip.
    public var start: Timecode? {
        asFCPXMLClipAttributes.start
    }
    
    /// Convenience to return the duration of the clip.
    public var duration: Timecode? {
        asFCPXMLClipAttributes.duration
    }
    
    /// Convenience to return the enabled state of the clip.
    public var enabled: Bool {
        asFCPXMLClipAttributes.enabled
    }
}

extension FinalCutPro.FCPXML.AnyClip: _FCPXMLExtractableElement {
    var extractableStart: Timecode? { start }
    var extractableName: String? { name }
}

extension FinalCutPro.FCPXML.AnyClip: FCPXMLMarkersExtractable {
    public var markers: [FinalCutPro.FCPXML.Marker] {
        switch self {
        case let .assetClip(clip): return clip.markers
        case let .audio(clip): return clip.markers
        case let .audition(clip): return clip.markers
        case let .clip(clip): return clip.markers
        case let .gap(clip): return clip.markers
        case let .mcClip(clip): return clip.markers
        case let .refClip(clip): return clip.markers
        case let .syncClip(clip): return clip.markers
        case let .title(clip): return clip.markers
        case let .video(clip): return clip.markers
        }
    }
    
    public func extractMarkers(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        switch self {
        case let .assetClip(clip):
            return clip.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        case let .audio(clip):
            return clip.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        case let .audition(clip):
            return clip.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        case let .clip(clip):
            return clip.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        case let .gap(clip):
            return clip.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        case let .mcClip(clip):
            return clip.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        case let .refClip(clip):
            return clip.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        case let .syncClip(clip):
            return clip.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        case let .title(clip):
            return clip.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        case let .video(clip):
            return clip.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        }
    }
}

extension Collection<FinalCutPro.FCPXML.AnyClip> {
    public func asAnyStoryElements() -> [FinalCutPro.FCPXML.AnyStoryElement] {
        map { $0.asAnyStoryElement() }
    }
}

#endif
