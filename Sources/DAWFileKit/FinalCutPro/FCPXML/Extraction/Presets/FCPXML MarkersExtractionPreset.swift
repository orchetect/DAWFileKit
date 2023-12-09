//
//  FCPXML MarkersExtractionPreset.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// FCPXML extraction preset that extracts markers, applying appropriate settings and filters to
    /// produce extraction results that will reflect what is shown on the Final Cut Pro timeline.
    public struct MarkersExtractionPreset: FCPXMLExtractionPreset {
        public init() { }
        
        public func perform(
            on extractable: XMLElement,
            baseSettings settings: FinalCutPro.FCPXML.ExtractionSettings
        ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
            var settings = settings
            
            if settings.filteredExtractionTypes == nil {
                settings.filteredExtractionTypes = []
            }
            settings.filteredExtractionTypes?.insert(.story(.annotation(.marker(.marker))))
            settings.filteredExtractionTypes?.insert(.story(.annotation(.marker(.chapterMarker))))
            
//            let elementTypes: [ElementType] = [
//                .story(.annotation(.marker(.marker))),
//                .story(.annotation(.marker(.chapterMarker)))
//            ]
            
            let extracted = extractable.fcpExtractElements(
                settings: settings
            ) /*{ element in
                guard let elementType = element.element.fcpElementType
                else { return false }
                return elementTypes.contains(elementType)
            }*/
            
            let markers = extracted
                // .filter { element in
                //     guard let elementType = element.element.fcpElementType
                //     else { return false }
                //     return elementTypes.contains(elementType)
                // }
                .compactMap { ExtractedMarker($0) }
            
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

extension FinalCutPro.FCPXML {
    /// An extracted marker element with pertinent data.
    public struct ExtractedMarker {
        var extractedElement: ExtractedElement
        
        init?(_ extractedElement: ExtractedElement) {
            self.extractedElement = extractedElement
        }
        
        // Generic getters
        
        /// Returns the marker XML element wrapped in a model struct.
        public var marker: Marker {
            // this guard only necessary because `fcpAsMarker` returns an Optional
            guard let markerModel = extractedElement.element.fcpAsMarker else {
                assertionFailure("Could not form marker model struct.")
                return Marker()
            }
            return markerModel
        }
        
        public func value<Value>(forContext: ElementContext<Value>) -> Value {
            extractedElement.value(forContext: forContext)
        }
        
        // Convenience getters
        
        /// Marker name.
        public var name: String {
            marker.name
        }
        
        /// Marker note, if any.
        public var note: String? {
            marker.note
        }
        
        /// Absolute timecode position within the outermost timeline.
        public var timecode: Timecode? {
            guard let absFraction = extractedElement.value(forContext: .absoluteStart),
                  let tc = try? extractedElement.element._fcpTimecode(
                    fromRational: absFraction,
                    resources: extractedElement.resources
                  )
            else { return nil }
            return tc
        }
        
        /// Duration expressed as a length of timecode.
        public var duration: Timecode? {
            guard let duration = marker.duration,
                  let tc = try? extractedElement.element._fcpTimecode(
                    fromRational: duration,
                    resources: extractedElement.resources
                  )
            else { return nil }
            return tc
        }
        
        /// Inherited roles of the marker from its container(s).
        public var roles: [AnyInterpolatedRole] {
            extractedElement.value(forContext: .inheritedRoles)
        }
    }
}

extension Sequence<FinalCutPro.FCPXML.ExtractedMarker> {
    /// Sort collection by marker timecode.
    public func sorted() -> [FinalCutPro.FCPXML.ExtractedMarker] {
        sorted { lhs, rhs in
            guard let lhsTimecode = lhs.timecode,
                  let rhsTimecode = rhs.timecode
            else {
                // sort by `start` attribute as fallback
                return lhs.marker.start < rhs.marker.start
            }
            return lhsTimecode < rhsTimecode
        }
    }
    
    /// Sort collection by marker name.
    public func sortedByName() -> [FinalCutPro.FCPXML.ExtractedMarker] {
        sorted { lhs, rhs in
            lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }
}

#endif
