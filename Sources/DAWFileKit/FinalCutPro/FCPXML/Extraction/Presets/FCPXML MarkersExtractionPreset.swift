//
//  FCPXML MarkersExtractionPreset.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// FCPXML extraction preset that extracts markers,.
    public struct MarkersExtractionPreset: FCPXMLExtractionPreset {
        public init() { }
        
        public func perform(
            on extractable: XMLElement,
            scope: FinalCutPro.FCPXML.ExtractionScope
        ) async -> [FinalCutPro.FCPXML.ExtractedMarker] {
            let extracted = await extractable.fcpExtractElements(
                types: [.marker, .chapterMarker],
                scope: scope
            )
            
            let wrapped = extracted
                .compactMap { ExtractedMarker($0) }
            
            return wrapped
        }
    }
}

extension FCPXMLExtractionPreset where Self == FinalCutPro.FCPXML.MarkersExtractionPreset {
    /// FCPXML extraction preset that extracts markers.
    public static var markers: FinalCutPro.FCPXML.MarkersExtractionPreset {
        FinalCutPro.FCPXML.MarkersExtractionPreset()
    }
}

extension FinalCutPro.FCPXML {
    /// An extracted marker element with pertinent data.
    public struct ExtractedMarker: FCPXMLExtractedModelElement {
        public typealias Model = Marker
        public let element: XMLElement
        public let breadcrumbs: [XMLElement]
        public let resources: XMLElement?
        
        init?(_ extractedElement: ExtractedElement) {
            element = extractedElement.element
            breadcrumbs = extractedElement.breadcrumbs
            resources = extractedElement.resources
        }
        
        /// Return the a context value for the element.
        public func value<Value>(
            forContext contextKey: FinalCutPro.FCPXML.ElementContext<Value>
        ) -> Value {
            contextKey.value(from: element, breadcrumbs: breadcrumbs, resources: resources)
        }
        
        // Convenience getters
        
        /// Marker name.
        public var name: String {
            model.name
        }
        
        /// Marker note, if any.
        public var note: String? {
            model.note
        }
        
        /// Marker configuration.
        public var configuration: FinalCutPro.FCPXML.Marker.MarkerConfiguration {
            model.configuration
        }
        
        /// Inherited roles from container(s).
        public var roles: [AnyInterpolatedRole] {
            value(forContext: .inheritedRoles)
        }
    }
}

#endif
