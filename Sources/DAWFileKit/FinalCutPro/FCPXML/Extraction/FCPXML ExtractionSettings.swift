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
        
        /// Element types to filter during extraction.
        /// Any other element types will be excluded.
        /// This rule is superseded by ``excludedTypes`` or ``excludedAncestorTypes`` in the event
        /// the
        /// same type is in both.
        ///
        /// - Note: If this set is non-nil and empty, no elements will be extracted.
        public var filteredTypes: Set<FinalCutPro.FCPXML.ElementType>?
        
        /// Element types to exclude during extraction.
        /// This rule supersedes ``filteredTypes`` in the event the same type is in both.
        public var excludedTypes: Set<FinalCutPro.FCPXML.ElementType>
        
        /// Exclude elements that have ancestors with these element types.
        /// This rule supersedes ``filteredTypes`` in the event the same type is in both.
        public var excludedAncestorTypes: Set<FinalCutPro.FCPXML.ElementType>
        
        public init(
            auditions: FinalCutPro.FCPXML.Audition.Mask = .active,
            filteredTypes: Set<FinalCutPro.FCPXML.ElementType>? = nil,
            excludedTypes: Set<FinalCutPro.FCPXML.ElementType> = [],
            excludedAncestorTypes: Set<FinalCutPro.FCPXML.ElementType> = []
        ) {
            self.filteredTypes = filteredTypes
            self.excludedTypes = excludedTypes
            self.excludedAncestorTypes = excludedAncestorTypes
            self.auditions = auditions
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
            filteredTypes: nil,
            excludedTypes: [],
            excludedAncestorTypes: []
        )
    }
    
    /// Extraction settings that constrain results to elements that are visible from the main
    /// timeline.
    public static let mainTimeline = FinalCutPro.FCPXML.ExtractionSettings(
        auditions: .active,
        filteredTypes: nil,
        excludedTypes: [],
        excludedAncestorTypes: [
            .story(.anyClip(.refClip)),
            .story(.anyClip(.syncClip)),
            .story(.anyClip(.mcClip))
        ]
    )
}

#endif
