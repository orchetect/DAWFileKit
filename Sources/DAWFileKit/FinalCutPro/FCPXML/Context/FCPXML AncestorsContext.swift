//
//  FCPXML AncestorsContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Ancestors context for a model element.
    /// Adds context information for an element's parent, as well as absolute timecode information.
    public struct AncestorsContext: Equatable, Hashable {
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

extension FinalCutPro.FCPXML.AncestorsContext {
    public init() { }
    
    public init(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        let tools = FinalCutPro.FCPXML.ContextTools(xmlLeaf: xmlLeaf, resources: resources)
        self.init(tools: tools)
    }
    
    public init(
        // from xmlLeaf: XMLElement,
        // resources: [String: FinalCutPro.FCPXML.AnyResource],
        tools: FinalCutPro.FCPXML.ContextTools
    ) {
        absoluteStart = tools.absoluteStart
        ancestorEventName = tools.ancestorEventName
        ancestorProjectName = tools.ancestorProjectName
        
        parentType = tools.parentType
        parentName = tools.parentName
        parentAbsoluteStart = tools.parentAbsoluteStart
        parentDuration = tools.parentDuration
    }
}

extension FinalCutPro.FCPXML.AncestorsContext: FCPXMLElementContextBuilder {
    public var contextBuilder: FinalCutPro.FCPXML.ElementContextClosure {
        { element, resources, tools in
            ["ancestors": Self(tools: tools)]
        }
    }
}

// MARK: - Static Constructor

extension FCPXMLElementContextBuilder where Self == FinalCutPro.FCPXML.AncestorsContext {
    /// Ancestors context for a model element.
    /// Adds context information for an element's parent, as well as absolute timecode information.
    public static var ancestors: FinalCutPro.FCPXML.AncestorsContext {
        FinalCutPro.FCPXML.AncestorsContext()
    }
}

#endif
