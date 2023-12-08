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
        
        /// Explicit descendants and their children, if any.
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
        case let .story(storyElementType):
            switch storyElementType {
            case let .annotation(annotationType):
                switch annotationType {
                case .caption:
                    return .directChildren
                    
                case .keyword:
                    return nil
                    
                case .marker:
                    return nil
                }
                
            case let .clip(clipType):
                switch clipType {
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
                       let mediaResource = fcpResource(),
                       let multicam = mediaResource.fcpAsMedia?.multicam
                    {
                        let (audio, video) = multicam
                            .fcpAudioVideoMCAngles(forMulticamSources: multicamSources)
                        
                        // remove nils and reduce any duplicate elements
                        let reducedMCAngles = [video, audio] // video first, audio second
                            .compactMap { $0 }
                            .removingDuplicates()
                        
                        // provide explicit descendants
                        let descendants: [FinalCutPro.FCPXML.ExtractionChildren.Descendant] = [
                            // .init(element: mcSource, children: nil), - can omit, not really important
                            .init(element: mediaResource, children: nil),
                            .init(element: multicam, children: .specificChildren(reducedMCAngles))
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
                    
                case .refClip: // a.k.a. Compound Clip
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
                }
                
            case .sequence:
                // should only be a `spine` element, but return all children anyway
                return .directChildren
                
            case .spine:
                return .directChildren
            }
            
        case let .structure(structureElementType):
            switch structureElementType {
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
            }
            
        case .resources:
            return nil
            
        case let .resource(resourceElementType):
            switch resourceElementType {
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
            }
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

// MARK: - Public Methods

extension XMLElement {
    /// Extract elements from the element and recursively from all sub-elements.
    public func fcpExtractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings
    ) -> [FinalCutPro.FCPXML.ExtractedElement] {
        fcpExtractElements(settings: settings) { _ in true }
    }
    
    /// Extract elements from the element and recursively from all sub-elements.
    public func fcpExtractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        matching predicate: @escaping (_ element: FinalCutPro.FCPXML.ExtractedElement) -> Bool
    ) -> [FinalCutPro.FCPXML.ExtractedElement] {
        _fcpExtractElements(
            settings: settings,
            matching: predicate,
            ancestors: ancestorElements(includingSelf: false),
            resources: nil
        )
    }
    
    // TODO: finish this
    // /// Extract elements using a preset.
    // public func fcpExtractElements<Result>(
    //     preset: some FCPXMLExtractionPreset<Result>,
    //     settings: FinalCutPro.FCPXML.ExtractionSettings = .mainTimeline
    // ) -> Result {
    //     preset.perform(on: self, baseSettings: settings)
    // }
}

// MARK: - Recursive Extraction Logic

extension XMLElement {
    /// Recursively extract elements based on a set of matching criteria and filtering rules.
    ///
    /// - Parameters:
    ///   - settings: Extraction settings.
    ///   - matching: A closure which allows filtering an element based on custom logic.
    ///   - ancestors: Ancestors, ordered nearest to furthest ancestor.
    ///   - resources: The document's `resources` container element.
    ///     If `nil`, the `resources` found in the document will be used if present.
    ///   - overrideDirectChildren: Uses the direct children rule supplied instead of the default
    ///     rule for the element type.
    func _fcpExtractElements<A: Sequence<XMLElement>>(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        matching predicate: @escaping (_ element: FinalCutPro.FCPXML.ExtractedElement) -> Bool,
        ancestors: A,
        resources: XMLElement?,
        overrideDirectChildren: FinalCutPro.FCPXML.ExtractionChildren? = nil
    ) -> [FinalCutPro.FCPXML.ExtractedElement] {
        // self
        
        if !_fcpShouldKeepForExtraction(settings: settings, ancestors: ancestors) {
            return []
        }
        
        var result: [FinalCutPro.FCPXML.ExtractedElement] = []
        
        let selfEE = FinalCutPro.FCPXML.ExtractedElement(element: self, breadcrumbs: Array(ancestors), resources: resources)
        result.append(contentsOf: [selfEE].filter(predicate))
        
        // get recursing information
        
        guard let recurse = overrideDirectChildren ?? _fcpExtractableChildren(auditions: settings.auditions)
        else { return result }
        
        // direct children, if any
        
        if let childrenRule = recurse.children {
            let extractedChildren = _fcpExtractDirectChildren(
                childrenRule: childrenRule,
                settings: settings,
                matching: predicate,
                ancestors: ancestors,
                resources: resources
            )
            result.append(contentsOf: extractedChildren) // already filtered by predicate
        }
        
        // explicit descendants that are not automatically recursive, if any
        
        if let descendants = recurse.descendants, !descendants.isEmpty {
            let extractedDescendants = _fcpExtractDescendants(
                descendants: descendants,
                settings: settings,
                matching: predicate,
                ancestors: ancestors,
                resources: resources
            )
            result.append(contentsOf: extractedDescendants) // already filtered by predicate
        }
        
        return result
    }
    
    /// Helper
    private func _fcpExtractDirectChildren<A: Sequence<XMLElement>>(
        childrenRule: FinalCutPro.FCPXML.ExtractionChildren.DirectChildren,
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        matching predicate: @escaping (_ element: FinalCutPro.FCPXML.ExtractedElement) -> Bool,
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
                matching: predicate,
                ancestors: [self] + ancestors,
                resources: resources
            )
        }
        return extractedChildren.filter(predicate)
    }
    
    /// Helper
    private func _fcpExtractDescendants<A: Sequence<XMLElement>>(
        descendants: [FinalCutPro.FCPXML.ExtractionChildren.Descendant],
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        matching predicate: @escaping (_ element: FinalCutPro.FCPXML.ExtractedElement) -> Bool,
        ancestors: A,
        resources: XMLElement?
    ) -> [FinalCutPro.FCPXML.ExtractedElement] {
        // each descendant record has an element, as well as an optional sequence of children
        
        var descendantAccum: [XMLElement] = []
        var extracted: [FinalCutPro.FCPXML.ExtractedElement] = []
        
        for descendant in descendants {
            defer { descendantAccum.insert(descendant.element, at: 0) }
            
            let e = descendant.element._fcpExtractElements(
                settings: settings,
                matching: predicate,
                ancestors: descendantAccum + ancestors,
                resources: resources,
                overrideDirectChildren: descendant.children
            )
            extracted.append(contentsOf: e.filter(predicate))
        }
        
        return extracted
    }
    
    /// Returns `true` if the element should be filtered out of the returned elements.
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    func _fcpShouldKeepForExtraction<S: Sequence<XMLElement>>(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestors: S
    ) -> Bool {
        if let fcpElementType = fcpElementType {
            if let filteredTypes = settings.filteredTypes,
               !filteredTypes.contains(fcpElementType)
            {
                return false
            }
            
            if settings.excludedTypes.contains(fcpElementType)
            {
                return false
            }
        }
        
        if !settings.excludedAncestorTypes.isEmpty {
            for t in settings.excludedAncestorTypes {
                let lane = _fcpEffectiveLane(ancestors: ancestors)
                if _fcpHasAncestorExcludingParent(elementLane: lane, ofType: t, ancestors: ancestors) {
                    return false
                }
            }
        }
        
        let occlusion = _fcpEffectiveOcclusion(ancestors: ancestors)
        if !settings.occlusions.contains(occlusion) {
            return false
        }
        
        return true
    }
    
    /// Return effective lane for the element.
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    func _fcpEffectiveLane<S: Sequence<XMLElement>>(ancestors: S) -> Int? {
        _fcpAncestorElementTypesAndLanes(ancestors: ancestors, includingSelf: false)
            .reversed()
            .first(where: { $0.lane != nil })?
            .lane
    }
}

// MARK: - Helpers

extension XMLElement {
    /// Returns `true` if element has an ancestor with the specified element type, excluding its
    /// immediate parent.
    ///
    /// Ancestors are ordered nearest to furthest ancestor.
    func _fcpHasAncestorExcludingParent<S: Sequence<XMLElement>>(
        elementLane: Int?,
        ofType elementType: FinalCutPro.FCPXML.ElementType,
        ancestors: S
    ) -> Bool {
        let ancestorTypesOfClip = _fcpAncestorElementTypesAndLanes(
            ancestors: ancestors,
            includingSelf: false
        )
        .dropFirst() // remove ancestor the element is directly attached to
        
        return ancestorTypesOfClip
            .contains { type, lane in
                lane == elementLane && type == elementType
            }
    }
}

#endif
