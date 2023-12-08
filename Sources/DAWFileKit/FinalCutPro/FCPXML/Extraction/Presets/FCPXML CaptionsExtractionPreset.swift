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
            baseSettings settings: FinalCutPro.FCPXML.ExtractionSettings
        ) -> [FinalCutPro.FCPXML.ExtractedElement] {
            let extracted = extractable.fcpExtractElements(
                settings: settings
            ) { element in
                element.element.fcpElementType == .story(.annotation(.caption))
            }
            
            let captions = extracted.filter {
                $0.element.fcpElementType == .story(.annotation(.caption))
            }
            
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