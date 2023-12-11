//
//  FCPXML ExtractionSettings.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Settings applied when extracting FCPXML elements.
    public struct ExtractionSettings {
        /// Filter to apply to Audition clip contents.
        public var auditions: FinalCutPro.FCPXML.Audition.Mask
        
        /// Occlusion conditions of elements to include.
        /// By default, all are included.
        public var occlusions: Set<FinalCutPro.FCPXML.ElementOcclusion>
        
        /// Element types to filter during traversal.
        /// This applies to elements that are walked and does not apply to elements that are
        /// extracted.
        ///
        /// - Note: If this set is non-nil and empty, no elements will be extracted.
        public var filteredTraversalTypes: Set<FinalCutPro.FCPXML.ElementType>?
        
        /// Extracted element types to filter during extraction.
        /// This applies to extracted (returned result) types and does not affect
        /// element traversal.
        ///
        /// - Note: If this set is non-nil and empty, no elements will be extracted.
        public var filteredExtractionTypes: Set<FinalCutPro.FCPXML.ElementType>?
        
        /// Element types to exclude during traversal.
        /// These types will be excluded from XML traversal and does not apply to elements that are
        /// extracted.
        /// This rule supersedes ``filteredTraversalTypes`` in the event the same type is in both.
        public var excludedTraversalTypes: Set<FinalCutPro.FCPXML.ElementType>
        
        /// Element types to exclude during extraction.
        /// This rule supersedes ``filteredExtractionTypes`` in the event the same type exists in
        /// both.
        public var excludedExtractionTypes: Set<FinalCutPro.FCPXML.ElementType>
        
        /// Predicate to apply to element traversal.
        /// This predicate is applied last after all other filters and exclusions.
        public var traversalPredicate: ((_ element: FinalCutPro.FCPXML.ExtractedElement) -> Bool)?
        
        /// Predicate to apply to element traversal.
        /// This predicate is applied last after all other filters and exclusions.
        public var extractionPredicate: ((_ element: FinalCutPro.FCPXML.ExtractedElement) -> Bool)?
        
        public init(
            auditions: FinalCutPro.FCPXML.Audition.Mask = .active,
            occlusions: Set<FinalCutPro.FCPXML.ElementOcclusion> = .allCases,
            filteredTraversalTypes: Set<FinalCutPro.FCPXML.ElementType>? = nil,
            filteredExtractionTypes: Set<FinalCutPro.FCPXML.ElementType>? = nil,
            excludedTraversalTypes: Set<FinalCutPro.FCPXML.ElementType> = [],
            excludedExtractionTypes: Set<FinalCutPro.FCPXML.ElementType> = [],
            traversalPredicate: ((_ element: FinalCutPro.FCPXML.ExtractedElement) -> Bool)? = nil,
            extractionPredicate: ((_ element: FinalCutPro.FCPXML.ExtractedElement) -> Bool)? = nil
        ) {
            self.auditions = auditions
            self.occlusions = occlusions
            self.filteredTraversalTypes = filteredTraversalTypes
            self.filteredExtractionTypes = filteredExtractionTypes
            self.excludedTraversalTypes = excludedTraversalTypes
            self.excludedExtractionTypes = excludedExtractionTypes
            self.traversalPredicate = traversalPredicate
            self.extractionPredicate = extractionPredicate
        }
    }
}

extension FinalCutPro.FCPXML.ExtractionSettings {
    /// Extraction settings that return deep results including internal timelines within clips,
    /// producing results that include elements visible from the main timeline and elements not
    /// visible from the main timeline.
    public static func deep(
        auditions: FinalCutPro.FCPXML.Audition.Mask = .active
    ) -> FinalCutPro.FCPXML.ExtractionSettings {
        FinalCutPro.FCPXML.ExtractionSettings(
            auditions: .active,
            occlusions: .allCases,
            filteredTraversalTypes: nil,
            filteredExtractionTypes: nil,
            excludedTraversalTypes: [],
            excludedExtractionTypes: [],
            traversalPredicate: nil,
            extractionPredicate: nil
        )
    }
    
    /// Extraction settings that constrain results to elements that are visible from the main
    /// timeline.
    public static let mainTimeline = FinalCutPro.FCPXML.ExtractionSettings(
        auditions: .active,
        occlusions: [.notOccluded, .partiallyOccluded],
        filteredTraversalTypes: nil,
        filteredExtractionTypes: nil,
        excludedTraversalTypes: [],
        excludedExtractionTypes: [],
        traversalPredicate: { element in
            let timelineCount = element.breadcrumbs
                .filter { $0.fcpElementType?.isTimeline == true }
                .filter { ($0.fcpLane ?? 0) == 0 }
                .count
            // print(e.element.name!, clipCount, e.breadcrumbs.map(\.name!))
            return timelineCount <= 2
        },
        extractionPredicate: { element in
            let timelineCount = element.breadcrumbs
                .filter { $0.fcpElementType?.isTimeline == true }
                .filter { ($0.fcpLane ?? 0) == 0 }
                .count
            // print(e.element.name!, clipCount, e.breadcrumbs.map(\.name!))
            return timelineCount <= 2
        }
    )
}

#endif
