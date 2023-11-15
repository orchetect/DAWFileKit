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
    /// If `true`, perform a deep traversal recursively gathering markers from all sub-elements.
    /// If `false`, perform a shallow traversal of only the element's own markers.
    public var deep: Bool
    
    /// Filter to apply to Auditions.
    public var auditionMask: FinalCutPro.FCPXML.Audition.Mask
    
    public init(
        deep: Bool,
        auditionMask: FinalCutPro.FCPXML.Audition.Mask
    ) {
        self.deep = deep
        self.auditionMask = auditionMask
    }
}

//extension FCPXMLMarkersExtractionSettings {
//    func offset(of newOffset: Timecode?) -> Self {
//        var copy = self
//        copy.ancestorTCStart = newOffset
//        return copy
//    }
//    
//    func offset(by delta: Timecode?) -> Self {
//        var copy = self
//        if let delta = delta {
//            if let po = copy.ancestorTCStart {
//                copy.ancestorTCStart = po + delta
//            } else {
//                copy.ancestorTCStart = delta
//            }
//        } else {
//            copy.ancestorTCStart = delta
//        }
//        return copy
//    }
//}

extension FinalCutPro.FCPXML {
    /// Contains an extracted marker along with pertinent contextual metadata.
    public struct ExtractedMarker {
        public var marker: Marker
        
        public var absoluteStart: Timecode?
        
        public var parentType: ClipType
        public var parentName: String?
        public var parentStart: Timecode?
        public var parentDuration: Timecode?
        
        init(
            marker: Marker,
            settings: FCPXMLMarkersExtractionSettings,
            parent: AnyClip
        ) {
            self.marker = marker
            
            if let parentOffset = parent.offset,
               let parentStart = parent.start
            {
                let offsetFromParentStart = marker.start - parentStart
                if let newTimecode = try? parentOffset.adding(offsetFromParentStart, by: .wrapping) {
                    absoluteStart = newTimecode
                } else {
                    print("Error offsetting timecode for marker \(marker.name.quoted).")
                }
            }
            
            parentType = parent.clipType
            parentName = parent.name
            parentStart = parent.start
            parentDuration = parent.duration
        }
    }
}

extension Collection<FinalCutPro.FCPXML.Marker> {
    func convertToExtractedMarkers(
        settings: FCPXMLMarkersExtractionSettings,
        parent: FinalCutPro.FCPXML.AnyClip
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        map {
            FinalCutPro.FCPXML.ExtractedMarker(
                marker: $0,
                settings: settings,
                parent: parent
            )
        }
    }
}

#endif
