//
//  FCPXML MarkersExtractionPreset.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// FCPXML extraction preset that extracts markers, applying appropriate settings and filters to
    /// produce extraction results that will reflect what is shown on the Final Cut Pro timeline.
    public struct MarkersExtractionPreset: FCPXMLExtractionPreset {
        public init() { }
        
        public func perform<E: FCPXMLExtractable & FCPXMLElement>(
            on extractable: E,
            baseSettings settings: FinalCutPro.FCPXML.ExtractionSettings
        ) -> [FinalCutPro.FCPXML.Marker] {
            let extracted = extractable.extractElements(
                settings: settings
            ) {
                $0.elementType == .story(.anyAnnotation(.marker)) ||
                    $0.elementType == .story(.anyAnnotation(.chapterMarker))
            }
            
            let markers = extracted.storyElements().annotations().markers()
            
            return markers
        }
    }
}

extension FCPXMLExtractionPreset where Self == FinalCutPro.FCPXML.MarkersExtractionPreset {
    /// FCPXML extraction preset that extracts markers, applying appropriate settings and filters to
    /// produce extraction results that will reflect what is shown on the Final Cut Pro timeline.
    public static var markers: FinalCutPro.FCPXML.MarkersExtractionPreset {
        FinalCutPro.FCPXML.MarkersExtractionPreset()
    }
}

#endif
