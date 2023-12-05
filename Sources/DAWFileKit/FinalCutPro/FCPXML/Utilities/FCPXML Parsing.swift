//
//  FCPXML Parsing.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

// MARK: - Elements

extension XMLElement {
    /// Returns the element type of the element.
    public var fcpElementType: FinalCutPro.FCPXML.ElementType? {
        FinalCutPro.FCPXML.ElementType(from: self)
    }
}

// MARK: - Story Elements

extension XMLElement {
    /// Returns child story elements.
    public var fcpStoryElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.fcpStoryElementType != nil }
    }
    
    /// Returns the story element type of the element if the element is a story element.
    public var fcpStoryElementType: FinalCutPro.FCPXML.StoryElementType? {
        FinalCutPro.FCPXML.StoryElementType(from: self)
    }
}

// MARK: - Events

extension XMLElement {
    public var fcpEvents: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.fcpElementType == .structure(.event) }
    }
}

// MARK: - Resources

extension XMLElement {
    /// Returns the root-level `fcpxml` element.
    /// This may be called on any element within a FCPXML.
    public var fcpRoot: XMLElement? {
        rootDocument?
            .rootElement()?
            .firstChildElement(named: FinalCutPro.FCPXML.RootChildren.fcpxml.rawValue)
    }
    
    /// Returns the root-level `fcpxml/resources` element.
    /// This may be called on any element within a FCPXML.
    public var fcpRootResources: XMLElement? {
        fcpRoot?
            .firstChildElement(named: FinalCutPro.FCPXML.Children.resources.rawValue)
    }
    
    /// Returns the resource element for the given resource ID from within the root-level
    /// `fcpxml/resources` element.
    /// This may be called on any element within a FCPXML.
    ///
    /// - Parameters:
    ///   - resourceID: Resource identifier string. (ie: "r1")
    ///   - resources: Optionally supply a resources element.
    ///     If `nil`, the resources from the XML document will be located and used.
    ///     This may be useful with isolated testing when a full FCPXML document is not loaded and
    ///     the document does not contain any resources to be found.
    /// - Returns: Resource element for the given ID.
    public func fcpResource(
        forID resourceID: String,
        in resources: XMLElement? = nil
    ) -> XMLElement? {
        (resources ?? fcpRootResources)?
            .childElements
            .first(whereAttribute: "id", hasValue: resourceID)
    }
}

#endif
