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

#endif
