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
        case clip(Clip)
        case gap(Gap)
        case mcClip(MCClip)
        case refClip(RefClip)
        case syncClip(SyncClip)
        case title(Title)
        case video(Video)
    }
}

extension FinalCutPro.FCPXML.AnyClip {
    init?(
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
            
        case .clip:
            let clip = FinalCutPro.FCPXML.Clip(from: xmlLeaf, resources: resources)
            self = .clip(clip)
            
        case .gap:
            let element = FinalCutPro.FCPXML.Gap(from: xmlLeaf, resources: resources)
            self = .gap(element)
            
        case .mcClip:
            guard let clip = FinalCutPro.FCPXML.MCClip(from: xmlLeaf, resources: resources) else { return nil }
            self = .mcClip(clip)
            
        case .refClip:
            guard let clip = FinalCutPro.FCPXML.RefClip(from: xmlLeaf, resources: resources) else { return nil }
            self = .refClip(clip)
            
        case .syncClip:
            let clip = FinalCutPro.FCPXML.SyncClip(from: xmlLeaf, resources: resources)
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
}

extension FinalCutPro.FCPXML.AnyClip: FCPXMLClipAttributes {
    public var asFCPXMLClipAttributes: FCPXMLClipAttributes {
        switch self {
        case let .assetClip(clip): return clip
        case let .audio(clip): return clip
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

extension FinalCutPro.FCPXML.AnyClip {
    // TODO: refactor using protocol and generics?
    /// Convenience to return markers within the clip.
    /// Operation is not recursive, and only returns markers attached to the clip itself and not markers within nested clips.
    public var markers: [FinalCutPro.FCPXML.Marker] {
        switch self {
        case let .assetClip(clip): return clip.markers
        case let .audio(clip): return clip.markers
        case let .clip(clip): return clip.markers
        case let .gap(clip): return clip.markers
        case let .mcClip(clip): return clip.markers
        case let .refClip(clip): return clip.markers
        case let .syncClip(clip): return clip.markers
        case let .title(clip): return clip.markers
        case let .video(clip): return clip.markers
        }
    }
    
    // TODO: refactor using protocol and generics?
    /// Convenience to return markers within the clip.
    /// Operation is recursive and returns markers for all nested clips and elements.
    public func markersDeep(
        auditions auditionMask: FinalCutPro.FCPXML.Audition.Mask
    ) -> [FinalCutPro.FCPXML.Marker] {
        switch self {
        case let .assetClip(clip): return clip.markersDeep(auditions: auditionMask)
        case let .audio(clip): return clip.markersDeep(auditions: auditionMask)
        case let .clip(clip): return clip.markersDeep(auditions: auditionMask)
        case let .gap(clip): return clip.markersDeep(auditions: auditionMask)
        case let .mcClip(clip): return clip.markersDeep(auditions: auditionMask)
        case let .refClip(clip): return clip.markersDeep(auditions: auditionMask)
        case let .syncClip(clip): return clip.markersDeep(auditions: auditionMask)
        case let .title(clip): return clip.markersDeep(auditions: auditionMask)
        case let .video(clip): return clip.markersDeep(auditions: auditionMask)
        }
    }
}

#endif
