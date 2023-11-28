//
//  FCPXML SyncClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Contains a clip with its contained and anchored items synchronized.
    ///
    /// In Final Cut Pro, a Sync Clip does not bear roles itself.
    /// Instead, it inherits the video and audio role of the asset clip(s) within it.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use the `sync-source` element to describe the audio components of a synchronized clip.
    public struct SyncClip: FCPXMLClipAttributes {
        public var format: String? // DTD: default is same as parent
        public var syncSources: [SyncSource]
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
            format: String?,
            syncSources: [SyncSource],
            contents: [AnyStoryElement],
            // FCPXMLAnchorableAttributes
            lane: Int?,
            offset: Timecode,
            // FCPXMLClipAttributes
            name: String,
            start: Timecode,
            duration: Timecode,
            enabled: Bool,
            // FCPXMLElementContext
            context: FinalCutPro.FCPXML.ElementContext = .init()
        ) {
            self.format = format
            self.syncSources = syncSources
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

extension FinalCutPro.FCPXML.SyncClip: FCPXMLClip {
    public enum Attributes: String, XMLParsableAttributesKey {
        case format
    }
    
    public enum Children: String {
        case syncSource = "sync-source"
    }
    
    // no ref, no role
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        format = rawValues[.format]
        
        syncSources = FinalCutPro.FCPXML.parseSyncSources(from: xmlLeaf)
        
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
    
    public var clipType: FinalCutPro.FCPXML.ClipType { .syncClip }
    public func asAnyClip() -> FinalCutPro.FCPXML.AnyClip { .syncClip(self) }
}

extension FinalCutPro.FCPXML.SyncClip: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        []
    }
    
    public func extractableChildren() -> [FinalCutPro.FCPXML.AnyElement] {
        contents.asAnyElements()
    }
}

extension FinalCutPro.FCPXML.SyncClip {
    /// Describes an the audio component of a synchronized clip.
    ///
    /// > FCPXML 1.11 DTD:
    /// > A `sync-source` element defines the role-based audio components to be used
    /// > for a source of a synchronized clip.
    public struct SyncSource: Equatable, Hashable {
        public var sourceID: SourceID
        public var audioRoleSources: [FinalCutPro.FCPXML.AudioRoleSource]
    }
}

extension FinalCutPro.FCPXML.SyncClip.SyncSource {
    public enum Element: String {
        case name = "sync-source"
    }
    
    public enum Attributes: String, XMLParsableAttributesKey {
        case sourceID // required
    }
    
    init?(from xmlLeaf: XMLElement) {
        // validate element name
        guard xmlLeaf.name == Element.name.rawValue else { return nil }
        
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        guard let sourceIDString = rawValues[.sourceID],
              let sourceID = SourceID(rawValue: sourceIDString)
        else { return nil }
        self.sourceID = sourceID
        
        audioRoleSources = FinalCutPro.FCPXML.parseAudioRoleSources(from: xmlLeaf)
    }
}

extension FinalCutPro.FCPXML {
    static func parseSyncSources(
        from xmlLeaf: XMLElement
    ) -> [FinalCutPro.FCPXML.SyncClip.SyncSource] {
        let elements = (xmlLeaf.children ?? [])
            .filter { $0.name == SyncClip.SyncSource.Element.name.rawValue }
            .compactMap { $0 as? XMLElement }
        
        return elements.compactMap {
            SyncClip.SyncSource(from: $0)
        }
    }
}

extension FinalCutPro.FCPXML.SyncClip.SyncSource {
    public enum SourceID: String, Equatable, Hashable, CaseIterable {
        case storyline
        case connected
    }
}

#endif
