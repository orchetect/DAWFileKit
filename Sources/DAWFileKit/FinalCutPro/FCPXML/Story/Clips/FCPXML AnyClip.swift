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
            let clip = FinalCutPro.FCPXML.Audio(from: xmlLeaf, resources: resources)
            self = .audio(clip)
            
        case .clip:
            let clip = FinalCutPro.FCPXML.Clip(from: xmlLeaf, resources: resources)
            self = .clip(clip)
            
        case .mcClip:
            let clip = FinalCutPro.FCPXML.MCClip(from: xmlLeaf, resources: resources)
            self = .mcClip(clip)
            
        case .refClip:
            let clip = FinalCutPro.FCPXML.RefClip(from: xmlLeaf, resources: resources)
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

extension FinalCutPro.FCPXML.AnyClip {
    // TODO: refactor using protocol and generics?
    /// Convenience to return markers within the clip.
    /// Operation is not recursive, and only returns markers attached to the clip itself and not markers within nested clips.
    public var markers: [FinalCutPro.FCPXML.Marker] {
        switch self {
        case let .assetClip(clip): return clip.markers
        case let .audio(clip): return clip.markers
        case let .clip(clip): return clip.markers
        case let .mcClip(clip): return clip.markers
        case let .refClip(clip): return clip.markers
        case let .syncClip(clip): return clip.markers
        case let .title(clip): return clip.markers
        case let .video(clip): return clip.markers
        }
    }
}

#endif
