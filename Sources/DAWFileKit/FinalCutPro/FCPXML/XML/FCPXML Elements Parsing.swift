//
//  FCPXML Elements Parsing.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore
import TimecodeKit

// MARK: - Resources

extension XMLElement {
    /// FCPXML: Returns the resource type of the element if it is a resource element.
    public var fcpResourceType: FinalCutPro.FCPXML.ResourceType? {
        FinalCutPro.FCPXML.ResourceType(from: self)
    }
}

// MARK: - Any Elements

extension XMLElement {
    /// FCPXML: Returns the element type of the element.
    public var fcpElementType: FinalCutPro.FCPXML.ElementType? {
        FinalCutPro.FCPXML.ElementType(from: self)
    }
}

// MARK: - Structure Elements

extension XMLElement {
    /// FCPXML: Returns child structure elements.
    public var fcpStructureElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.fcpStructureElementType != nil }
    }
    
    /// FCPXML: Returns the structure element type of the element if the element is a structure
    /// element.
    public var fcpStructureElementType: FinalCutPro.FCPXML.StructureElementType? {
        FinalCutPro.FCPXML.StructureElementType(from: self)
    }
}

extension XMLElement {
    /// FCPXML: Returns child `event` elements.
    public var fcpEvents: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.fcpElementType == .structure(.event) }
    }
    
    /// FCPXML: Returns child `project` elements.
    public var fcpProjects: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.fcpElementType == .structure(.project) }
    }
}

// MARK: - Story Elements

extension XMLElement {
    /// FCPXML: Returns child story elements.
    public var fcpStoryElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.fcpStoryElementType != nil }
    }
    
    /// FCPXML: Returns the story element type of the element if the element is a story element.
    public var fcpStoryElementType: FinalCutPro.FCPXML.StoryElementType? {
        FinalCutPro.FCPXML.StoryElementType(from: self)
    }
}

#endif
