//
//  FCPXMLElementContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

public protocol FCPXMLElementContext {
    /// Additional contextual metadata for the element.
    /// This is generated during FCPXML parsing by using the context builder.
    var context: FinalCutPro.FCPXML.ElementContext { get }
}

public protocol FCPXMLElementContextBuilder {
    var contextBuilder: FinalCutPro.FCPXML.ElementContextClosure { get }
}

extension FCPXMLElementContextBuilder {
    /// Internal: builds the context for the element.
    func buildContext(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> FinalCutPro.FCPXML.ElementContext {
        let tools = FinalCutPro.FCPXML.ContextTools(xmlLeaf: xmlLeaf, resources: resources)
        return contextBuilder(xmlLeaf, resources, tools)
    }
}

extension FinalCutPro.FCPXML {
    /// Context for a model element.
    public typealias ElementContext = [String: Any]
    
    /// Context builder closure for a model element.
    public typealias ElementContextClosure = (
        _ element: XMLElement,
        _ resources: [String: FinalCutPro.FCPXML.AnyResource],
        _ tools: FinalCutPro.FCPXML.ContextTools
    ) -> [String: Any]
    
    /// Class instance that provides useful context for a FCPXML element.
    public struct ContextTools {
        var xmlLeaf: XMLElement
        var resources: [String: FinalCutPro.FCPXML.AnyResource]
        
        init(
            xmlLeaf: XMLElement,
            resources: [String: FinalCutPro.FCPXML.AnyResource]
        ) {
            self.xmlLeaf = xmlLeaf
            self.resources = resources
        }
        
        /// The absolute start timecode of the element.
        /// This is calculated based on ancestor elements.
        public var absoluteStart: Timecode? {
            FinalCutPro.FCPXML.calculateAbsoluteStart(
                element: xmlLeaf,
                resources: resources
            )
        }
        
        /// Returns an event name if the element is a descendent of an event.
        public var ancestorEventName: String? {
            let ancestorEvent = xmlLeaf.first(
                ancestorNamed: FinalCutPro.FCPXML.StructureElementType.event.rawValue
            )
            return FinalCutPro.FCPXML.getNameAttribute(from: ancestorEvent)
        }
        
        /// Returns a project name if the element is a descendent of a project.
        public var ancestorProjectName: String? {
            let ancestorProject = xmlLeaf.first(
                ancestorNamed: FinalCutPro.FCPXML.StructureElementType.project.rawValue
            )
            return FinalCutPro.FCPXML.getNameAttribute(from: ancestorProject)
        }
        
        /// The parent clip's type.
        public var parentType: ElementType? {
            guard let parent = xmlLeaf.parentXMLElement else { return nil }
            guard let nameValue = parent.name else { return nil }
            return FinalCutPro.FCPXML.ElementType(rawValue: nameValue)
        }
        
        /// The parent clip's name.
        public var parentName: String? {
            guard let parent = xmlLeaf.parentXMLElement else { return nil }
            return FinalCutPro.FCPXML.getNameAttribute(from: parent)
        }
        
        /// The parent clip's absolute start time.
        /// This is calculated based on ancestor elements.
        public var parentAbsoluteStart: Timecode? {
            guard let parent = xmlLeaf.parentXMLElement else { return nil }
            return FinalCutPro.FCPXML.aggregateOffset(
                of: parent,
                resources: resources
            )
        }
        
        /// The parent clip's duration.
        public var parentDuration: Timecode? {
            guard let parent = xmlLeaf.parentXMLElement else { return nil }
            guard let durationValue = parent.attributeStringValue(forName: "duration") else { return nil }
            return try? FinalCutPro.FCPXML.timecode(
                fromRational: durationValue,
                xmlLeaf: parent,
                resources: resources
            )
        }
    }
}

#endif
