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
    /// > ``fcpExtractElements(scope:)`` instead.
    ///
    /// - Parameters:
    ///   - constrainToLocalTimeline: If `true`, calculations for interior elements that involve the
    ///   outermost timeline (such as absolute start timecode and occlusion) will be constrained to
    ///   the initiating element's local timeline. If the element has no implicit local timeline,
    ///   the local timeline of the first nested container will be used.
    public func fcpExtract(
        constrainToLocalTimeline: Bool = false
    ) async -> FinalCutPro.FCPXML.ExtractedElement {
        let scope = FinalCutPro.FCPXML.ExtractionScope(
            constrainToLocalTimeline: constrainToLocalTimeline,
            maxContainerDepth: nil,
            auditions: .active,
            mcClipAngles: .active,
            occlusions: .allCases,
            filteredTraversalTypes: [],
            excludedTraversalTypes: [],
            excludedExtractionTypes: [],
            traversalPredicate: { _ in false },
            extractionPredicate: nil
        )
        
        guard let elementType = fcpElementType,
              let extractedElement = await fcpExtractElements(
                  types: [elementType],
                  scope: scope
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
