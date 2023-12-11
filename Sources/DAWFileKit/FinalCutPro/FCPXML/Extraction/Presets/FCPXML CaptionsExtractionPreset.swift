//
//  FCPXML CaptionsExtractionPreset.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// FCPXML extraction preset that extracts closed captions, applying appropriate settings and
    /// filters to produce extraction results that will reflect what is shown on the Final Cut Pro
    /// timeline.
    public struct CaptionsExtractionPreset: FCPXMLExtractionPreset {
        public init() { }
        
        public func perform(
            on extractable: XMLElement,
            constrainToLocalTimeline: Bool,
            baseSettings settings: FinalCutPro.FCPXML.ExtractionSettings
        ) -> [FinalCutPro.FCPXML.ExtractedElement] {
            var settings = settings
            
            if settings.filteredExtractionTypes == nil {
                settings.filteredExtractionTypes = []
            }
            settings.filteredExtractionTypes?.insert(.caption)
            
            let extracted = extractable.fcpExtractElements(
                constrainToLocalTimeline: constrainToLocalTimeline,
                settings: settings
            )
            
            let captions = extracted
            
            return captions
        }
    }
}

extension FCPXMLExtractionPreset where Self == FinalCutPro.FCPXML.CaptionsExtractionPreset {
    /// FCPXML extraction preset that extracts closed captions, applying appropriate settings and
    /// filters to produce extraction results that will reflect what is shown on the Final Cut Pro
    /// timeline.
    public static var captions: FinalCutPro.FCPXML.CaptionsExtractionPreset {
        FinalCutPro.FCPXML.CaptionsExtractionPreset()
    }
}

#endif
