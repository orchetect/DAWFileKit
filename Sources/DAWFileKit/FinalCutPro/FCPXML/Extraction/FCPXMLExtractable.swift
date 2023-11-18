//
//  FCPXMLExtractable.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

/// A FCPXML element that is capable of extracting its own contents as well as the contents of its
/// children, if any.
public protocol FCPXMLExtractable { // parent/container
    /// Extractable elements contained immediately within the element. Do not include children.
    func extractableElements() -> [FinalCutPro.FCPXML.AnyElement]
    
    /// Extract elements from the element and optionally recursively from all sub-elements.
    /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
    func extractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyElement],
        matching predicate: (_ element: FinalCutPro.FCPXML.AnyElement) -> Bool
    ) -> [FinalCutPro.FCPXML.AnyElement]
}

// MARK: - Extraction Logic

extension FCPXMLExtractable where Self: FCPXMLElement {
    func extractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyElement],
        contents: [FinalCutPro.FCPXML.AnyElement],
        matching predicate: (FinalCutPro.FCPXML.AnyElement) -> Bool
    ) -> [FinalCutPro.FCPXML.AnyElement] {
        let isFiltered = settings.excludeTypes.contains(elementType)
        guard !isFiltered else { return [] }
        
        let ownElements = [self.asAnyElement()] + extractableElements()
        
        let childAncestors = ancestorsOfParent + [self.asAnyElement()]
        
        let childElements = contents.flatMap {
            $0.extractableElements()
                + $0.extractElements(
                    settings: settings,
                    ancestorsOfParent: childAncestors,
                    matching: predicate
                )
        }
        
        let matchingElements = (ownElements + childElements).filter(predicate)
        
        return matchingElements
    }
}

// MARK: - Specialized Extraction

extension FCPXMLExtractable {
    /// Extract all nested markers.
    public func extractMarkers(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyElement] = []
    ) -> [FinalCutPro.FCPXML.Marker] {
        let extracted = extractElements(
            settings: settings,
            ancestorsOfParent: ancestorsOfParent) { element in
                element.elementType == .story(.anyAnnotation(.marker)) ||
                element.elementType == .story(.anyAnnotation(.chapterMarker))
            }
        let markers = extracted.storyElements().annotations().markers()
        return markers
    }
    
    /// Extract all nested captions.
    public func extractCaptions(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyElement] = []
    ) -> [FinalCutPro.FCPXML.Caption] {
        let extracted = extractElements(
            settings: settings,
            ancestorsOfParent: ancestorsOfParent) { element in
                element.elementType == .story(.anyAnnotation(.caption))
            }
        let captions = extracted.storyElements().annotations().captions()
        return captions
    }
}

#endif
