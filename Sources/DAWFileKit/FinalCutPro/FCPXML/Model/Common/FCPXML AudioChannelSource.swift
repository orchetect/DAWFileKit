//
//  FCPXML AudioChannelSource.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// FCPXML 1.11 DTD:
    /// "An `audio-channel-source` element adjusts playback settings for a single channel-based
    /// audio component in a clip's primary audio layout.
    /// The primary audio layout is comprised of all audio from elements in the primary (lane 0)
    /// storyline."
    public struct AudioChannelSource: Equatable, Hashable {
        /// Source audio channels (comma separated, 1-based index, ie: "1, 2")
        public var sourceChannels: String
        
        /// Output audio channels (comma separated, from: `L,R,C,LFE,Ls,Rs,X`)
        public var outputChannels: String?
        
        /// Output role assignment.
        public var role: FinalCutPro.FCPXML.AudioRole?
        
        public var start: Timecode?
        public var duration: Timecode?
        
        public var enabled: Bool
        
        public var active: Bool
        
        public var contents: [XMLElement]
        
        public init(
            sourceChannels: String,
            outputChannels: String? = nil,
            role: FinalCutPro.FCPXML.AudioRole? = nil,
            start: Timecode? = nil,
            duration: Timecode? = nil,
            enabled: Bool = true,
            active: Bool = true,
            contents: [XMLElement] = []
        ) {
            self.sourceChannels = sourceChannels
            self.outputChannels = outputChannels
            self.role = role
            self.start = start
            self.duration = duration
            self.enabled = enabled
            self.active = active
            
            self.contents = contents
        }
    }
}

extension FinalCutPro.FCPXML.AudioChannelSource {
    public enum Element: String {
        case name = "audio-channel-source"
    }
    
    /// Attributes unique to ``AudioChannelSource``.
    public enum Attributes: String, XMLParsableAttributesKey {
        case sourceChannels = "srcCh"
        case outputChannels = "outCh"
        case role
        case start
        case duration
        case enabled
        case active
    }
    
    init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        // validate element name
        guard xmlLeaf.name == Element.name.rawValue else { return nil }
        
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        guard let srcCh = rawValues[.sourceChannels] else { return nil }
        sourceChannels = srcCh
        
        outputChannels = rawValues[.outputChannels]
        
        if let audioRole = FinalCutPro.FCPXML.AudioRole(rawValue: rawValues[.role] ?? "")
        { role = audioRole }
        
        start = try? FinalCutPro.FCPXML.timecode(
            fromRational: rawValues[.start] ?? "",
            xmlLeaf: xmlLeaf,
            resources: resources
        )
        
        duration = try? FinalCutPro.FCPXML.timecode(
            fromRational: rawValues[.duration] ?? "",
            xmlLeaf: xmlLeaf,
            resources: resources
        )
        
        enabled = (rawValues[.enabled] ?? "1") == "1"
        
        active = (rawValues[.active] ?? "1") == "1"
        
        contents = xmlLeaf.children?.compactMap { $0 as? XMLElement } ?? []
    }
}

extension FinalCutPro.FCPXML {
    static func parseAudioChannelSources(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> [AudioChannelSource] {
        let elements = (xmlLeaf.children ?? [])
            .filter { $0.name == AudioChannelSource.Element.name.rawValue }
            .compactMap { $0 as? XMLElement }
        
        return elements.compactMap {
            AudioChannelSource(from: $0, resources: resources)
        }
    }
}

// MARK: - Collection Methods

extension [FinalCutPro.FCPXML.AudioChannelSource] {
    /// Convert and wrap the audio channel source roles as ``FinalCutPro/FCPXML/AnyRole``
    public func asAnyRoles() -> [FinalCutPro.FCPXML.AnyRole] {
        compactMap(\.role)
            .compactMap { FinalCutPro.FCPXML.AnyRole.audio($0) }
    }
}

#endif
