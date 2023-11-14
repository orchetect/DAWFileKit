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
        frameRate: TimecodeFrameRate
    ) {
        guard let name = xmlLeaf.name else { return nil }
        guard let clipType = FinalCutPro.FCPXML.ClipType(rawValue: name) else {
            print("Unrecognized FCPXML clip type: \(name)")
            return nil
        }
        
        switch clipType {
        case .assetClip:
            guard let clip = FinalCutPro.FCPXML.AssetClip(
                from: xmlLeaf,
                frameRate: frameRate
            ) else { return nil }
            self = .assetClip(clip)
            
        case .audio:
            let clip = FinalCutPro.FCPXML.Audio(from: xmlLeaf)
            self = .audio(clip)
            
        case .clip:
            let clip = FinalCutPro.FCPXML.Clip(from: xmlLeaf)
            self = .clip(clip)
            
        case .title:
            guard let clip = FinalCutPro.FCPXML.Title(
                from: xmlLeaf,
                frameRate: frameRate
            ) else { return nil }
            self = .title(clip)
            
        case .syncClip:
            let clip = FinalCutPro.FCPXML.SyncClip(from: xmlLeaf)
            self = .syncClip(clip)
            
        case .video:
            guard let clip = FinalCutPro.FCPXML.Video(
                from: xmlLeaf,
                frameRate: frameRate
            ) else { return nil }
            self = .video(clip)
            
        default:
            // TODO: handle additional clip types
            print("Unhandled FCPXML clip type: \(name)")
            return nil
        }
    }
    
    init?<C: FCPXMLTimelineAttributes>(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        timelineContext: C.Type,
        timelineContextInstance: C
    ) {
        guard let frameRate = FinalCutPro.FCPXML.parseTimecodeFrameRate(
            from: xmlLeaf,
            resources: resources,
            timelineContext: timelineContext,
            timelineContextInstance: timelineContextInstance
        ) else { return nil }
        self.init(from: xmlLeaf, frameRate: frameRate)
    }
}

#endif
