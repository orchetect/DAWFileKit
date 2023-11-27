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
    public enum Attributes: String, XMLParsableAttributesKey {
        case name
        case id
        case uid
        case modDate
        case sequence
    }
    
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        name = rawValues[.name]
        id = rawValues[.id]
        uid = rawValues[.uid]
        modDate = rawValues[.modDate]
        
        guard let seq = Self.parseSequence( // adds xmlLeaf as breadcrumb
            from: xmlLeaf,
            breadcrumbs: breadcrumbs,
            resources: resources,
            contextBuilder: contextBuilder
        )
        else { return nil }
        sequence = seq
        
        // FCPXMLElementContext
        context = contextBuilder.buildContext(from: xmlLeaf, breadcrumbs: breadcrumbs, resources: resources)
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == structureElementType.rawValue else { return nil }
    }
    
    internal static func parseSequence(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) -> FinalCutPro.FCPXML.Sequence? {
        let storyElements = FinalCutPro.FCPXML.storyElements( // adds xmlLeaf as breadcrumb
            in: xmlLeaf,
            breadcrumbs: breadcrumbs,
            resources: resources,
            contextBuilder: contextBuilder
        )
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
    
    public func extractableChildren() -> [FinalCutPro.FCPXML.AnyElement] {
        [sequence.asAnyElement()]
    }
}

#endif