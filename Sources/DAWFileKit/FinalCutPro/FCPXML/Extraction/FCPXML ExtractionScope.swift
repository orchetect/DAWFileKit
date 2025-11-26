//
//  FCPXML ExtractionScope.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore

extension FinalCutPro.FCPXML {
    /// Scope applied when extracting FCPXML elements.
    public struct ExtractionScope: Sendable {
        // MARK: - Public Properties
        
        /// Limit the top-level (main) timeline to the element that extraction is initiated upon.
        ///
        /// If `true`, calculations for interior elements that involve the outermost timeline (such
        /// as absolute start timecode and occlusion) will be constrained to the initiating
        /// element's local timeline. If the element has no implicit local timeline, the local
        /// timeline of the first nested container will be used.
        public var constrainToLocalTimeline: Bool
        
        /// The maximum number of internal containers to traverse.
        /// `nil` bypasses this rule.
        public var maxContainerDepth: Int?
        
        /// Filter to apply to Audition clip contents.
        public var auditions: FinalCutPro.FCPXML.Audition.AuditionMask
        
        /// Filter to apply to Multicam clip contents.
        public var mcClipAngles: FinalCutPro.FCPXML.MCClip.AngleMask
        
        /// Include disabled clips.
        public var includeDisabled: Bool
        
        /// Occlusion conditions of elements to include.
        /// By default, all are included.
        public var occlusions: Set<FinalCutPro.FCPXML.ElementOcclusion>
        
        /// Element types to filter during traversal.
        /// This applies to elements that are walked and does not apply to elements that are
        /// extracted.
        public var filteredTraversalTypes: Set<FinalCutPro.FCPXML.ElementType>
        
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
        public var traversalPredicate: (@Sendable (_ element: FinalCutPro.FCPXML.ExtractedElement) -> Bool)?
        
        /// Predicate to apply to element traversal.
        /// This predicate is applied last after all other filters and exclusions.
        public var extractionPredicate: (@Sendable (_ element: FinalCutPro.FCPXML.ExtractedElement) -> Bool)?
        
        // MARK: - Internal Properties
        
        /// Extracted element types to filter during extraction.
        /// This applies to extracted (returned result) types and does not affect
        /// element traversal.
        var filteredExtractionTypes: Set<FinalCutPro.FCPXML.ElementType> = []
        
        // MARK: - Init
        
        public init(
            constrainToLocalTimeline: Bool = false,
            maxContainerDepth: Int? = nil,
            auditions: FinalCutPro.FCPXML.Audition.AuditionMask = .active,
            mcClipAngles: FinalCutPro.FCPXML.MCClip.AngleMask = .active,
            includeDisabled: Bool = true,
            occlusions: Set<FinalCutPro.FCPXML.ElementOcclusion> = .allCases,
            filteredTraversalTypes: Set<FinalCutPro.FCPXML.ElementType> = [],
            excludedTraversalTypes: Set<FinalCutPro.FCPXML.ElementType> = [],
            excludedExtractionTypes: Set<FinalCutPro.FCPXML.ElementType> = [],
            traversalPredicate: (@Sendable (_ element: FinalCutPro.FCPXML.ExtractedElement) -> Bool)? = nil,
            extractionPredicate: (@Sendable (_ element: FinalCutPro.FCPXML.ExtractedElement) -> Bool)? = nil
        ) {
            self.constrainToLocalTimeline = constrainToLocalTimeline
            self.maxContainerDepth = maxContainerDepth
            self.auditions = auditions
            self.mcClipAngles = mcClipAngles
            self.includeDisabled = includeDisabled
            self.occlusions = occlusions
            self.filteredTraversalTypes = filteredTraversalTypes
            self.excludedTraversalTypes = excludedTraversalTypes
            self.excludedExtractionTypes = excludedExtractionTypes
            self.traversalPredicate = traversalPredicate
            self.extractionPredicate = extractionPredicate
        }
    }
}

extension FinalCutPro.FCPXML.ExtractionScope {
    /// Extraction settings that return deep results including internal timelines within clips,
    /// producing results that include elements visible from the main timeline and elements not
    /// visible from the main timeline.
    public static func deep(
        auditions: FinalCutPro.FCPXML.Audition.AuditionMask = .all,
        mcClipAngles: FinalCutPro.FCPXML.MCClip.AngleMask = .all
    ) -> FinalCutPro.FCPXML.ExtractionScope {
        FinalCutPro.FCPXML.ExtractionScope(
            constrainToLocalTimeline: false,
            maxContainerDepth: nil,
            auditions: auditions,
            mcClipAngles: mcClipAngles,
            includeDisabled: true,
            occlusions: .allCases,
            filteredTraversalTypes: [],
            excludedTraversalTypes: [],
            excludedExtractionTypes: [],
            traversalPredicate: nil,
            extractionPredicate: nil
        )
    }
    
    /// Extraction settings that constrain results to elements that are visible from the main
    /// timeline.
    public static let mainTimeline = FinalCutPro.FCPXML.ExtractionScope(
        constrainToLocalTimeline: false,
        maxContainerDepth: 2,
        auditions: .active,
        mcClipAngles: .active,
        includeDisabled: false,
        occlusions: [.notOccluded, .partiallyOccluded],
        filteredTraversalTypes: [],
        excludedTraversalTypes: [],
        excludedExtractionTypes: [],
        traversalPredicate: nil,
        extractionPredicate: nil
    )
}

#endif
