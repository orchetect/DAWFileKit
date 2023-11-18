//
//  FCPXML Keyword.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Represents a keyword.
    public struct Keyword: Equatable, Hashable {
        public var name: String // a.k.a. `value`, required
        public var start: Timecode? // required
        public var duration: Timecode?
        public var note: String?
        
        // FCPXMLElementContext
        @EquatableAndHashableExempt
        public var context: FinalCutPro.FCPXML.ElementContext
        
        public init(
            name: String,
            start: Timecode?,
            duration: Timecode?,
            note: String?,
            // FCPXMLElementContext
            context: FinalCutPro.FCPXML.ElementContext = .init()
        ) {
            self.start = start
            self.duration = duration
            self.name = name
            self.note = note
            
            // FCPXMLElementContext
            self.context = context
        }
    }
}

extension FinalCutPro.FCPXML.Keyword: FCPXMLAnnotationElement {
    public enum Attributes: String, XMLParsableAttributesKey {
        case name
        case start
        case duration
        case note
    }
    
    public init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        let rawValues = xmlLeaf.parseAttributesRawValues(key: Attributes.self)
        
        // `name`
        guard let nameValue = rawValues[.name] else { return nil }
        name = nameValue
        
        // `start`
        start = try? FinalCutPro.FCPXML.timecode(
            fromRational: rawValues[.start] ?? "",
            xmlLeaf: xmlLeaf,
            resources: resources
        )
        
        // `duration`
        duration = try? FinalCutPro.FCPXML.timecode(
            fromRational: rawValues[.duration] ?? "",
            xmlLeaf: xmlLeaf,
            resources: resources
        )
        
        // `note`
        note = rawValues[.note]
        
        // FCPXMLElementContext
        context = FinalCutPro.FCPXML.ElementContext(from: xmlLeaf, resources: resources)
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == annotationType.rawValue else { return nil }
    }
    
    public var annotationType: FinalCutPro.FCPXML.AnnotationType { .keyword }
    public func asAnyAnnotation() -> FinalCutPro.FCPXML.AnyAnnotation { .keyword(self) }
}

extension FinalCutPro.FCPXML.Keyword: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        [self.asAnyElement()]
    }
    
    public func extractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyElement],
        matching predicate: (_ element: FinalCutPro.FCPXML.AnyElement) -> Bool
    ) -> [FinalCutPro.FCPXML.AnyElement] {
        []
    }
}

#endif
