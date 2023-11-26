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
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
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
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            self = .assetClip(clip)
            
        case .audio:
            guard let clip = FinalCutPro.FCPXML.Audio(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            self = .audio(clip)
            
        case .audition:
            guard let element = FinalCutPro.FCPXML.Audition(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            self = .audition(element)
            
        case .clip:
            guard let clip = FinalCutPro.FCPXML.Clip(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            self = .clip(clip)
            
        case .gap:
            guard let element = FinalCutPro.FCPXML.Gap(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            self = .gap(element)
            
        case .mcClip:
            guard let clip = FinalCutPro.FCPXML.MCClip(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            self = .mcClip(clip)
            
        case .refClip:
            guard let clip = FinalCutPro.FCPXML.RefClip(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            self = .refClip(clip)
            
        case .syncClip:
            guard let clip = FinalCutPro.FCPXML.SyncClip(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            self = .syncClip(clip)
            
        case .title:
            guard let clip = FinalCutPro.FCPXML.Title(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            self = .title(clip)
            
        case .video:
            guard let clip = FinalCutPro.FCPXML.Video(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
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

extension FinalCutPro.FCPXML.AnyClip: FCPXMLElementContext {
    public var context: FinalCutPro.FCPXML.ElementContext {
        wrapped.context
    }
}

// MARK: Proxy Properties

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

extension FinalCutPro.FCPXML.AnyClip: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        switch self {
        case let .assetClip(clip): return clip.extractableElements()
        case let .audio(clip): return clip.extractableElements()
        case let .audition(clip): return clip.extractableElements()
        case let .clip(clip): return clip.extractableElements()
        case let .gap(clip): return clip.extractableElements()
        case let .mcClip(clip): return clip.extractableElements()
        case let .refClip(clip): return clip.extractableElements()
        case let .syncClip(clip): return clip.extractableElements()
        case let .title(clip): return clip.extractableElements()
        case let .video(clip): return clip.extractableElements()
        }
    }
    
    public func extractableChildren() -> [FinalCutPro.FCPXML.AnyElement] {
        switch self {
        case let .assetClip(clip): return clip.extractableChildren()
        case let .audio(clip): return clip.extractableChildren()
        case let .audition(clip): return clip.extractableChildren()
        case let .clip(clip): return clip.extractableChildren()
        case let .gap(clip): return clip.extractableChildren()
        case let .mcClip(clip): return clip.extractableChildren()
        case let .refClip(clip): return clip.extractableChildren()
        case let .syncClip(clip): return clip.extractableChildren()
        case let .title(clip): return clip.extractableChildren()
        case let .video(clip): return clip.extractableChildren()
        }
    }
}

// MARK: - Filtering

extension Collection<FinalCutPro.FCPXML.AnyClip> {
    /// Convenience to filter the FCPXML clip collection and return only `asset-clip`s.
    public func assetClips() -> [FinalCutPro.FCPXML.AssetClip] {
        reduce(into: []) { elements, element in
            if case let .assetClip(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML clip collection and return only `audio` clips.
    public func audios() -> [FinalCutPro.FCPXML.Audio] {
        reduce(into: []) { elements, element in
            if case let .audio(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML clip collection and return only `audition` clips.
    public func auditions() -> [FinalCutPro.FCPXML.Audition] {
        reduce(into: []) { elements, element in
            if case let .audition(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML clip collection and return only plain `clip`s.
    public func clips() -> [FinalCutPro.FCPXML.Clip] {
        reduce(into: []) { elements, element in
            if case let .clip(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML clip collection and return only `gap` clips.
    public func gaps() -> [FinalCutPro.FCPXML.Gap] {
        reduce(into: []) { elements, element in
            if case let .gap(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML clip collection and return only multicam `mc-clip`s.
    public func mcClips() -> [FinalCutPro.FCPXML.MCClip] {
        reduce(into: []) { elements, element in
            if case let .mcClip(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML clip collection and return only reference `ref-clip`s.
    public func refClips() -> [FinalCutPro.FCPXML.RefClip] {
        reduce(into: []) { elements, element in
            if case let .refClip(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML clip collection and return only reference `sync-clip`s.
    public func syncClips() -> [FinalCutPro.FCPXML.SyncClip] {
        reduce(into: []) { elements, element in
            if case let .syncClip(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML clip collection and return only `title` clips.
    public func titles() -> [FinalCutPro.FCPXML.Title] {
        reduce(into: []) { elements, element in
            if case let .title(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML clip collection and return only `video` clips.
    public func videos() -> [FinalCutPro.FCPXML.Video] {
        reduce(into: []) { elements, element in
            if case let .video(element) = element { elements.append(element) }
        }
    }
}

#endif
