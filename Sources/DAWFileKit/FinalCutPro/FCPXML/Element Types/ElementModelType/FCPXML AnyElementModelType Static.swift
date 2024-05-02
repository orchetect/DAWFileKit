//
//  FCPXML AnyElementModelType Static.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML.AnyElementModelType {
    // MARK: - Root
    
    public static var fcpxml: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Root>.fcpxml)
    }
    
    // MARK: - Structure
    
    public static var library: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Library>.library)
    }
    
    public static var event: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Event>.event)
    }
    
    public static var project: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Project>.project)
    }
    
    // MARK: - Resources
    
    public static var asset: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Asset>.asset)
    }
    
    public static var media: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Media>.media)
    }
    
    public static var format: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Format>.format)
    }
    
    public static var effect: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Effect>.effect)
    }
    
    public static var locator: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Locator>.locator)
    }
    
    public static var objectTracker: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.ObjectTracker>.objectTracker)
    }
    
    // asset sub-elements
    
    public static var mediaRep: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.MediaRep>.mediaRep)
    }
    
    // media sub-elements
    
    public static var multicam: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Media.Multicam>.multicam)
    }
    
    // media.multicam sub-elements
    
    public static var mcAngle: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Media.Multicam.Angle>.mcAngle)
    }
    
    // object-tracker sub-elements
    
    public static var trackingShape: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.ObjectTracker.TrackingShape>.trackingShape)
    }
    
    // MARK: - Story Elements
    
    public static var sequence: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Sequence>.sequence)
    }
    
    public static var spine: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Spine>.spine)
    }
    
    // MARK: - Clips
    
    public static var assetClip: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.AssetClip>.assetClip)
    }
    
    public static var audio: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Audio>.audio)
    }
    
    public static var audition: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Audition>.audition)
    }
    
    public static var clip: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Clip>.clip)
    }
    
    public static var gap: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Gap>.gap)
    }
    
    // TODO: uncomment once `live-drawing` element model is implemented
    // public static var liveDrawing: Self {
    //     .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.LiveDrawing>.liveDrawing)
    // }
    
    public static var mcClip: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.MCClip>.mcClip)
    }
    
    public static var refClip: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.RefClip>.refClip)
    }
    
    public static var syncClip: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.SyncClip>.syncClip)
    }
    
    public static var title: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Title>.title)
    }
    
    public static var video: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Video>.video)
    }
    
    // asset-clip sub-elements
    
    public static var audioChannelSource: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.AudioChannelSource>.audioChannelSource)
    }
    
    // mc-clip sub-elements
    
    public static var mcSource: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.MulticamSource>.mcSource)
    }
    
    // sync-clip/ref-clip sub-elements
    
    public static var syncSource: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.SyncClip.SyncSource>.syncSource)
    }
    
    public static var audioRoleSource: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.AudioRoleSource>.audioRoleSource)
    }
    
    // MARK: - Annotations
    
    public static var caption: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Caption>.caption)
    }
    
    public static var keyword: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Keyword>.keyword)
    }
    
    // Marker model includes `marker` and `chapter-marker` element types
    public static var marker: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Marker>.marker)
    }
    
    // MARK: - Textual
    
    public static var text: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Text>.text)
    }
    
    // MARK: - Metadata
    
    public static var metadata: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Metadata>.metadata)
    }
    
    public static var metadatum: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Metadata.Metadatum>.metadatum)
    }
    
    // MARK: - Misc
    
    public static var conformRate: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.ConformRate>.conformRate)
    }
    
    public static var timeMap: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.TimeMap>.timeMap)
    }
    
    public static var timePoint: Self {
        .init(base: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.TimeMap.TimePoint>.timePoint)
    }
}

#endif
