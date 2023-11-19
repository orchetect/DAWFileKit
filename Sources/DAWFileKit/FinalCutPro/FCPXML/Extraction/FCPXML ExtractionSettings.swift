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
        // /// If `true`, perform a deep traversal recursively gathering child elements from all sub-elements.
        // /// If `false`, perform a shallow traversal of only the element's own child elements.
        // public var deep: Bool
        
        /// Filter to apply to Auditions.
        public var auditionMask: FinalCutPro.FCPXML.Audition.Mask
        
        /// Element types to exclude during extraction.
        public var excludeTypes: [FinalCutPro.FCPXML.ElementType]
        
        public init(
            // deep: Bool,
            excludeTypes: [FinalCutPro.FCPXML.ElementType] = [],
            auditionMask: FinalCutPro.FCPXML.Audition.Mask = .activeAudition
        ) {
            // self.deep = deep
            self.excludeTypes = excludeTypes
            self.auditionMask = auditionMask
        }
    }
}

#endif
