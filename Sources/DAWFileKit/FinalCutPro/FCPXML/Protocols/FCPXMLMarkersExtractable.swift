//
//  FCPXMLMarkersExtractable.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
@_implementationOnly import OTCore

public protocol FCPXMLMarkersExtractable: FCPXMLExtractable {
    var markers: [FinalCutPro.FCPXML.Marker] { get }
    
    /// Extract markers from the element and optionally recursively from all sub-elements.
    /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
    func extractMarkers(
        settings: FCPXMLExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> [FinalCutPro.FCPXML.ExtractedMarker]
}

extension FinalCutPro.FCPXML {
    public struct ExtractedMarker {
        public var marker: Marker
        public var context: ElementContext
    }
}

// MARK: - Extraction Logic

extension FCPXMLMarkersExtractable where Self: FCPXMLStoryElement {
    public func extractMarkers(
        settings: FCPXMLExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement],
        children: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        let ownMarkers = markers.convertToExtractedMarkers(
            settings: settings,
            parent: self.asAnyStoryElement(),
            ancestorsOfParent: ancestorsOfParent
        )
        
        let childAncestors = ancestorsOfParent + [self.asAnyStoryElement()]
        
        let clipsMarkers = children.flatMap {
            $0.extractMarkers(settings: settings, ancestorsOfParent: childAncestors)
        }
        
        return ownMarkers + clipsMarkers
    }
}

extension Collection<FinalCutPro.FCPXML.Marker> {
    func convertToExtractedMarkers(
        settings: FCPXMLExtractionSettings,
        parent: FinalCutPro.FCPXML.AnyStoryElement,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        compactMap {
            guard !settings.excludeTypes.contains(parent.storyElementType) else { return nil }
            
            let context = FinalCutPro.FCPXML.ElementContext(
                element: $0,
                settings: settings,
                parent: parent,
                ancestorsOfParent: ancestorsOfParent
            )
            
            return FinalCutPro.FCPXML.ExtractedMarker(
                marker: $0,
                context: context
            )
        }
    }
}

#endif
