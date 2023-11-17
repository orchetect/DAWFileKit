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
        public var excludeTypes: [FinalCutPro.FCPXML.StoryElementType]
        
        // internal
        var ancestorEventName: String?
        var ancestorProjectName: String?
        
        public init(
            // deep: Bool,
            excludeTypes: [FinalCutPro.FCPXML.StoryElementType] = [],
            auditionMask: FinalCutPro.FCPXML.Audition.Mask = .activeAudition
        ) {
            // self.deep = deep
            self.excludeTypes = excludeTypes
            self.auditionMask = auditionMask
        }
        
        @_disfavoredOverload
        init(
            // deep: Bool,
            excludeTypes: [FinalCutPro.FCPXML.StoryElementType] = [],
            auditionMask: FinalCutPro.FCPXML.Audition.Mask = .activeAudition,
            ancestorEventName: String? = nil,
            ancestorProjectName: String? = nil
        ) {
            // self.deep = deep
            self.excludeTypes = excludeTypes
            self.auditionMask = auditionMask
            self.ancestorEventName = ancestorEventName
            self.ancestorProjectName = ancestorProjectName
        }
    }
}

extension FinalCutPro.FCPXML.ExtractionSettings {
    func updating(ancestorEventName: String? = nil, ancestorProjectName: String? = nil) -> Self {
        var copy = self
        if let ancestorEventName = ancestorEventName {
            copy.ancestorEventName = ancestorEventName
        }
        if let ancestorProjectName = ancestorProjectName {
            copy.ancestorProjectName = ancestorProjectName
        }
        return copy
    }
}

#endif
