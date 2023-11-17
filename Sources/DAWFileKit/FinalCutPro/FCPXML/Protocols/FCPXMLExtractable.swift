//
//  FCPXMLExtractable.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
@_implementationOnly import OTCore

/// A FCPXML element that is capable of extracting its own contents as well as the contents of its
/// children, if any.
public protocol FCPXMLExtractable { // parent/container
    /// Extract elements from the element and optionally recursively from all sub-elements.
    /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
    func extractElements<Element: FCPXMLExtractableElement>(
        settings: FCPXMLExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> [FinalCutPro.FCPXML.ExtractedElement<Element>]
}

/// A FCPXML element that is capable of being extracted by a ``FCPXMLExtractable``-conforming parent
/// element.
public protocol FCPXMLExtractableElement: FCPXMLStoryElement {
    var start: Timecode? { get }
    var name: String? { get }
}

public struct FCPXMLExtractionSettings {
    // /// If `true`, perform a deep traversal recursively gathering child elements from all sub-elements.
    // /// If `false`, perform a shallow traversal of only the element's own child elements.
    // public var deep: Bool
    
    /// Filter to apply to Auditions.
    public var auditionMask: FinalCutPro.FCPXML.Audition.Mask
    
    /// Element types to exclude during extraction.
    public var excludeTypes: [FinalCutPro.FCPXML.StoryElementType]
    
    // internal
    var ancestorEventName: String?
    var ancestorProjectName: String?
    
    public init(
        // deep: Bool,
        excludeTypes: [FinalCutPro.FCPXML.StoryElementType] = [],
        auditionMask: FinalCutPro.FCPXML.Audition.Mask = .activeAudition
    ) {
        // self.deep = deep
        self.excludeTypes = excludeTypes
        self.auditionMask = auditionMask
    }
    
    @_disfavoredOverload
    init(
        // deep: Bool,
        excludeTypes: [FinalCutPro.FCPXML.StoryElementType] = [],
        auditionMask: FinalCutPro.FCPXML.Audition.Mask = .activeAudition,
        ancestorEventName: String? = nil,
        ancestorProjectName: String? = nil
    ) {
        // self.deep = deep
        self.excludeTypes = excludeTypes
        self.auditionMask = auditionMask
        self.ancestorEventName = ancestorEventName
        self.ancestorProjectName = ancestorProjectName
    }
}

extension FCPXMLExtractionSettings {
    func updating(ancestorEventName: String? = nil, ancestorProjectName: String? = nil) -> Self {
        var copy = self
        if let ancestorEventName = ancestorEventName {
            copy.ancestorEventName = ancestorEventName
        }
        if let ancestorProjectName = ancestorProjectName {
            copy.ancestorProjectName = ancestorProjectName
        }
        return copy
    }
}

extension FinalCutPro.FCPXML {
    /// Contains an extracted element along with pertinent contextual metadata.
    public struct ExtractedElement<Element: FCPXMLStoryElement> {
        public var element: Element
        
        public var context: ElementContext
    }
}

#endif
