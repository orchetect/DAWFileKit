//
//  FCPXML Extraction.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore
import TimecodeKit

// MARK: - FCPXMLElement Public Methods

extension FCPXMLElement {
    /// Extract elements from the element and recursively from all sub-elements.
    ///
    /// - Parameters:
    ///   - types: Element types to include. If empty, all element types will be returned.
    ///   - scope: Extraction scope.
    public func extract(
        types elementTypes: Set<FinalCutPro.FCPXML.ElementType>,
        scope: FinalCutPro.FCPXML.ExtractionScope
    ) async -> [FinalCutPro.FCPXML.ExtractedElement] {
        await element.fcpExtract(
            types: elementTypes,
            scope: scope
        )
    }
    
    /// Extract elements using a preset.
    ///
    /// - Parameters:
    ///   - preset: Extraction preset.
    ///   - scope: Extraction scope.
    public func extract<Result>(
        preset: some FCPXMLExtractionPreset<Result>,
        scope: FinalCutPro.FCPXML.ExtractionScope = .mainTimeline
    ) async -> Result {
        await element.fcpExtract(
            preset: preset,
            scope: scope
        )
    }
    
    /// Extract data using a closure that provides access to the element.
    ///
    /// If no implicit data transform is required, use ``extract(types:scope:)`` to simply return
    /// the elements themselves instead.
    ///
    /// - Parameters:
    ///   - transform: A closure to return data for each element.
    ///   - scope: Extraction scope.
    public func extract<Result>(
        scope: FinalCutPro.FCPXML.ExtractionScope = .mainTimeline,
        transform: @escaping (_ element: FinalCutPro.FCPXML.ExtractedElement) -> Result
    ) async -> [Result] {
        await element.fcpExtract(scope: scope, transform: transform)
    }
}

// MARK: - XMLElement Public Methods

extension XMLElement {
    /// Extract elements from the element and recursively from all sub-elements.
    ///
    /// - Parameters:
    ///   - types: Element types to include. If empty, all element types will be returned.
    ///   - scope: Extraction scope.
    public func fcpExtract(
        types elementTypes: Set<FinalCutPro.FCPXML.ElementType>,
        scope: FinalCutPro.FCPXML.ExtractionScope
    ) async -> [FinalCutPro.FCPXML.ExtractedElement] {
        await _fcpExtract(
            types: elementTypes,
            scope: scope,
            ancestors: ancestorElements(includingSelf: false),
            resources: nil
        )
    }
    
    /// Extract data using a preset.
    ///
    /// - Parameters:
    ///   - preset: Extraction preset.
    ///   - scope: Extraction scope.
    public func fcpExtract<Result>(
        preset: some FCPXMLExtractionPreset<Result>,
        scope: FinalCutPro.FCPXML.ExtractionScope = .mainTimeline
    ) async -> Result {
        await preset.perform(
            on: self,
            scope: scope
        )
    }
    
    /// Extract data using a closure that provides access to the element.
    ///
    /// If no implicit data transform is required, use ``fcpExtract(types:scope:)`` to simply return
    /// the elements themselves instead.
    ///
    /// - Parameters:
    ///   - transform: A closure to return data for each element.
    ///   - scope: Extraction scope.
    public func fcpExtract<Result>(
        scope: FinalCutPro.FCPXML.ExtractionScope = .mainTimeline,
        transform: @escaping (_ element: FinalCutPro.FCPXML.ExtractedElement) -> Result
    ) async -> [Result] {
        let extractedElements = await _fcpExtract(
            types: [],
            scope: scope,
            ancestors: ancestorElements(includingSelf: false),
            resources: nil
        )
        
        return await withOrderedTaskGroup(sequence: extractedElements) { extractedElement in
            transform(extractedElement)
        }
    }
}

// MARK: - Extraction Logic

extension XMLElement {
    /// Internal extraction entry point:
    /// Recursively extract elements based on a set of matching criteria and filtering rules.
    ///
    /// - Parameters:
    ///   - types: Element types to include. If empty, all element types will be returned.
    ///   - scope: Extraction scope.
    ///   - ancestors: Ancestors, ordered nearest to furthest ancestor.
    ///   - resources: The document's `resources` container element.
    ///     If `nil`, the `resources` found in the document will be used if present.
    ///   - overrideDirectChildren: Uses the direct children rule supplied instead of the default
    ///     rule for the element type.
    func _fcpExtract<Ancestors: Sequence<XMLElement>>(
        types elementTypes: Set<FinalCutPro.FCPXML.ElementType>,
        scope: FinalCutPro.FCPXML.ExtractionScope,
        ancestors: Ancestors,
        resources: XMLElement?,
        overrideDirectChildren: FinalCutPro.FCPXML.ExtractableChildren? = nil
    ) async -> [FinalCutPro.FCPXML.ExtractedElement] {
        var ancestors: any Sequence<XMLElement> = ancestors
        if scope.constrainToLocalTimeline {
            ancestors = []
        }
        
        var scope = scope
        scope.filteredExtractionTypes = elementTypes
        
        return await _fcpExtract(
            scope: scope,
            ancestors: ancestors,
            resources: resources
        )
    }
    
    /// Internal extraction recursion method:
    /// Recursively extract elements based on a set of matching criteria and filtering rules.
    ///
    /// - Parameters:
    ///   - scope: Extraction scope.
    ///   - ancestors: Ancestors, ordered nearest to furthest ancestor.
    ///   - resources: The document's `resources` container element.
    ///     If `nil`, the `resources` found in the document will be used if present.
    ///   - overrideDirectChildren: Uses the direct children rule supplied instead of the default
    ///     rule for the element type.
    private func _fcpExtract<Ancestors: Sequence<XMLElement>>(
        scope: FinalCutPro.FCPXML.ExtractionScope,
        ancestors: Ancestors,
        resources: XMLElement?,
        overrideDirectChildren: FinalCutPro.FCPXML.ExtractableChildren? = nil
    ) async -> [FinalCutPro.FCPXML.ExtractedElement] {
        // self
        
        let selfExtractedElement = FinalCutPro.FCPXML.ExtractedElement(
            element: self,
            breadcrumbs: Array(ancestors),
            resources: resources
        )
        
        let keepForExtraction = Self._fcpShouldKeepForExtraction(
            extractedElement: selfExtractedElement,
            scope: scope,
            ancestors: ancestors
        )
        
        let keepForTraversal = Self._fcpShouldKeepForTraversal(
            extractedElement: selfExtractedElement,
            scope: scope,
            ancestors: ancestors
        )
        
        var extractedElements: [FinalCutPro.FCPXML.ExtractedElement] = []
        
        // occlusion - apply to both traversal and extraction
        let occlusion = _fcpEffectiveOcclusion(ancestors: ancestors)
        if !scope.occlusions.contains(occlusion) {
            return extractedElements
        }
        
        if keepForExtraction {
            extractedElements.append(contentsOf: [selfExtractedElement])
        }
        
        // gather immediate children with `lane != 0` which should be considered peers
        // with the current element
        
        let extractedPeers = await _fcpExtractPeers(
            scope: scope,
            ancestors: ancestors,
            resources: resources
        )
        extractedElements.append(contentsOf: extractedPeers) // already filtered by predicate
        
        if !keepForTraversal {
            return extractedElements
        }
        
        // get recursing information
        
        guard let recurse = overrideDirectChildren
                ?? _fcpExtractableChildren(
                    resources: resources,
                    auditions: scope.auditions,
                    mcClipAngleMask: scope.mcClipAngles
                )
        else { return extractedElements }
        
        // direct children, if any
        if let childrenRule = recurse.children {
            let extractedChildren = await _fcpExtractDirectChildren(
                childrenRule: childrenRule,
                scope: scope,
                ancestors: ancestors,
                resources: resources
            )
            extractedElements.append(contentsOf: extractedChildren) // already filtered by predicate
        }
        
        // explicit descendants that are not automatically recursive, if any
        
        if let descendants = recurse.descendants, !descendants.isEmpty {
            let extractedDescendants = await _fcpExtractDescendants(
                descendants: descendants,
                scope: scope,
                ancestors: ancestors,
                resources: resources
            )
            extractedElements.append(contentsOf: extractedDescendants) // already filtered by predicate
        }
        
        return extractedElements
    }
    
    private func _fcpExtractPeers<Ancestors: Sequence<XMLElement>>(
        scope: FinalCutPro.FCPXML.ExtractionScope,
        ancestors: Ancestors,
        resources: XMLElement?
    ) async -> some Sequence<FinalCutPro.FCPXML.ExtractedElement> {
        // gather immediate children with `lane != 0` which should be considered peers
        // with the current element
        
        let elements = childElements
        // filter out peers of parent, which we already handled in main extraction method
            .filter { ($0.fcpLane ?? 0) != 0 }
        
        let extracted = await withOrderedTaskGroup(sequence: elements) { element in
            await element._fcpExtract(
                scope: scope,
                ancestors: [self] + ancestors,
                resources: resources
            )
        }
        
        let output = extracted.flatMap { $0 }
        
        return output
    }
        
    /// Helper to extract direct children of the element.
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    private func _fcpExtractDirectChildren<Ancestors: Sequence<XMLElement>>(
        childrenRule: FinalCutPro.FCPXML.ExtractableChildren.DirectChildren,
        scope: FinalCutPro.FCPXML.ExtractionScope,
        ancestors: Ancestors,
        resources: XMLElement?
    ) async -> [FinalCutPro.FCPXML.ExtractedElement] {
        let childrenSource: any Sequence<XMLElement>
        
        switch childrenRule {
        case .all:
            childrenSource = childElements
        case let .specific(childrenSequence):
            childrenSource = childrenSequence
        }
        
        let elements = childrenSource
            // filter out peers of parent, which we already handled in main extraction method
            .filter { ($0.fcpLane ?? 0) == 0 }
        
        let extracted = await withOrderedTaskGroup(sequence: elements) { element in
            await element._fcpExtract(
                scope: scope,
                ancestors: [self] + ancestors,
                resources: resources
            )
        }
        
        let output = extracted.flatMap { $0 }
        
        return output
    }
    
    /// Helper to extract further descendants of the element in special circumstances.
    ///
    /// - Note: This is not used for all descendants of any element, but for rare cases where a
    /// generational jump is required due to how elements are referenced. (`mc-clip` is one such example).
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    ///
    /// Descendants are ordered nearest to furthest descendant.
    private func _fcpExtractDescendants<Ancestors: Sequence<XMLElement>>(
        descendants: [FinalCutPro.FCPXML.ExtractableChildren.Descendant],
        scope: FinalCutPro.FCPXML.ExtractionScope,
        ancestors: Ancestors,
        resources: XMLElement?
    ) async -> [FinalCutPro.FCPXML.ExtractedElement] {
        // each descendant record has an element, as well as an optional sequence of children
        
        var descendantAccum: [XMLElement] = []
        
        var descendantsIterator = descendants.makeIterator()
        typealias IteratorResult = (
            descendant: FinalCutPro.FCPXML.ExtractableChildren.Descendant,
            accum: [XMLElement]
        )
        let iterator = AnyIterator { () -> IteratorResult? in
            guard let next = descendantsIterator.next() else { return nil }
            defer { descendantAccum.insert(next.element, at: 0) }
            return (descendant: next, accum: descendantAccum)
        }
        
        // parse from nearest descendent to furthest, which is the same as
        // parsing ancestors from furthest to nearest
        let extracted = await withOrderedTaskGroup(sequence: iterator) { (descendant, accum) in
            await descendant.element._fcpExtract(
                scope: scope,
                ancestors: accum + [self] + ancestors,
                resources: resources,
                overrideDirectChildren: descendant.children
            )
        }
        
        let output = extracted.flatMap { $0 }
        
        return output
    }
    
    /// Returns `true` if the element should be filtered (kept) in returned elements.
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    static func _fcpShouldKeepForExtraction<Ancestors: Sequence<XMLElement>>(
        extractedElement: FinalCutPro.FCPXML.ExtractedElement,
        scope: FinalCutPro.FCPXML.ExtractionScope,
        ancestors: Ancestors
    ) -> Bool {
        // we can apply inclusion-filter even if we don't know the element type
        if !scope.filteredExtractionTypes.isEmpty {
            if let elementType = extractedElement.element.fcpElementType {
                if !scope.filteredExtractionTypes.contains(elementType) {
                    return false
                }
            } else {
                // we have an element without a ElementType case, but the filter is non-nil
                // so we know it has to get filtered out
                return false
            }
        }
        
        // we can only exclude element types if has a type concretely known to us
        if let elementType = extractedElement.element.fcpElementType {
            if scope.excludedExtractionTypes.contains(elementType) {
                return false
            }
        }
        
        if let maxContainerDepth = scope.maxContainerDepth,
           _fcpContainerDepth(in: ancestors) > maxContainerDepth
        {
            return false
        }
        
        let enabledState = extractedElement.element.fcpGetEnabled(default: true)
        if !scope.includeDisabled, !enabledState {
            return false
        }
        
        if let predicate = scope.extractionPredicate,
           !predicate(extractedElement)
        {
            return false
        }
        
        return true
    }
    
    /// Returns `true` if the element should be filtered (kept) and further traversed.
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    static func _fcpShouldKeepForTraversal<Ancestors: Sequence<XMLElement>>(
        extractedElement: FinalCutPro.FCPXML.ExtractedElement,
        scope: FinalCutPro.FCPXML.ExtractionScope,
        ancestors: Ancestors
    ) -> Bool {
        // we can apply inclusion-filter even if we don't know the element type
        if !scope.filteredTraversalTypes.isEmpty {
            if let elementType = extractedElement.element.fcpElementType {
                if !scope.filteredTraversalTypes.contains(elementType) {
                    return false
                }
            } else {
                // we have an element without a ElementType case, but the filter is non-nil
                // so we know it has to get filtered out
                return false
            }
        }
        
        // we can only exclude element types if has a type concretely known to us
        if let elementType = extractedElement.element.fcpElementType {
            if scope.excludedTraversalTypes.contains(elementType) {
                return false
            }
        }
        
        if let maxContainerDepth = scope.maxContainerDepth,
           _fcpContainerDepth(in: ancestors) > maxContainerDepth
        {
            return false
        }
        
        let enabledState = extractedElement.element.fcpGetEnabled(default: true)
        if !scope.includeDisabled, !enabledState {
            return false
        }
        
        if let predicate = scope.traversalPredicate,
           !predicate(extractedElement)
        {
            return false
        }
        
        return true
    }
    
    /// Returns number of container elements found in an ancestor chain.
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    static func _fcpContainerDepth<Ancestors: Sequence<XMLElement>>(
        in ancestors: Ancestors
    ) -> Int {
        var count = 0
        var isTraversingContainerClip = false
        for ancestor in ancestors {
            let elementType = ancestor.fcpElementType
            let isTimeline = elementType?.isTimeline == true
                && (elementType != nil && elementType != .spine) // don't include spines
            let hasNoLane = (ancestor.fcpLane ?? 0) == 0
            
            if elementType == .assetClip || elementType == .refClip {
                if isTraversingContainerClip {
                    // don't count asset clips within an asset clip
                    // TODO: should this also apply to other clip types?
                    continue
                }
                isTraversingContainerClip = true
            }
            
            if isTimeline, hasNoLane { count += 1 }
        }
        return count
    }
}

// MARK: - Helpers

extension XMLElement {
    /// Return effective lane for the element.
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    func _fcpEffectiveLane<Ancestors: Sequence<XMLElement>>(
        ancestors: Ancestors
    ) -> Int? {
        _fcpAncestorElementTypesAndLanes(ancestors: ancestors, includingSelf: true)
            .first(where: { $0.lane != nil })?
            .lane
    }
}

#endif
