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
    public var fcpEvents: LazyMapSequence<
        LazyFilterSequence<LazyMapSequence<
            LazyFilterSequence<LazyMapSequence<
                LazyFilterSequence<LazyMapSequence<LazySequence<[XMLNode]>.Elements, XMLElement?>>,
                XMLElement
            >.Elements>.Elements,
            FinalCutPro.FCPXML.Event?
        >>,
        FinalCutPro.FCPXML.Event
    > {
        childElements
            .filter { $0.fcpElementType == .structure(.event) }
            .compactMap(\.fcpAsEvent)
    }
    
    /// FCPXML: Returns child `project` elements.
    public var fcpProjects: LazyMapSequence<
        LazyFilterSequence<LazyMapSequence<
            LazyFilterSequence<LazyMapSequence<
                LazyFilterSequence<LazyMapSequence<LazySequence<[XMLNode]>.Elements, XMLElement?>>,
                XMLElement
            >.Elements>.Elements,
            FinalCutPro.FCPXML.Project?
        >>,
        FinalCutPro.FCPXML.Project
    > {
        childElements
            .filter { $0.fcpElementType == .structure(.project) }
            .compactMap(\.fcpAsProject)
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

// MARK: - Child Elements

extension XMLElement {
    /// Updates the `stringValue` of a child if it exists.
    /// If the new value is `nil`, the child element is removed.
    func _updateChildElement(named childName: String, newStringValue: String?) {
        if let existingChild = firstChildElement(named: childName) {
            if let newStringValue = newStringValue {
                existingChild.stringValue = newStringValue
            } else {
                existingChild.detach()
            }
        } else {
            if let newStringValue = newStringValue {
                let newNote = XMLElement(name: childName)
                newNote.stringValue = newStringValue
                addChild(newNote)
            }
        }
    }
}

// MARK: - Attributes Gathering

extension XMLElement {
    /// Returns the first ancestor clip, if the element is contained within a clip.
    public func fcpAncestorClip<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        includeSelf: Bool
    ) -> XMLElement? {
        let ancestors = ancestorElements(overrideWith: ancestors, includingSelf: includeSelf)
        let clipTypeStrings = FinalCutPro.FCPXML.ClipType.allCases.map(\.rawValue)
        return ancestors
            .first(whereElementNamed: clipTypeStrings)
    }
    
    /// FCPXML: Returns type and lane for each of the element's ancestors.
    func _fcpAncestorElementTypesAndLanes<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        includeSelf: Bool
    ) -> LazyMapSequence<
        LazyFilterSequence<
            LazyMapSequence<
                LazySequence<AnySequence<XMLElement>>.Elements,
                (type: FinalCutPro.FCPXML.ElementType, lane: Int?)?
            >
        >,
        (type: FinalCutPro.FCPXML.ElementType, lane: Int?)
    > {
        let ancestors = ancestorElements(overrideWith: ancestors, includingSelf: includeSelf)
        return ancestors
            .lazy
            .compactMap { ancestor -> (type: FinalCutPro.FCPXML.ElementType, lane: Int?)? in
                guard let type = ancestor.fcpElementType else { return nil }
                let laneStr = ancestor.fcpLane
                let lane: Int? = laneStr != nil ? Int(laneStr!) : nil
                return (type: type, lane: lane)
            }
    }
}

#endif
