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
    
    // internal
    var ancestorEventName: String?
    var ancestorProjectName: String?
    
    public init(
        // deep: Bool,
        excludeTypes: [FinalCutPro.FCPXML.ClipType] = [],
        auditionMask: FinalCutPro.FCPXML.Audition.Mask = .activeAudition
    ) {
        // self.deep = deep
        self.excludeTypes = excludeTypes
        self.auditionMask = auditionMask
    }
    
    @_disfavoredOverload
    init(
        // deep: Bool,
        excludeTypes: [FinalCutPro.FCPXML.ClipType] = [],
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

extension FCPXMLMarkersExtractionSettings {
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

extension FinalCutPro.FCPXML {
    /// Contains an extracted marker along with pertinent contextual metadata.
    public struct ExtractedMarker {
        public var marker: Marker
        
        public var absoluteStart: Timecode?
        
        /// Contains an event name if the marker is a descendent of an event.
        public var ancestorEventName: String?
        
        /// Contains a project name if the marker is a descendent of a project.
        public var ancestorProjectName: String?
        
        // TODO: abstract into a generic protocol that can describe any clip's details? we don't want to just store the clip itself though.
        
        /// The parent clip's type.
        public var parentType: ClipType
        
        /// The parent clip's name.
        public var parentName: String?
        
        /// The parent clip's absolute start time.
        public var parentAbsoluteStart: Timecode?
        
        /// The parent clip's duration.
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
            
            ancestorEventName = settings.ancestorEventName
            ancestorProjectName = settings.ancestorProjectName
            
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
