//
//  FCPXML MCClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// References a multicam media.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use an `mc-clip` element to describe a timeline sequence created from a multicam media. To
    /// > use multicam media as a clip, see [Using Multicam Media](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/mc-clip
    /// > ). To specify the timing of the edit,
    /// > use the [Timing Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/mc-clip
    /// > ).
    public struct MCClip: FCPXMLClipAttributes {
        public var ref: String // resource ID, required
        
        @EquatableAndHashableExempt
        public var multicam: FinalCutPro.FCPXML.Media.Multicam
        
        public var sources: [MulticamSource]
        
        public var contents: [AnyStoryElement]
        
        // FCPXMLAnchorableAttributes
        public var lane: Int?
        public var offset: Timecode?
        
        // FCPXMLClipAttributes
        public var name: String?
        public var start: Timecode?
        public var duration: Timecode?
        public var enabled: Bool
        
        // TODO: add missing attributes and protocols
        
        // FCPXMLElementContext
        @EquatableAndHashableExempt
        public var context: FinalCutPro.FCPXML.ElementContext
        
        public init(
            ref: String,
            multicam: FinalCutPro.FCPXML.Media.Multicam,
            sources: [MulticamSource],
            contents: [AnyStoryElement],
            // FCPXMLAnchorableAttributes
            lane: Int?,
            offset: Timecode?,
            // FCPXMLClipAttributes
            name: String?,
            start: Timecode?,
            duration: Timecode?,
            enabled: Bool,
            // FCPXMLElementContext
            context: FinalCutPro.FCPXML.ElementContext = .init()
        ) {
            self.ref = ref
            self.multicam = multicam
            self.sources = sources
            self.contents = contents
            
            // FCPXMLAnchorableAttributes
            self.lane = lane
            self.offset = offset
            
            // FCPXMLClipAttributes
            self.name = name
            self.start = start
            self.duration = duration
            self.enabled = enabled
            
            // FCPXMLElementContext
            self.context = context
        }
    }
}

extension FinalCutPro.FCPXML.MCClip: FCPXMLClip {
    /// Attributes unique to ``MCClip`` clip.
    public enum Attributes: String, XMLParsableAttributesKey {
        case ref // resource ID
    }
    
    public enum Children: String {
        case mcSource = "mc-source"
    }
    
    // no role
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        guard let ref = rawValues[.ref] else { return nil }
        self.ref = ref
        
        // AFAIK `media` is the only resource type usable by a `mc-clip`
        guard case let .media(refMedia) = resources[ref] else { return nil }
        
        // AFAIK `multicam` is the only resource container usable by a `mc-clip`
        guard let mediaType = refMedia.generateMediaType(
            breadcrumbs: breadcrumbs + [xmlLeaf],
            resources: resources,
            contextBuilder: contextBuilder
        ) else { return nil }
        guard case let .multicam(multicam) = mediaType else { return nil }
        self.multicam = multicam
        
        sources = Self.parseMulticamSources(in: xmlLeaf)
        
        contents = FinalCutPro.FCPXML.storyElements( // adds xmlLeaf as breadcrumb
            in: xmlLeaf,
            breadcrumbs: breadcrumbs,
            resources: resources,
            contextBuilder: contextBuilder
        )
        
        let clipAttributes = Self.parseClipAttributes(
            from: xmlLeaf,
            resources: resources
        )
        
        // FCPXMLAnchorableAttributes
        lane = clipAttributes.lane
        offset = clipAttributes.offset
        
        // FCPXMLClipAttributes
        name = clipAttributes.name
        start = clipAttributes.start
        duration = clipAttributes.duration
        enabled = clipAttributes.enabled
        
        // FCPXMLElementContext
        context = contextBuilder.buildContext(from: xmlLeaf, breadcrumbs: breadcrumbs, resources: resources)
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == clipType.rawValue else { return nil }
    }
    
    public var clipType: FinalCutPro.FCPXML.ClipType { .mcClip }
    public func asAnyClip() -> FinalCutPro.FCPXML.AnyClip { .mcClip(self) }
}

extension FinalCutPro.FCPXML.MCClip: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        []
    }
    
    public func extractableChildren() -> [FinalCutPro.FCPXML.AnyElement] {
        // resource may contain story elements
        let mtElements = multicam.extractableElements()
        let mtChildren = multicam.extractableChildren()
        
        return contents.asAnyElements() + mtElements + mtChildren
    }
}

extension FinalCutPro.FCPXML.MCClip {
    /// Multicam source used in a `mc-clip`.
    /// A single source may be used for both video and audio, or separate sources may be used for each.
    public struct MulticamSource: Equatable, Hashable {
        /// Specifies the angle identifier.
        /// This is not the angle name, but a unique ID string randomly generated by FCP.
        public var angleID: String
        
        /// Indicates which source to use, if any, from the angle.
        ///
        /// When a `mc-clip` has the same angle selected for both video and audio, a single
        /// `mc-source` child element is used with a `srcEnable` attribute value of `all`.
        /// When a `mc-clip` has different angles selected for video and audio, then two
        /// `mc-source` child elements are used where one will have a `srcEnable` attribute value of
        /// `video` and the other `audio`.
        public var sourceEnable: SourceEnable
        
        public init(angleID: String, sourceEnable: SourceEnable) {
            self.angleID = angleID
            self.sourceEnable = sourceEnable
        }
    }
    
    static func parseMulticamSources(
        in xmlLeaf: XMLElement
    ) -> [MulticamSource] {
        let mcSourceChildren = xmlLeaf.children?
            .filter { $0.name == Children.mcSource.rawValue }
            .compactMap { $0 as? XMLElement }
        ?? []
        
        let sources = mcSourceChildren.compactMap {
            MulticamSource(from: $0)
        }
        return sources
    }
}

extension FinalCutPro.FCPXML.MCClip.MulticamSource {
    public enum Attributes: String, XMLParsableAttributesKey {
        case angleID
        case srcEnable
    }
    
    public init?(from xmlLeaf: XMLElement) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        // validate element name
        guard xmlLeaf.name == FinalCutPro.FCPXML.MCClip.Children.mcSource.rawValue
        else { return nil }
        
        guard let angleID = rawValues[.angleID],
              let srcEnable = rawValues[.srcEnable],
              let sourceEnable = SourceEnable(rawValue: srcEnable)
        else { return nil }
        
        self.angleID = angleID
        self.sourceEnable = sourceEnable
    }
}

extension FinalCutPro.FCPXML.MCClip.MulticamSource {
    /// Multicam angle source enable value.
    ///
    /// When a `mc-clip` has the same angle selected for both video and audio, a single
    /// `mc-source` child element is used with a `srcEnable` attribute value of `all`.
    /// When a `mc-clip` has different angles selected for video and audio, then two
    /// `mc-source` child elements are used where one will have a `srcEnable` attribute value of
    /// `video` and the other `audio`.
    public enum SourceEnable: String, Equatable, Hashable, CaseIterable {
        /// Audio and Video.
        case all
        
        /// Audio source.
        case audio
        
        /// Video source.
        case video
        
        /// No sources.
        case none
    }
}

extension [FinalCutPro.FCPXML.MCClip.MulticamSource] {
    /// Returns the corresponding angle IDs for the given multicam source(s).
    public func audioVideoAngleIDs() -> (audioID: String?, videoID: String?) {
        var audioAngleID: String?
        var videoAngleID: String?
        
        forEach { source in
            switch source.sourceEnable {
            case .all:
                audioAngleID = source.angleID
                videoAngleID = source.angleID
            case .audio:
                audioAngleID = source.angleID
            case .video:
                videoAngleID = source.angleID
            case .none:
                break
            }
        }
        
        return (audioID: audioAngleID, videoID: videoAngleID)
    }
}

#endif
