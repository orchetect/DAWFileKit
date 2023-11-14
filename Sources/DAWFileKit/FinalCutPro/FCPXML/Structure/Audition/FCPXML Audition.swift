//
//  FCPXML Audition.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import CoreMedia
import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Contains one active story element followed by alternative story elements in the audition
    /// > container.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > When exported, the XML lists the currently active item as the first child in the audition container.
    public struct Audition {
        public var clips: [AnyClip]
        
        public var lane: Int?
        
        // TODO: public var dateModified: Date?
        
        public init(
            clips: [AnyClip] = [],
            lane: Int?
        ) {
            self.clips = clips
            self.lane = lane
        }
    }
}

extension FinalCutPro.FCPXML.Audition {
    /// Attributes unique to ``Audition``.
    public enum Attributes: String {
        case lane
        case modDate
    }
    
    init(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        if let laneString = xmlLeaf.attributeStringValue(forName: Attributes.lane.rawValue) {
            lane = Int(laneString)
        }
        
        clips = FinalCutPro.FCPXML.parseClips(in: xmlLeaf, resources: resources)
    }
    
    // TODO: refactor using protocol and generics?
    /// Convenience to return markers within the clip.
    /// Operation is recursive and returns markers for all nested clips and elements.
    public func markersDeep(for mask: Mask) -> [FinalCutPro.FCPXML.Marker] {
        switch mask {
        case .omitAuditions:
            return []
        case .activeAudition:
            return clips.first?.markersDeep(auditions: mask) ?? []
        case .allAuditions:
            return clips.flatMap { $0.markersDeep(auditions: mask) }
        }
    }
    
    public enum Mask {
        case omitAuditions
        case activeAudition
        case allAuditions
    }
}

#endif
