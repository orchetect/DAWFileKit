//
//  FCPXML Extraction.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore
import TimecodeKit

extension XMLElement {
    /// Extract the element with timeline context.
    /// This provides additional computed information such as absolute start timecode, occlusion,
    /// and more.
    ///
    /// > Note:
    /// > This can only contain as much context as is available in its XML scope.
    /// > Which means calling this on an element within a resource (media, multicam, etc.) will only
    /// > be able to provide context for the resource's scope and is not able to reach outside
    /// > to any parent timelines above it.
    /// >
    /// > If full context is required, do not use this method, but use
    /// > ``fcpExtractElements(constrainToLocalTimeline:settings:)`` instead.
    public func fcpExtract(
        constrainToLocalTimeline: Bool = false
    ) -> FinalCutPro.FCPXML.ExtractedElement {
        let settings = FinalCutPro.FCPXML.ExtractionSettings(
            auditions: .active,
            occlusions: .allCases,
            filteredTraversalTypes: nil,
            filteredExtractionTypes: nil,
            excludedTraversalTypes: [],
            excludedExtractionTypes: [],
            excludedAncestorTypesOfParentForExtraction: [],
            traversalPredicate: { _ in false },
            extractionPredicate: nil
        )
        
        guard let extractedElement = fcpExtractElements(
            constrainToLocalTimeline: constrainToLocalTimeline,
            settings: settings
        )
        .first
        else {
            assertionFailure("Element extraction did not return self.")
            return FinalCutPro.FCPXML.ExtractedElement(
                element: self,
                breadcrumbs: Array(ancestorElements(includingSelf: false)),
                resources: nil
            )
        }
        
        return extractedElement
    }
}

#endif
