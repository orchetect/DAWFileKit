//
//  FCPXML Extraction.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore
import TimecodeKit

extension FinalCutPro.FCPXML {
    struct ExtractionChildren {
        enum DirectChildren {
            /// All direct child elements of the element.
            case all
            
            /// Specific direct child elements of the element.
            case specific(_ specificChildren: any Swift.Sequence<XMLElement>)
        }
        
        var children: DirectChildren?
        
        /// Explicit descendants and their children, if any, in special circumstances.
        ///
        /// - Note: This is not used for all descendants of any element, but for rare cases where a
        /// generational jump is required due to how elements are referenced. (`mc-clip` is one such example).
        ///
        /// Descendants are ordered nearest to furthest descendant.
        var descendants: [Descendant]?
    }
}

extension FinalCutPro.FCPXML.ExtractionChildren {
    static let directChildren = Self(children: .all, descendants: nil)
    
    static func specificChildren(_ specificChildren: any Swift.Sequence<XMLElement>) -> Self {
        Self(children: .specific(specificChildren), descendants: nil)
    }
}

extension FinalCutPro.FCPXML.ExtractionChildren {
    struct Descendant {
        let element: XMLElement
        let children: FinalCutPro.FCPXML.ExtractionChildren?
    }
}

extension XMLElement { // parent/container
    /// Extractable children contained within the element.
    func _fcpExtractableChildren(
        auditions: FinalCutPro.FCPXML.Audition.Mask
    ) -> FinalCutPro.FCPXML.ExtractionChildren? {
        guard let fcpElementType = fcpElementType else { return nil }
        
        switch fcpElementType {
        // MARK: annotations
            
        case .caption:
            return .directChildren
            
        case .keyword:
            return nil
            
        case .marker:
            return nil
                
        // MARK: clips
            
        case .assetClip:
            return .directChildren
            
        case .audio:
            return .directChildren
            
        case .audition:
            switch auditions {
            case .active:
                return .specificChildren([fcpAsAudition?.activeClip].compactMap { $0 })
            case .activeAndAlternates:
                return .directChildren
            }
            
        case .clip:
            return .directChildren
            
        case .gap:
            return .directChildren
            
        case .liveDrawing:
            return .directChildren // TODO: ?
            
        case .mcClip: // a.k.a. Multicam Clip
                      // points to a `media` resource which will contain one `multicam`.
                      // an `mc-clip` can point to only one `media` resource, but
                      // the `mc-source` children in the `mc-clip` dictate what parts
                      // of the `multicam` are used.
            
            // we need to know which video angle and audio angle the `mc-clip`
            // is referencing. they may be different angles or the same angle.
            // then we extract from those angle's storylines, ignoring the
            // other angles that may be present in the `multicam`.
            // so we can't just return the `media` resource and recurse, we need
            // to actually know which angles are used by the `mc-clip`.
            
            if let multicamSources = fcpAsMCClip?.sources,
               let mediaResource = fcpResource()?.fcpAsMedia,
               let multicam = mediaResource.multicam
            {
                let (audio, video) = multicam
                    .audioVideoMCAngles(forMulticamSources: multicamSources)
                
                // remove nils and reduce any duplicate elements
                let reducedMCAngles = [video, audio] // video first, audio second
                    .compactMap(\.?.element)
                    .removingDuplicates()
                
                // provide explicit descendants
                let descendants: [FinalCutPro.FCPXML.ExtractionChildren.Descendant] = [
                    // .init(element: mcSource, children: nil), - can omit, not really important
                    .init(element: mediaResource.element, children: nil),
                    .init(element: multicam.element, children: .specificChildren(reducedMCAngles))
                ]
                
                let ec = FinalCutPro.FCPXML.ExtractionChildren(
                    children: .all,
                    descendants: descendants
                )
                return ec
            }
            else {
                return .directChildren
            }
            
        case .refClip:
            // a.k.a. Compound Clip
            // points to a `media` resource which will contain one `sequence`
            
            if let mediaResource = fcpResource() {
                let ec = FinalCutPro.FCPXML.ExtractionChildren(
                    children: .all,
                    descendants: [.init(element: mediaResource, children: nil)]
                )
                return ec
            } else {
                return .directChildren
            }
            
        case .syncClip:
            return .directChildren
            
        case .title:
            return .directChildren
            
        case .video:
            return .directChildren
            
        // MARK: sequence
            
        case .sequence:
            // should only be a `spine` element, but return all children anyway
            return .directChildren
            
        case .spine:
            return .directChildren
            
        // MARK: structure
            
        case .library:
            // can contain one or more `event`s and `smart-collection`s
            return .directChildren
            
        case .event:
            // can contain `project`s and `clips`
            // as well as collection folders, keyword collections, smart collections
            return .directChildren
            
        case .project:
            // contains a `sequence` element
            return .directChildren
            
        // MARK: resources
            
        case .resources:
            return nil
            
        case .asset:
            return nil
            
        case .effect:
            return nil
            
        case .format:
            return nil
            
        case .locator:
            return nil
            
        case .media:
            // used by `ref-clip` story element, media will contain a `sequence`
            // used by `mc-clip` story element, media will contain a `multicam`
            return .directChildren
            
        case .objectTracker:
            return nil
            
        default:
            return nil
        }
    }
}

// MARK: -

extension FinalCutPro.FCPXML {
    /// Extracted element and its context.
    public struct ExtractedElement {
        public var element: XMLElement
        public var breadcrumbs: [XMLElement]
        var resources: XMLElement?
        
        init(
            element: XMLElement,
            breadcrumbs: [XMLElement],
            resources: XMLElement?
        ) {
            self.element = element
            self.breadcrumbs = breadcrumbs
            self.resources = resources
        }
        
        public func value<Value>(forContext contextKey: ElementContext<Value>) -> Value {
            contextKey.value(from: element, breadcrumbs: breadcrumbs, resources: resources)
        }
    }
}

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

// MARK: - Recursive Extraction Logic

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
        overrideDirectChildren: FinalCutPro.FCPXML.ExtractionChildren? = nil
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
        overrideDirectChildren: FinalCutPro.FCPXML.ExtractionChildren? = nil
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
        
        if !keepForTraversal {
            return extractedElements
        }
        
        // get recursing information
        
        guard let recurse = overrideDirectChildren
              ?? _fcpExtractableChildren(auditions: settings.auditions)
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
    
    /// Helper to extract direct children of the element.
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    private func _fcpExtractDirectChildren<A: Sequence<XMLElement>>(
        childrenRule: FinalCutPro.FCPXML.ExtractionChildren.DirectChildren,
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
        
        let extractedChildren = childrenSource.flatMap {
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
        descendants: [FinalCutPro.FCPXML.ExtractionChildren.Descendant],
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestors: A,
        resources: XMLElement?
    ) -> [FinalCutPro.FCPXML.ExtractedElement] {
        // each descendant record has an element, as well as an optional sequence of children
        
        var descendantAccum: [XMLElement] = []
        var extracted: [FinalCutPro.FCPXML.ExtractedElement] = []
        
        for descendant in descendants {
            defer { descendantAccum.insert(descendant.element, at: 0) }
            
            let extractedDescendants = descendant.element._fcpExtractElements(
                settings: settings,
                ancestors: [self] + descendantAccum + ancestors,
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
        
        if !settings.excludedAncestorTypesOfParentForExtraction.isEmpty {
            let lane = extractedElement.element._fcpEffectiveLane(ancestors: ancestors)
            if extractedElement.element._fcpHasAncestorExcludingParent(
                elementLane: lane,
                ofTypes: settings.excludedAncestorTypesOfParentForExtraction,
                ancestors: ancestors
            ) {
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
    
    /// Returns `true` if element has an ancestor, excluding its immediate parent, with the any of
    /// specified element type(s).
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    func _fcpHasAncestorExcludingParent<S: Sequence<XMLElement>>(
        elementLane: Int?,
        ofTypes elementTypes: Set<FinalCutPro.FCPXML.ElementType>,
        ancestors: S
    ) -> Bool {
        let ancestorTypesOfClip = _fcpAncestorElementTypesAndLanes(
            ancestors: ancestors,
            includeSelf: false
        )
        .dropFirst() // remove ancestor the element is directly attached to
        
        // print(ancestorTypesOfClip.map(\.type).map(\.rawValue).joined(separator: " - "))
        
        for ancestor in ancestorTypesOfClip {
            guard ancestor.lane == elementLane else { return false }
            if elementTypes.contains(ancestor.type) { return true }
        }
        
        return false
    }
}

#endif
