//
//  FCPXML Project.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import CoreMedia
import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Project element.
    public struct Project {
        public var name: String?
        public var id: String?
        public var uid: String?
        public var modDate: String?
        public var sequence: Sequence
        
        public init(
            name: String? = nil,
            id: String? = nil,
            uid: String? = nil,
            modDate: String? = nil,
            sequence: Sequence
        ) {
            self.name = name
            self.id = id
            self.uid = uid
            self.modDate = modDate
            self.sequence = sequence
        }
    }
}

extension FinalCutPro.FCPXML.Project {
    /// Attributes unique to ``Project``.
    public enum Attributes: String {
        case modDate
        case sequence
    }
    
    internal init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        name = FinalCutPro.FCPXML.getNameAttribute(from: xmlLeaf)
        id = FinalCutPro.FCPXML.getIDAttribute(from: xmlLeaf)
        uid = FinalCutPro.FCPXML.getUIDAttribute(from: xmlLeaf)
        modDate = xmlLeaf.attributeStringValue(forName: Attributes.modDate.rawValue)
        
        guard let seq = Self.parseSequence(from: xmlLeaf, resources: resources) else { return nil }
        sequence = seq
    }
    
    internal static func parseSequence(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> FinalCutPro.FCPXML.Sequence? {
        let sequences = FinalCutPro.FCPXML.parseSequences(in: xmlLeaf, resources: resources)
        guard let sequence = sequences.first else {
            print("Expected one sequence within project but found none.")
            return nil
        }
        if sequences.count != 1 {
            print("Expected one sequence within project but found \(sequences.count)")
        }
        return sequence
    }
}

extension FinalCutPro.FCPXML.Project {
    /// Convenience to return the start timecode of the earliest sequence in the project.
    public var startTimecode: Timecode? {
        sequence.start
    }
    
    /// Convenience to return the frame rate of the project.
    public var frameRate: TimecodeFrameRate? {
        sequence.start?.frameRate
    }
}

extension FinalCutPro.FCPXML.Project {
    /// Convenience to return markers within the project.
    /// Operation is not recursive, and only returns markers attached to the clip itself and not markers within nested clips.
    public var markers: [FinalCutPro.FCPXML.Marker] {
        sequence.markers
    }
    
    /// Convenience to return markers within the project.
    /// Operation is recursive and returns markers for all nested clips and elements.
    public func markersDeep(
        auditions auditionMask: FinalCutPro.FCPXML.Audition.Mask
    ) -> [FinalCutPro.FCPXML.Marker] {
        sequence.markersDeep(auditions: auditionMask)
    }
}

#endif
