//
//  FCPXMLElementModelTypeProtocol Static.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

// MARK: - Root

extension FCPXMLElementModelTypeProtocol where
Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Root>
{
    public static var fcpxml: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Root> {
        .init()
    }
}

// MARK: - Structure

extension FCPXMLElementModelTypeProtocol where
Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Library>
{
    public static var library: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Library> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol where
Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Event>
{
    public static var event: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Event> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Project>
{
    public static var project: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Project> {
        .init()
    }
}

// MARK: - Resources

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Asset>
{
    public static var asset: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Asset> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Media>
{
    public static var media: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Media> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Format>
{
    public static var format: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Format> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Effect>
{
    public static var effect: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Effect> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Locator>
{
    public static var locator: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Locator> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.ObjectTracker>
{
    public static var objectTracker: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.ObjectTracker> {
        .init()
    }
}

// asset sub-elements

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.MediaRep>
{
    public static var mediaRep: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.MediaRep> {
        .init()
    }
}

// media sub-elements

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Media.Multicam>
{
    public static var multicam: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Media.Multicam> {
        .init()
    }
}

// media.multicam sub-elements

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Media.Multicam.Angle>
{
    public static var mcAngle: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Media.Multicam.Angle> {
        .init()
    }
}

// object-tracker sub-elements

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.ObjectTracker.TrackingShape>
{
    public static var trackingShape: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.ObjectTracker.TrackingShape> {
        .init()
    }
}

// MARK: - Story Elements

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Sequence>
{
    public static var sequence: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Sequence> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Spine>
{
    public static var spine: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Spine> {
        .init()
    }
}

// MARK: - Clips

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.AssetClip>
{
    public static var assetClip: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.AssetClip> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Audio>
{
    public static var audio: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Audio> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Audition>
{
    public static var audition: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Audition> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Clip>
{
    public static var clip: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Clip> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Gap>
{
    public static var gap: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Gap> {
        .init()
    }
}

// TODO: uncomment once `live-drawing` element model is implemented
// extension FCPXMLElementModelTypeProtocol
// where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.LiveDrawing>
// {
//     public static var liveDrawing: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.LiveDrawing> {
//         .init()
//     }
// }

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.MCClip>
{
    public static var mcClip: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.MCClip> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.RefClip>
{
    public static var refClip: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.RefClip> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.SyncClip>
{
    public static var syncClip: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.SyncClip> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Title>
{
    public static var title: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Title> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Video>
{
    public static var video: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Video> {
        .init()
    }
}

// asset-clip sub-elements

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.AudioChannelSource>
{
    public static var audioChannelSource: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.AudioChannelSource> {
        .init()
    }
}

// mc-clip sub-elements

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.MulticamSource>
{
    public static var mcSource: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.MulticamSource> {
        .init()
    }
}

// sync-clip/ref-clip sub-elements

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.SyncClip.SyncSource>
{
    public static var syncSource: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.SyncClip.SyncSource> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.AudioRoleSource>
{
    public static var audioRoleSource: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.AudioRoleSource> {
        .init()
    }
}

// MARK: - Annotations

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Caption>
{
    public static var caption: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Caption> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Keyword>
{
    public static var keyword: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Keyword> {
        .init()
    }
}

// Marker model includes `marker` and `chapter-marker` element types
extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Marker>
{
    public static var marker: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Marker> {
        .init()
    }
}

// MARK: - Textual

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Text>
{
    public static var text: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Text> {
        .init()
    }
}

// MARK: - Metadata

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Metadata>
{
    public static var metadata: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.Metadata> {
        .init()
    }
}

// MARK: - Misc

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.ConformRate>
{
    public static var conformRate: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.ConformRate> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.TimeMap>
{
    public static var timeMap: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.TimeMap> {
        .init()
    }
}

extension FCPXMLElementModelTypeProtocol
where Self == FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.TimeMap.TimePoint>
{
    public static var timePoint: FinalCutPro.FCPXML.ElementModelType<FinalCutPro.FCPXML.TimeMap.TimePoint> {
        .init()
    }
}

#endif
