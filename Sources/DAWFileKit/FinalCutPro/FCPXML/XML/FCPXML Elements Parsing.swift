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
    /// FCPXML: Returns immediate child story elements.
    public var fcpStoryElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.fcpElementType?.isStoryElement == true }
    }
}

extension XMLElement {
    /// FCPXML: Returns immediate child timeline elements.
    public var fcpTimelineElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.fcpElementType?.isTimeline == true }
    }
    
    /// FCPXML: Returns immediate child timeline model objects wrapped in type-erased
    /// ``FinalCutPro/FCPXML/AnyTimeline`` instances.
    public var fcpTimelineElementsAsAnyTimeline: LazyMapSequence<
        LazyFilterSequence<
            LazyMapSequence<
                LazyMapSequence<
                    LazyFilterSequence<LazyMapSequence<
                        LazySequence<[XMLNode]>.Elements,
                        XMLElement?
                    >>, XMLElement
                >.Elements,
                FinalCutPro.FCPXML.AnyTimeline?
            >
        >,
        FinalCutPro.FCPXML.AnyTimeline
    > {
        childElements
            .compactMap { $0.fcpAsAnyTimeline }
    }
    
    /// FCPXML: Recursively returns descendant timelines, including within `library`, `event` and
    /// `project` elements.
    ///
    /// - Returns: Sequence of timeline elements wrapped in a type-erased
    ///   ``FinalCutPro/FCPXML/AnyTimeline`` instance.
    func _fcpMetaTimelinesAsAnyTimelines() -> [FinalCutPro.FCPXML.AnyTimeline] {
        childElements
            .flatMap { element -> [FinalCutPro.FCPXML.AnyTimeline] in
                if let library = element.fcpAsLibrary {
                    return library.childTimelinesAsAnyTimelines()
                } else if let event = element.fcpAsEvent {
                    return event.childTimelinesAsAnyTimelines()
                } else if let project = element.fcpAsProject {
                    return [project.sequenceAsAnyTimeline()]
                } else if let timeline = element.fcpAsAnyTimeline {
                    return [timeline]
                } else {
                    return []
                }
            }
    }
}

// MARK: - Child Elements

extension XMLElement {
    func _addChildren<S: Sequence>(_ models: S) where S.Element: FCPXMLElement {
        for model in models {
            addChild(model.element)
        }
    }
    
    func _updateChildElements<S: Sequence>(
        ofType elementType: FinalCutPro.FCPXML.ElementType,
        with newChildren: S
    ) where S.Element: XMLNode {
        // remove existing children of the element type first
        removeChildren { child in
            child.fcpElementType == elementType
        }
        
        // add new children
        addChildren(newChildren)
    }
    
    func _updateChildElements<S: Sequence, T: FCPXMLElementModelTypeProtocol>(
        ofType elementType: T,
        with newChildren: S
    ) where S.Element: FCPXMLElement, T.ModelType == S.Element {
        // remove existing children of the element type first
        removeChildren { child in
            guard let ct = child.fcpElementType else { return false }
            return elementType.supportedElementTypes.contains(ct)
        }
        
        // add new children
        _addChildren(newChildren)
    }
    
    func _updateChildElements(
        ofType elementType: FinalCutPro.FCPXML.ElementType,
        withChild newChild: XMLNode?,
        default defaultChild: XMLNode? = nil
    ) {
        // remove existing children of the element type first
        removeChildren { child in
            child.fcpElementType == elementType
        }
        
        // add new child
        if let newChild = newChild ?? defaultChild {
            addChild(newChild)
        }
    }
    
    func _updateChildElements<M: FCPXMLElement>(
        ofType modelType: FinalCutPro.FCPXML.ElementModelType<M>,
        withChild newChild: M?,
        default defaultChild: M? = nil
    ) {
        // remove existing children of the element type first
        removeChildren { child in
            guard let ct = child.fcpElementType else { return false }
            return modelType.supportedElementTypes.contains(ct)
        }
        
        // add new child
        if let newChild = newChild?.element ?? defaultChild?.element {
            addChild(newChild)
        }
    }
    
    func _updateFirstChildElement<M: FCPXMLElement>(
        ofType modelType: FinalCutPro.FCPXML.ElementModelType<M>,
        withChild newChild: M?,
        default defaultChild: M? = nil
    ) {
        let newElement = newChild?.element ?? defaultChild?.element
        
        if let existingChild = firstChild(whereFCPElement: modelType)?.element {
            if let newElement = newElement {
                if newElement != existingChild {
                    replaceChild(at: existingChild.index, with: newElement)
                }
            } else {
                removeChild(at: existingChild.index)
            }
        } else if let newElement = newElement {
            addChild(newElement)
        }
    }
    
    func _updateFirstChildElement(
        ofType elementType: FinalCutPro.FCPXML.ElementType,
        withChild newChild: XMLElement?,
        default defaultChild: @autoclosure () -> XMLElement? = { nil }()
    ) {
        let newElement = newChild ?? defaultChild()
        
        if let existingChild = firstChildElement(whereFCPElementType: elementType) {
            if let newElement = newElement {
                if newElement != existingChild {
                    replaceChild(at: existingChild.index, with: newElement)
                }
            } else {
                removeChild(at: existingChild.index)
            }
        } else if let newElement = newElement {
            addChild(newElement)
        }
    }
    
    func _updateDefaultedFirstChildElement(
        ofType elementType: FinalCutPro.FCPXML.ElementType,
        withChild newChild: XMLElement?
    ) {
        _updateFirstChildElement(
            ofType: elementType,
            withChild: newChild,
            default: XMLElement(name: elementType.rawValue)
        )
    }
    
    func _removeChildren(
        ofType elementType: FinalCutPro.FCPXML.ElementType
    ) {
        removeChildren { child in
            child.fcpElementType == elementType
        }
    }
    
    func _removeChildren(
        ofTypes elementTypes: Set<FinalCutPro.FCPXML.ElementType>
    ) {
        removeChildren { child in
            guard let ct = child.fcpElementType else { return false }
            return elementTypes.contains(ct)
        }
    }
    
    func _removeChildren<Model>(
        ofTypes modelType: FinalCutPro.FCPXML.ElementModelType<Model>
    ) {
        removeChildren { child in
            guard let ct = child.fcpElementType else { return false }
            return modelType.supportedElementTypes.contains(ct)
        }
    }
}

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

// MARK: - Ancestors

extension XMLElement {
    /// Returns the first ancestor clip, if the element is contained within one.
    ///
    /// Ancestors are ordered nearest to furthest.
    public func fcpAncestorClip<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        includingSelf: Bool
    ) -> XMLElement? {
        let ancestors = ancestorElements(overrideWith: ancestors, includingSelf: includingSelf)
        let clipTypes = FinalCutPro.FCPXML.ElementType.allClipCases
        return ancestors
            .first(whereFCPElementTypes: clipTypes)
    }
    
    /// Returns the first ancestor timeline, if the element is contained within one.
    ///
    /// Ancestors are ordered nearest to furthest.
    public func fcpAncestorTimeline<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        includingSelf: Bool,
        withLaneZero: Bool = false
    ) -> (timeline: XMLElement, ancestors: AnySequence<XMLElement>)? {
        var ancestors = ancestorElements(overrideWith: ancestors, includingSelf: includingSelf)
        let timelineTypes = FinalCutPro.FCPXML.ElementType.allTimelineCases
        
        var zeroLaneCount = 0
        var nonZeroLaneCount = 0
        
        for ancestor in ancestors {
            ancestors = ancestors.dropFirst()
            
            guard let elementType = ancestor.fcpElementType else { continue }
            
            let isTimeline = timelineTypes.contains(elementType)
            guard isTimeline else { continue }
            
            // if we don't care about lane, just return early
            guard withLaneZero else {
                if isTimeline {
                    return (timeline: ancestor, ancestors: ancestors)
                } else {
                    continue
                }
            }
            
            let isLaneZero = (ancestor.fcpLane ?? 0) == 0
            
            if isLaneZero {
                zeroLaneCount += 1
            } else {
                nonZeroLaneCount += 1
            }
            
            // first clip encountered has lane zero
            if zeroLaneCount == 1, nonZeroLaneCount == 0 {
                return (timeline: ancestor, ancestors: ancestors)
            }
            
            // skip a generation because we want the clip that is the lane-zero parent
            // clip, lane 0 <-- we want this
            //   - clip, lane 1 <-- skip this
            //     - element <-- self
            if isLaneZero, nonZeroLaneCount > 0 {
                return (timeline: ancestor, ancestors: ancestors)
            }
        }
        
        return nil
    }
    
    /// FCPXML: Returns type and lane for each of the element's ancestors.
    ///
    /// Ancestors are ordered nearest to furthest.
    func _fcpAncestorElementTypesAndLanes<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        includingSelf: Bool
    ) -> LazyMapSequence<
        LazyFilterSequence<
            LazyMapSequence<
                LazySequence<AnySequence<XMLElement>>.Elements,
                (type: FinalCutPro.FCPXML.ElementType, lane: Int?)?
            >
        >,
        (type: FinalCutPro.FCPXML.ElementType, lane: Int?)
    > {
        let ancestors = ancestorElements(overrideWith: ancestors, includingSelf: includingSelf)
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

// MARK: - Children

extension XMLElement {
    /// FCPXML: Finds the nearest child (descendent) timeline.
    func _fcpFirstChildTimelineElement(
        excluding: Set<FinalCutPro.FCPXML.ElementType> = []
    ) -> XMLElement? {
        fcpTimelineElements
            .first(whereFCPElementType: { elementType in
                !excluding.contains(elementType)
            })
    }
}

#endif
