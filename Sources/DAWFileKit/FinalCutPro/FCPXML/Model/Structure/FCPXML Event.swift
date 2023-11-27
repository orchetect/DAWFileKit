//
//  FCPXML Event.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import CoreMedia
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Represent a single event in a library.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > An event may contain clips as story elements and projects, along with keyword collections
    /// > and smart collections. The keyword-collection and smart-collection elements organize clips
    /// > by keywords and other matching criteria listed under the Smart Collection Match Elements.
    public struct Event {
        public var name: String?
        public var uid: String?
        
        public var projects: [Project]
        public var clips: [AnyClip]
        
        // TODO: public var collectionFolders: [CollectionFolder] = []
        // TODO: public var keywordCollections: [KeywordCollection] = []
        // TODO: public var smartCollections: [SmartCollection] = []
        
        // FCPXMLElementContext
        @EquatableAndHashableExempt
        public var context: FinalCutPro.FCPXML.ElementContext
        
        public init(
            name: String? = nil,
            uid: String? = nil,
            projects: [Project] = [],
            clips: [AnyClip] = [],
            // FCPXMLElementContext
            context: FinalCutPro.FCPXML.ElementContext = .init()
        ) {
            self.name = name
            self.uid = uid
            self.projects = projects
            self.clips = clips
            
            // FCPXMLElementContext
            self.context = context
        }
    }
}

extension FinalCutPro.FCPXML.Event: FCPXMLStructureElement {
    /// Attributes unique to ``Event``.
    public enum Attributes: String, XMLParsableAttributesKey {
        case name
        case uid
    }
    
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        name = rawValues[.name]
        uid = rawValues[.uid]
        
        projects = FinalCutPro.FCPXML
            .structureElements( // adds xmlLeaf as breadcrumb
                in: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            )
            .projects()
        
        clips = FinalCutPro.FCPXML
            .storyElements( // adds xmlLeaf as breadcrumb
                in: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            )
            .clips()
        
        // FCPXMLElementContext
        context = contextBuilder.buildContext(from: xmlLeaf, breadcrumbs: breadcrumbs, resources: resources)
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == structureElementType.rawValue else { return nil }
    }
    
    public var structureElementType: FinalCutPro.FCPXML.StructureElementType {
        .event
    }
    
    public func asAnyStructureElement() -> FinalCutPro.FCPXML.AnyStructureElement {
        .event(self)
    }
}

extension FinalCutPro.FCPXML.Event: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        []
    }
    
    public func extractableChildren() -> [FinalCutPro.FCPXML.AnyElement] {
        let p = projects.asAnyElements()
        let c = clips.asAnyElements()
        
        return p + c
    }
}

#endif