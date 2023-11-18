//
//  FCPXML ElementContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Context for a model element.
    ///
    /// Adds context information for an element's parent, as well as absolute timecode information.
    public struct ElementContext: Equatable, Hashable {
        /// The absolute start timecode of the element.
        public var absoluteStart: Timecode?
        
        /// Contains an event name if the element is a descendent of an event.
        public var ancestorEventName: String?
        
        /// Contains a project name if the element is a descendent of a project.
        public var ancestorProjectName: String?
        
        /// The parent clip's type.
        public var parentType: ElementType?
        
        /// The parent clip's name.
        public var parentName: String?
        
        /// The parent clip's absolute start time.
        public var parentAbsoluteStart: Timecode?
        
        /// The parent clip's duration.
        public var parentDuration: Timecode?
        
        public init(
            absoluteStart: Timecode? = nil,
            ancestorEventName: String? = nil,
            ancestorProjectName: String? = nil,
            parentType: ElementType? = nil,
            parentName: String? = nil,
            parentAbsoluteStart: Timecode? = nil,
            parentDuration: Timecode? = nil
        ) {
            self.absoluteStart = absoluteStart
            self.ancestorEventName = ancestorEventName
            self.ancestorProjectName = ancestorProjectName
            self.parentType = parentType
            self.parentName = parentName
            self.parentAbsoluteStart = parentAbsoluteStart
            self.parentDuration = parentDuration
        }
    }
}

extension FinalCutPro.FCPXML.ElementContext {
    public init(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        absoluteStart = FinalCutPro.FCPXML.calculateAbsoluteStart(
            element: xmlLeaf,
            resources: resources
        )
        
        let ancestorEvent = xmlLeaf.first(
            ancestorNamed: FinalCutPro.FCPXML.StructureElementType.event.rawValue
        )
        ancestorEventName = FinalCutPro.FCPXML.getNameAttribute(from: ancestorEvent)
        
        let ancestorProject = xmlLeaf.first(
            ancestorNamed: FinalCutPro.FCPXML.StructureElementType.project.rawValue
        )
        ancestorProjectName = FinalCutPro.FCPXML.getNameAttribute(from: ancestorProject)
        
        if let parent = xmlLeaf.parentXMLElement {
            if let nameValue = parent.name {
                parentType = FinalCutPro.FCPXML.ElementType(rawValue: nameValue)
            }
            parentName = FinalCutPro.FCPXML.getNameAttribute(from: parent)
            parentAbsoluteStart = FinalCutPro.FCPXML.aggregateOffset(
                of: parent,
                resources: resources
            )
            if let durationValue = parent.attributeStringValue(forName: "duration") {
                parentDuration = try? FinalCutPro.FCPXML.timecode(
                    fromRational: durationValue,
                    xmlLeaf: parent,
                    resources: resources
                )
            }
        }
    }
}

#endif
