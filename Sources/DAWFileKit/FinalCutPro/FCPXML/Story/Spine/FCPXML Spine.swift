//
//  FCPXML Spine.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Contains elements ordered sequentially in time.
    public struct Spine: FCPXMLAnchorableAttributes {
        public var name: String?
        public var elements: [FinalCutPro.FCPXML.AnyStoryElement]
        
        // FCPXMLAnchorableAttributes
        public var lane: Int?
        public var offset: Timecode?
        
        // FCPXMLElementContext
        @EquatableAndHashableExempt
        public var context: FinalCutPro.FCPXML.ElementContext
        
        public init(
            name: String?,
            elements: [FinalCutPro.FCPXML.AnyStoryElement],
            // FCPXMLAnchorableAttributes
            lane: Int?,
            offset: Timecode?,
            // FCPXMLElementContext
            context: FinalCutPro.FCPXML.ElementContext = .init()
        ) {
            self.name = name
            self.elements = elements
            
            // FCPXMLAnchorableAttributes
            self.lane = lane
            self.offset = offset
            
            // FCPXMLElementContext
            self.context = context
        }
    }
}

extension FinalCutPro.FCPXML.Spine: FCPXMLStoryElement {
    /// Attributes unique to ``Spine``.
    public enum Attributes: String, XMLParsableAttributesKey {
        case name
    }
    
    // no start
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        name = rawValues[.name]
        
        elements = FinalCutPro.FCPXML.storyElements( // adds xmlLeaf as breadcrumb
            in: xmlLeaf,
            breadcrumbs: breadcrumbs,
            resources: resources,
            contextBuilder: contextBuilder
        )
        
        let anchorableAttributes = Self.parseAnchorableAttributes(
            from: xmlLeaf,
            resources: resources
        )
        
        // FCPXMLAnchorableAttributes
        lane = anchorableAttributes.lane
        offset = anchorableAttributes.offset
        
        // FCPXMLElementContext
        context = contextBuilder.buildContext(from: xmlLeaf, breadcrumbs: breadcrumbs, resources: resources)
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == storyElementType.rawValue else { return nil }
    }
    
    public var storyElementType: FinalCutPro.FCPXML.StoryElementType { .spine }
    public func asAnyStoryElement() -> FinalCutPro.FCPXML.AnyStoryElement { .spine(self) }
}

extension FinalCutPro.FCPXML.Spine: FCPXMLExtractable {
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
            contents: elements.asAnyElements(),
            matching: predicate
        )
    }
}

#endif
