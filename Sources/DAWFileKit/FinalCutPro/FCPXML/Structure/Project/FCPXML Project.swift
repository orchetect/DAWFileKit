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
        
        // FCPXMLElementContext
        @EquatableAndHashableExempt
        public var context: FinalCutPro.FCPXML.ElementContext
        
        public init(
            name: String? = nil,
            id: String? = nil,
            uid: String? = nil,
            modDate: String? = nil,
            sequence: Sequence,
            // FCPXMLElementContext
            context: FinalCutPro.FCPXML.ElementContext = .init()
        ) {
            self.name = name
            self.id = id
            self.uid = uid
            self.modDate = modDate
            self.sequence = sequence
            
            // FCPXMLElementContext
            self.context = context
        }
    }
}

extension FinalCutPro.FCPXML.Project: FCPXMLStructureElement {
    /// Attributes unique to ``Project``.
    public enum Attributes: String {
        case modDate
        case sequence
    }
    
    public init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        name = FinalCutPro.FCPXML.getNameAttribute(from: xmlLeaf)
        id = FinalCutPro.FCPXML.getIDAttribute(from: xmlLeaf)
        uid = FinalCutPro.FCPXML.getUIDAttribute(from: xmlLeaf)
        modDate = xmlLeaf.attributeStringValue(forName: Attributes.modDate.rawValue)
        
        guard let seq = Self.parseSequence(from: xmlLeaf, resources: resources) else { return nil }
        sequence = seq
        
        // FCPXMLElementContext
        context = FinalCutPro.FCPXML.ElementContext(from: xmlLeaf, resources: resources)
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == structureElementType.rawValue else { return nil }
    }
    
    internal static func parseSequence(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> FinalCutPro.FCPXML.Sequence? {
        let storyElements = FinalCutPro.FCPXML.storyElements(in: xmlLeaf, resources: resources)
        let sequences = storyElements.sequences()
        guard let sequence = sequences.first else {
            print("Expected one sequence within project but found none.")
            return nil
        }
        if sequences.count != 1 {
            print("Expected one sequence within project but found \(sequences.count)")
        }
        return sequence
    }
    
    public var structureElementType: FinalCutPro.FCPXML.StructureElementType {
        .project
    }
    
    public func asAnyStructureElement() -> FinalCutPro.FCPXML.AnyStructureElement {
        .project(self)
    }
}

extension FinalCutPro.FCPXML.Project {
    /// Convenience to return the start timecode of the earliest sequence in the project.
    public var startTimecode: Timecode? {
        sequence.startTimecode
    }
    
    /// Convenience to return the frame rate of the project.
    public var frameRate: TimecodeFrameRate? {
        sequence.startTimecode?.frameRate
    }
}

extension FinalCutPro.FCPXML.Project: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        []
    }
    
    public func extractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyElement],
        matching predicate: (_ element: FinalCutPro.FCPXML.AnyElement) -> Bool
    ) -> [FinalCutPro.FCPXML.AnyElement] {
        extractElements(
            settings: settings,
            ancestorsOfParent: ancestorsOfParent,
            contents: [sequence.asAnyElement()],
            matching: predicate
        )
    }
}

#endif
