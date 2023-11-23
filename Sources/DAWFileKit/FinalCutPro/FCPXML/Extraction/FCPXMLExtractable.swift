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
    
    /// Extractable children contained one level under the element.
    func extractableChildren() -> [FinalCutPro.FCPXML.AnyElement]
}

// MARK: - Additional Methods

extension FCPXMLExtractable where Self: FCPXMLElement {
    /// Extract elements from the element and recursively from all sub-elements.
    /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
    public func extractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings
    ) -> [FinalCutPro.FCPXML.AnyElement] {
        extractElements(settings: settings) { _ in true }
    }
}

// MARK: - Recursive Extraction Logic

extension FCPXMLExtractable where Self: FCPXMLElement {
    public func extractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        matching predicate: (FinalCutPro.FCPXML.AnyElement) -> Bool
    ) -> [FinalCutPro.FCPXML.AnyElement] {
        // apply filters from settings
        if !filter(settings: settings) {
            return []
        }
        
        let selfElement = self.asAnyElement()
        let ownElements = [selfElement] + extractableElements()
        
        let children = getExtractableChildren(settings: settings)
        
        let childElements = children.flatMap {
            $0.extractElements(
                settings: settings,
                matching: predicate
            )
        }
        
        let matchingElements = (ownElements + childElements).filter(predicate)
        
        return matchingElements
    }
    
    func filter(
        settings: FinalCutPro.FCPXML.ExtractionSettings
    ) -> Bool {
        if let filteredTypes = settings.filteredTypes,
           !filteredTypes.contains(elementType) 
        {
            return false
        }
        
        if settings.excludedTypes.contains(elementType)
        {
            return false
        }
        
        // TODO: this needs unit testing
        if !settings.excludedAncestorTypes.isEmpty {
            for t in settings.excludedAncestorTypes {
                if hasAncestorExcludingParent(ofType: t) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func getExtractableChildren(
        settings: FinalCutPro.FCPXML.ExtractionSettings
    ) -> [FinalCutPro.FCPXML.AnyElement] {
        if case let .story(.anyClip(.audition(auditionClip))) = self.asAnyElement() {
            return auditionClip.extractableChildren(mask: settings.auditions)
        } else {
            return extractableChildren()
        }
    }
}

// MARK: - Extraction Presets

extension FCPXMLExtractable where Self: FCPXMLElement {
    /// Extract elements using a preset.
    public func extractElements<Result>(
        preset: some FCPXMLExtractionPreset<Result>,
        settings: FinalCutPro.FCPXML.ExtractionSettings = .mainTimeline
    ) -> Result {
        preset.perform(on: self, baseSettings: settings)
    }
}

// MARK: - Helpers

extension FinalCutPro.FCPXML.AnyElement {
    /// Returns `true` if element has an ancestor with the specified element type, excluding its
    /// immediate parent.
    func hasAncestorExcludingParent(
        ofType elementType: FinalCutPro.FCPXML.ElementType
    ) -> Bool {
        guard var ancestorTypesOfClip = context[.ancestorElementTypes] else {
            return false
        }
        
        // remove clip that the element is directly attached to
        _ = ancestorTypesOfClip.popLast()
        return ancestorTypesOfClip.contains(elementType)
    }
}

extension FCPXMLElement {
    /// Returns `true` if element has an ancestor with the specified element type, excluding its
    /// immediate parent.
    func hasAncestorExcludingParent(
        ofType elementType: FinalCutPro.FCPXML.ElementType
    ) -> Bool {
        self.asAnyElement()
            .hasAncestorExcludingParent(ofType: elementType)
    }
}

#endif
