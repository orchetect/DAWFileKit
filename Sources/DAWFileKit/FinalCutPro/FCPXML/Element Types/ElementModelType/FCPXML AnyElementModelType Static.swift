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
}

#endif
