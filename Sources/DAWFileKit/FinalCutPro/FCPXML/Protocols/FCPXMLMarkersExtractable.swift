//
//  FCPXMLMarkersExtractable.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
@_implementationOnly import OTCore

public protocol FCPXMLMarkersExtractable {
    var markers: [FinalCutPro.FCPXML.Marker] { get }
    
    /// Extract markers from the element and optionally recursively from all sub-elements.
    func extractMarkers(
        settings: FCPXMLMarkersExtractionSettings
    ) -> [FinalCutPro.FCPXML.ExtractedMarker]
}

extension FCPXMLMarkersExtractable { }

public struct FCPXMLMarkersExtractionSettings {
    // /// If `true`, perform a deep traversal recursively gathering markers from all sub-elements.
    // /// If `false`, perform a shallow traversal of only the element's own markers.
    // public var deep: Bool
    
    /// Filter to apply to Auditions.
    public var auditionMask: FinalCutPro.FCPXML.Audition.Mask
    
    /// Clip types to exclude during extraction.
    public var excludeTypes: [FinalCutPro.FCPXML.ClipType]
    
    public init(
        // deep: Bool,
        excludeTypes: [FinalCutPro.FCPXML.ClipType] = [],
        auditionMask: FinalCutPro.FCPXML.Audition.Mask = .activeAudition
    ) {
        // self.deep = deep
        self.excludeTypes = excludeTypes
        self.auditionMask = auditionMask
    }
}

extension FinalCutPro.FCPXML {
    /// Contains an extracted marker along with pertinent contextual metadata.
    public struct ExtractedMarker {
        public var marker: Marker
        
        public var absoluteStart: Timecode?
        
        // TODO: abstract into a generic protocol that can describe any clip's details? we don't want to just store the clip itself though.
        public var parentType: ClipType
        public var parentName: String?
        public var parentAbsoluteStart: Timecode?
        public var parentDuration: Timecode?
        
        init(
            marker: Marker,
            settings: FCPXMLMarkersExtractionSettings,
            parent: AnyClip
        ) {
            self.marker = marker
            
            if let parentOffset = parent.offset,
               let parentAbsoluteStart = parent.start
            {
                let offsetFromParentStart = marker.start - parentAbsoluteStart
                if let newTimecode = try? parentOffset.adding(offsetFromParentStart, by: .wrapping) {
                    absoluteStart = newTimecode
                } else {
                    print("Error offsetting timecode for marker \(marker.name.quoted).")
                }
            }
            
            parentType = parent.clipType
            parentName = parent.name
            parentAbsoluteStart = parent.offset
            parentDuration = parent.duration
        }
    }
}

extension Collection<FinalCutPro.FCPXML.Marker> {
    func convertToExtractedMarkers(
        settings: FCPXMLMarkersExtractionSettings,
        parent: FinalCutPro.FCPXML.AnyClip
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        compactMap {
            guard !settings.excludeTypes.contains(parent.clipType) else { return nil }
            
            return FinalCutPro.FCPXML.ExtractedMarker(
                marker: $0,
                settings: settings,
                parent: parent
            )
        }
    }
}

#endif
