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
        case value // a.k.a name
        case start
        case duration
        case note
    }
    
    // no role
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        // `name`
        guard let nameValue = rawValues[.value] else { return nil }
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
        context = contextBuilder.buildContext(from: xmlLeaf, breadcrumbs: breadcrumbs, resources: resources)
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == annotationType.rawValue else { return nil }
    }
    
    public var annotationType: FinalCutPro.FCPXML.AnnotationType { .keyword }
    public func asAnyAnnotation() -> FinalCutPro.FCPXML.AnyAnnotation { .keyword(self) }
}

extension FinalCutPro.FCPXML.Keyword: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        []
    }
    
    public func extractableChildren() -> [FinalCutPro.FCPXML.AnyElement] {
        []
    }
}

#endif