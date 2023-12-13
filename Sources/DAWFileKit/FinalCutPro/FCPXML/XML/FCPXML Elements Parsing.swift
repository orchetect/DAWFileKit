//
//  FCPXML Elements Parsing.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

// MARK: - Structure Elements

extension XMLElement {
    /// FCPXML: Returns child structure elements.
    public var fcpStructureElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.fcpElementType?.isStructure == true }
    }
}

// MARK: - Story Elements

extension XMLElement {
    /// FCPXML: Returns child story elements.
    public var fcpStoryElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.fcpElementType?.isStoryElement == true }
    }
}

extension XMLElement {
    /// FCPXML: Returns child timeline elements.
    public var fcpTimelineElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.fcpElementType?.isTimeline == true }
    }
}

// MARK: - Child Elements

extension XMLElement {
    /// Updates the `stringValue` of the first matching child if it exists.
    /// If the new value is `nil`, the child element is removed.
    func _updateFirstChildElement(
        ofType childType: FinalCutPro.FCPXML.ElementType,
        newStringValue: String?
    ) { 
        _updateChildElement(named: childType.rawValue, newStringValue: newStringValue)
    }
    
    /// Updates the `stringValue` of the first matching child if it exists.
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
    ///
    /// Ancestors are ordered nearest to furthest.
    public func fcpAncestorClip<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        includeSelf: Bool
    ) -> XMLElement? {
        let ancestors = ancestorElements(overrideWith: ancestors, includingSelf: includeSelf)
        let clipTypes = FinalCutPro.FCPXML.ElementType.allClipCases
        return ancestors
            .first(whereFCPElementTypes: clipTypes)
    }
    
    /// FCPXML: Returns type and lane for each of the element's ancestors.
    ///
    /// Ancestors are ordered nearest to furthest.
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
