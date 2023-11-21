//
//  FCPXML Caption.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Represents a closed caption.
    public struct Caption: Equatable, Hashable, FCPXMLClipAttributes {
        public var note: String?
        public var role: String?
        public var texts: [Text]
        public var textStyleDefinitions: [XMLElement]
        
        // FCPXMLAnchorableAttributes
        public var lane: Int?
        public var offset: Timecode?
        
        // FCPXMLClipAttributes
        public var name: String?
        public var start: Timecode?
        public var duration: Timecode?
        public var enabled: Bool
        
        // TODO: parse children (`text` and `text-style-def` elements)
        
        // FCPXMLElementContext
        @EquatableAndHashableExempt
        public var context: FinalCutPro.FCPXML.ElementContext
        
        public init(
            note: String?,
            role: String?,
            texts: [Text],
            textStyleDefinitions: [XMLElement],
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
            self.note = note
            self.role = role
            self.texts = texts
            self.textStyleDefinitions = textStyleDefinitions
            
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

extension FinalCutPro.FCPXML.Caption: FCPXMLAnnotationElement {
    /// Attributes unique to ``Caption``.
    public enum Attributes: String, XMLParsableAttributesKey {
        case note
        case role
    }
    
    /// Children of ``Caption``.
    public enum Children: String {
        case text
        case textStyleDef = "text-style-def"
    }
    
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        note = rawValues[.note]
        role = rawValues[.role]
        texts = Self.parseTexts(from: xmlLeaf)
        textStyleDefinitions = Self.parseTextStyleDefinitions(from: xmlLeaf)
        
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
        guard xmlLeaf.name == annotationType.rawValue else { return nil }
    }
    
    static func parseTexts(from xmlLeaf: XMLElement) -> [FinalCutPro.FCPXML.Text] {
        let elements = (xmlLeaf.children ?? [])
            .filter { $0.name == Children.text.rawValue }
            .compactMap { $0 as? XMLElement }
        return elements.compactMap { FinalCutPro.FCPXML.Text(from: $0) }
    }
    
    // TODO: parse XML into strongly typed structs
    static func parseTextStyleDefinitions(from xmlLeaf: XMLElement) -> [XMLElement] {
        (xmlLeaf.children ?? [])
            .filter { $0.name == Children.textStyleDef.rawValue }
            .compactMap { $0 as? XMLElement }
    }
    
    public var annotationType: FinalCutPro.FCPXML.AnnotationType { .caption }
    public func asAnyAnnotation() -> FinalCutPro.FCPXML.AnyAnnotation { .caption(self) }
}

extension FinalCutPro.FCPXML.Caption: FCPXMLExtractable {
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
