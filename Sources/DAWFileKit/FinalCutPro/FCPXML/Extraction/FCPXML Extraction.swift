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
    enum ExtractionChildren {
        case immediateChildren
        case immediateChildrenAnd(children: [XMLElement], ofDescendants: [XMLElement])
    }
}

extension XMLElement { // parent/container
    /// Extractable children contained within the element.
    func _fcpExtractableChildren() -> FinalCutPro.FCPXML.ExtractionChildren? {
        guard let fcpElementType = fcpElementType else { return nil }
        
        switch fcpElementType {
        case let .story(storyElementType):
            switch storyElementType {
            case let .annotation(annotationType):
                switch annotationType {
                case .caption:
                    return .immediateChildren
                    
                case .keyword:
                    return nil
                    
                case .marker:
                    return nil
                }
                
            case let .clip(clipType):
                switch clipType {
                case .assetClip:
                    return .immediateChildren
                    
                case .audio:
                    return .immediateChildren
                    
                case .audition:
                    return .immediateChildren
                    
                case .clip:
                    return .immediateChildren
                    
                case .gap:
                    return .immediateChildren
                    
                case .liveDrawing:
                    return .immediateChildren // TODO: ?
                    
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
                    
                    let multicamSources = fcpAsMCClip.sources
                    
                    if
                        let mediaResource = fcpResource(),
                        let multicam = mediaResource.fcpAsMedia.multicam
                    {
                        let (audio, video) = multicam
                            .fcpAudioVideoMCAngles(forMulticamSources: multicamSources)
                        
                        // remove nils and reduce any duplicate elements
                        let reduced = [video, audio] // video first, audio second
                            .compactMap { $0 }
                            .removingDuplicates()
                        
                        let descendents = [mediaResource, multicam]
                        return .immediateChildrenAnd(children: reduced, ofDescendants: descendents)
                    }
                    else {
                        return .immediateChildren
                    }
                    
                case .refClip: // a.k.a. Compound Clip
                    // points to a `media` resource which will contain one `sequence`
                    if let mediaResource = fcpResource() {
                        return .immediateChildrenAnd(children: [mediaResource], ofDescendants: [])
                    } else {
                        return .immediateChildren
                    }
                    
                case .syncClip:
                    return .immediateChildren
                    
                case .title:
                    return .immediateChildren
                    
                case .video:
                    return .immediateChildren
                }
                
            case .sequence:
                // should only be a `spine` element, but return all children anyway
                return .immediateChildren
                
            case .spine:
                return .immediateChildren
            }
            
        case let .structure(structureElementType):
            switch structureElementType {
            case .library:
                // can contain one or more `event`s and `smart-collection`s
                return .immediateChildren
                
            case .event:
                // can contain `project`s and `clips`
                // as well as collection folders, keyword collections, smart collections
                return .immediateChildren
                
            case .project:
                // contains a `sequence` element
                return .immediateChildren
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
                return nil // TODO: ?
                
            case .media:
                // used by `ref-clip` story element, media will contain a `sequence`
                // used by `mc-clip` story element, media will contain a `multicam`
                return .immediateChildren
                
            case .objectTracker:
                return nil // TODO: ?
                
            case .trackingShape:
                return nil // TODO: ?
            }
        }
    }
}

// MARK: - Additional Methods

//extension XMLElement {
//    /// Extract elements from the element and recursively from all sub-elements.
//    /// - Note: Ancestors is ordered from closest ancestor to most distant.
//    public func fcpExtractElements(
//        settings: FinalCutPro.FCPXML.ExtractionSettings
//    ) -> [XMLElement] {
//        fcpExtractElements(settings: settings) { _ in true }
//    }
//}

// MARK: - Recursive Extraction Logic

//extension XMLElement {
//    public func fcpExtractElements(
//        settings: FinalCutPro.FCPXML.ExtractionSettings,
//        matching predicate: (_ element: XMLElement) -> Bool
//    ) -> [XMLElement] {
//        // apply filters from settings
//        if !filter(settings: settings) {
//            return []
//        }
//        
//        let selfElement = self
//        let ownElements = [selfElement] + extractableElements()
//        
//        let children = getExtractableChildren(settings: settings)
//        
//        let childElements = children.flatMap {
//            $0.extractElements(
//                settings: settings,
//                matching: predicate
//            )
//        }
//        
//        let matchingElements = (ownElements + childElements).filter(predicate)
//        
//        return matchingElements
//    }
//    
//    func filter(
//        settings: FinalCutPro.FCPXML.ExtractionSettings
//    ) -> Bool {
//        if let filteredTypes = settings.filteredTypes,
//           !filteredTypes.contains(elementType) 
//        {
//            return false
//        }
//        
//        if settings.excludedTypes.contains(elementType)
//        {
//            return false
//        }
//        
//        if !settings.excludedAncestorTypes.isEmpty {
//            for t in settings.excludedAncestorTypes {
//                let lane = effectiveLane()
//                if hasAncestorExcludingParent(elementLane: lane, ofType: t) {
//                    return false
//                }
//            }
//        }
//        
//        if let occlusion = context[.effectiveOcclusion],
//           !settings.occlusions.contains(occlusion)
//        {
//            return false
//        }
//        
//        return true
//    }
//    
//    func getExtractableChildren(
//        settings: FinalCutPro.FCPXML.ExtractionSettings
//    ) -> [FinalCutPro.FCPXML.AnyElement] {
//        if case let .story(.anyClip(.audition(auditionClip))) = self.asAnyElement() {
//            return auditionClip.extractableChildren(mask: settings.auditions)
//        } else {
//            return extractableChildren()
//        }
//    }
//    
//    func effectiveLane() -> Int? {
//        context[.ancestorElementTypes]?
//            .reversed()
//            .first(where: { $0.lane != nil })?
//            .lane
//    }
//}

// MARK: - Extraction Presets

//extension XMLElement {
//    /// Extract elements using a preset.
//    public func fcpExtractElements<Result>(
//        preset: some FCPXMLExtractionPreset<Result>,
//        settings: FinalCutPro.FCPXML.ExtractionSettings = .mainTimeline
//    ) -> Result {
//        preset.perform(on: self, baseSettings: settings)
//    }
//}

// MARK: - Helpers

//extension XMLElement {
//    /// Returns `true` if element has an ancestor with the specified element type, excluding its
//    /// immediate parent.
//    func _fcpHasAncestorExcludingParent(
//        elementLane: Int?,
//        ofType elementType: FinalCutPro.FCPXML.ElementType
//    ) -> Bool {
//        guard var ancestorTypesOfClip = context[.ancestorElementTypes] else {
//            return false
//        }
//        
//        // remove clip that the element is directly attached to
//        _ = ancestorTypesOfClip.popLast()
//        return ancestorTypesOfClip.contains { (lane: Int?, type: FinalCutPro.FCPXML.ElementType) in
//            lane == elementLane && type == elementType
//        }
//    }
//}

#endif
