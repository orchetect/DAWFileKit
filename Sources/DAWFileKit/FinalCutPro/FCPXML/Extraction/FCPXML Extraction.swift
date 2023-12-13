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
    ///   - constrainToLocalTimeline: If `true`, calculations for interior elements that involve the
    ///     outermost timeline (such as absolute start timecode and occlusion) will be constrained
    ///     to this element's local timeline. If this element has no implicit local timeline, the
    ///     first nested container element's local timeline will be used.
    ///   - settings: Extraction settings.
    public func extractElements(
        constrainToLocalTimeline: Bool = true,
        settings: FinalCutPro.FCPXML.ExtractionSettings
    ) -> [FinalCutPro.FCPXML.ExtractedElement] {
        element.fcpExtractElements(
            constrainToLocalTimeline: constrainToLocalTimeline,
            settings: settings
        )
    }
    
    /// Extract elements using a preset.
    ///
    /// - Parameters:
    ///   - preset: Extraction preset.
    ///   - constrainToLocalTimeline: If `true`, calculations for interior elements that involve the
    ///     outermost timeline (such as absolute start timecode and occlusion) will be constrained
    ///     to this element's local timeline. If this element has no implicit local timeline, the
    ///     first nested container element's local timeline will be used.
    ///   - settings: Extraction settings.
    public func extractElements<Result>(
        preset: some FCPXMLExtractionPreset<Result>,
        constrainToLocalTimeline: Bool = true,
        settings: FinalCutPro.FCPXML.ExtractionSettings = .mainTimeline
    ) -> Result {
        element.fcpExtractElements(
            preset: preset,
            constrainToLocalTimeline: constrainToLocalTimeline,
            settings: settings
        )
    }
}

// MARK: - XMLElement Public Methods

extension XMLElement {
    /// Extract elements from the element and recursively from all sub-elements.
    ///
    /// - Parameters:
    ///   - constrainToLocalTimeline: If `true`, calculations for interior elements that involve the
    ///     outermost timeline (such as absolute start timecode and occlusion) will be constrained
    ///     to this element's local timeline. If this element has no implicit local timeline, the
    ///     first nested container element's local timeline will be used.
    ///   - settings: Extraction settings.
    public func fcpExtractElements(
        constrainToLocalTimeline: Bool = true,
        settings: FinalCutPro.FCPXML.ExtractionSettings
    ) -> [FinalCutPro.FCPXML.ExtractedElement] {
        _fcpExtractElements(
            constrainToLocalTimeline: constrainToLocalTimeline,
            settings: settings,
            ancestors: ancestorElements(includingSelf: false),
            resources: nil
        )
    }
    
    /// Extract elements using a preset.
    ///
    /// - Parameters:
    ///   - preset: Extraction preset.
    ///   - constrainToLocalTimeline: If `true`, calculations for interior elements that involve the
    ///     outermost timeline (such as absolute start timecode and occlusion) will be constrained
    ///     to this element's local timeline. If this element has no implicit local timeline, the
    ///     first nested container element's local timeline will be used.
    ///   - settings: Extraction settings.
    public func fcpExtractElements<Result>(
        preset: some FCPXMLExtractionPreset<Result>,
        constrainToLocalTimeline: Bool = true,
        settings: FinalCutPro.FCPXML.ExtractionSettings = .mainTimeline
    ) -> Result {
        preset.perform(
            on: self,
            constrainToLocalTimeline: constrainToLocalTimeline,
            baseSettings: settings
        )
    }
}

// MARK: - Extraction Logic

extension XMLElement {
    /// Internal extraction entry point:
    /// Recursively extract elements based on a set of matching criteria and filtering rules.
    ///
    /// - Parameters:
    ///   - constrainToLocalTimeline: If `true`, calculations for interior elements that involve the
    ///     outermost timeline (such as absolute start timecode and occlusion) will be constrained
    ///     to this element's local timeline. If this element has no implicit local timeline, the
    ///     first nested container element's local timeline will be used.
    ///   - settings: Extraction settings.
    ///   - ancestors: Ancestors, ordered nearest to furthest ancestor.
    ///   - resources: The document's `resources` container element.
    ///     If `nil`, the `resources` found in the document will be used if present.
    ///   - overrideDirectChildren: Uses the direct children rule supplied instead of the default
    ///     rule for the element type.
    func _fcpExtractElements<A: Sequence<XMLElement>>(
        constrainToLocalTimeline: Bool = true,
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestors: A,
        resources: XMLElement?,
        overrideDirectChildren: FinalCutPro.FCPXML.ExtractableChildren? = nil
    ) -> [FinalCutPro.FCPXML.ExtractedElement] {
        var ancestors: any Sequence<XMLElement> = ancestors
        
        if constrainToLocalTimeline {
            ancestors = []
        }
        
        return _fcpExtractElements(
            settings: settings,
            ancestors: ancestors,
            resources: resources
        )
    }
    
    /// Internal extraction recursion method:
    /// Recursively extract elements based on a set of matching criteria and filtering rules.
    ///
    /// - Parameters:
    ///   - settings: Extraction settings.
    ///   - ancestors: Ancestors, ordered nearest to furthest ancestor.
    ///   - resources: The document's `resources` container element.
    ///     If `nil`, the `resources` found in the document will be used if present.
    ///   - overrideDirectChildren: Uses the direct children rule supplied instead of the default
    ///     rule for the element type.
    private func _fcpExtractElements<A: Sequence<XMLElement>>(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestors: A,
        resources: XMLElement?,
        overrideDirectChildren: FinalCutPro.FCPXML.ExtractableChildren? = nil
    ) -> [FinalCutPro.FCPXML.ExtractedElement] {
        // self
        
        let selfExtractedElement = FinalCutPro.FCPXML.ExtractedElement(
            element: self,
            breadcrumbs: Array(ancestors),
            resources: resources
        )
        
        let keepForExtraction = Self._fcpShouldKeepForExtraction(
            extractedElement: selfExtractedElement,
            settings: settings,
            ancestors: ancestors
        )
        
        let keepForTraversal = Self._fcpShouldKeepForTraversal(
            extractedElement: selfExtractedElement,
            settings: settings,
            ancestors: ancestors
        )
        
        var extractedElements: [FinalCutPro.FCPXML.ExtractedElement] = []
        
        // occlusion - apply to both traversal and extraction
        let occlusion = _fcpEffectiveOcclusion(ancestors: ancestors)
        if !settings.occlusions.contains(occlusion) {
            return extractedElements
        }
        
        if keepForExtraction {
            extractedElements.append(contentsOf: [selfExtractedElement])
        }
        
        // gather immediate children with `lane != 0` which should be considered peers
        // with the current element
        
        let extractedPeers = _fcpExtractPeers(
            settings: settings,
            ancestors: ancestors,
            resources: resources
        )
        extractedElements.append(contentsOf: extractedPeers) // already filtered by predicate
        
        if !keepForTraversal {
            return extractedElements
        }
        
        // get recursing information
        
        guard let recurse = overrideDirectChildren
                ?? _fcpExtractableChildren(resources: resources, auditions: settings.auditions)
        else { return extractedElements }
        
        // direct children, if any
        if let childrenRule = recurse.children {
            let extractedChildren = _fcpExtractDirectChildren(
                childrenRule: childrenRule,
                settings: settings,
                ancestors: ancestors,
                resources: resources
            )
            extractedElements.append(contentsOf: extractedChildren) // already filtered by predicate
        }
        
        // explicit descendants that are not automatically recursive, if any
        
        if let descendants = recurse.descendants, !descendants.isEmpty {
            let extractedDescendants = _fcpExtractDescendants(
                descendants: descendants,
                settings: settings,
                ancestors: ancestors,
                resources: resources
            )
            extractedElements.append(contentsOf: extractedDescendants) // already filtered by predicate
        }
        
        return extractedElements
    }
    
    private func _fcpExtractPeers<A: Sequence<XMLElement>>(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestors: A,
        resources: XMLElement?
    ) -> some Sequence<FinalCutPro.FCPXML.ExtractedElement> {
        // gather immediate children with `lane != 0` which should be considered peers
        // with the current element
        
        let peers = childElements
            .filter { ($0.fcpLane ?? 0) != 0 }
        
        let extractedPeers = peers
            .flatMap {
                $0._fcpExtractElements(
                    settings: settings,
                    ancestors: [self] + ancestors,
                    resources: resources
                )
            }
        
        return extractedPeers
    }
    
    /// Helper to extract direct children of the element.
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    private func _fcpExtractDirectChildren<A: Sequence<XMLElement>>(
        childrenRule: FinalCutPro.FCPXML.ExtractableChildren.DirectChildren,
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestors: A,
        resources: XMLElement?
    ) -> [FinalCutPro.FCPXML.ExtractedElement] {
        let childrenSource: any Sequence<XMLElement>
        
        switch childrenRule {
        case .all:
            childrenSource = childElements
        case let .specific(childrenSequence):
            childrenSource = childrenSequence
        }
        
        let extractedChildren = childrenSource
        // filter out peers of parent, which we already handled in main extraction method
            .filter { ($0.fcpLane ?? 0) == 0 }
            .flatMap {
                $0._fcpExtractElements(
                    settings: settings,
                    ancestors: [self] + ancestors,
                    resources: resources
                )
            }
        return extractedChildren
    }
    
    /// Helper to extract further descendants of the element in special circumstances.
    ///
    /// - Note: This is not used for all descendants of any element, but for rare cases where a
    /// generational jump is required due to how elements are referenced. (`mc-clip` is one such example).
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    ///
    /// Descendants are ordered nearest to furthest descendant.
    private func _fcpExtractDescendants<A: Sequence<XMLElement>>(
        descendants: [FinalCutPro.FCPXML.ExtractableChildren.Descendant],
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestors: A,
        resources: XMLElement?
    ) -> [FinalCutPro.FCPXML.ExtractedElement] {
        // each descendant record has an element, as well as an optional sequence of children
        
        var descendantAccum: [XMLElement] = []
        var extracted: [FinalCutPro.FCPXML.ExtractedElement] = []
        
        // parse from nearest descendent to furthest, which is the same as
        // parsing ancestors from furthest to nearest
        for descendant in descendants {
            defer { descendantAccum.insert(descendant.element, at: 0) }
            
            let extractedDescendants = descendant.element._fcpExtractElements(
                settings: settings,
                ancestors: descendantAccum + [self] + ancestors,
                resources: resources,
                overrideDirectChildren: descendant.children
            )
            extracted.append(contentsOf: extractedDescendants)
        }
        
        return extracted
    }
    
    /// Returns `true` if the element should be filtered (kept) in returned elements.
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    static func _fcpShouldKeepForExtraction<S: Sequence<XMLElement>>(
        extractedElement: FinalCutPro.FCPXML.ExtractedElement,
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestors: S
    ) -> Bool {
        // we can apply inclusion-filter even if we don't know the element type
        if let filteredExtractionTypes = settings.filteredExtractionTypes {
            if let elementType = extractedElement.element.fcpElementType {
                if !filteredExtractionTypes.contains(elementType) {
                    return false
                }
            } else if !filteredExtractionTypes.isEmpty {
                // we have an element without a ElementType case, but the filter is non-nil
                // so we know it has to get filtered out
                return false
            }
                
        }
        
        // we can only exclude element types if has a type concretely known to us
        if let elementType = extractedElement.element.fcpElementType {
            if settings.excludedExtractionTypes.contains(elementType) {
                return false
            }
        }
        
        if let predicate = settings.extractionPredicate,
           !predicate(extractedElement)
        {
            return false
        }
        
        return true
    }
    
    /// Returns `true` if the element should be filtered (kept) and further traversed.
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    static func _fcpShouldKeepForTraversal<S: Sequence<XMLElement>>(
        extractedElement: FinalCutPro.FCPXML.ExtractedElement,
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestors: S
    ) -> Bool {
        // we can apply inclusion-filter even if we don't know the element type
        if let filteredTraversalTypes = settings.filteredTraversalTypes {
            if let elementType = extractedElement.element.fcpElementType {
                if !filteredTraversalTypes.contains(elementType) {
                    return false
                }
            } else if !filteredTraversalTypes.isEmpty {
                // we have an element without a ElementType case, but the filter is non-nil
                // so we know it has to get filtered out
                return false
            }
        }
        
        // we can only exclude element types if has a type concretely known to us
        if let elementType = extractedElement.element.fcpElementType {
            if settings.excludedTraversalTypes.contains(elementType) {
                return false
            }
        }
        
        if let predicate = settings.traversalPredicate,
           !predicate(extractedElement)
        {
            return false
        }
        
        return true
    }
}

// MARK: - Helpers

extension XMLElement {
    /// Return effective lane for the element.
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    func _fcpEffectiveLane<S: Sequence<XMLElement>>(ancestors: S) -> Int? {
        _fcpAncestorElementTypesAndLanes(ancestors: ancestors, includeSelf: true)
            .first(where: { $0.lane != nil })?
            .lane
    }
}

#endif
