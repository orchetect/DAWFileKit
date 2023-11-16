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
    /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
    func extractMarkers(
        settings: FCPXMLMarkersExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> [FinalCutPro.FCPXML.ExtractedMarker]
}

public struct FCPXMLMarkersExtractionSettings {
    // /// If `true`, perform a deep traversal recursively gathering markers from all sub-elements.
    // /// If `false`, perform a shallow traversal of only the element's own markers.
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
        public var parentType: StoryElementType
        
        /// The parent clip's name.
        public var parentName: String?
        
        /// The parent clip's absolute start time.
        public var parentAbsoluteStart: Timecode?
        
        /// The parent clip's duration.
        public var parentDuration: Timecode?
        
        /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
        init(
            marker: Marker,
            settings: FCPXMLMarkersExtractionSettings,
            parent: AnyStoryElement,
            ancestorsOfParent: [AnyStoryElement]
        ) {
            self.marker = marker
            
            ancestorEventName = settings.ancestorEventName
            ancestorProjectName = settings.ancestorProjectName
            
            parentType = parent.storyElementType
            parentName = parent.name
            parentAbsoluteStart = Self.aggregateOffset(parent: parent, ancestorsOfParent: ancestorsOfParent)
            parentDuration = parent.duration
            
            // calculate absolute start
            
            let parentStart = Self.nearestStart(parent: parent, ancestorsOfParent: ancestorsOfParent)
            
            if let parentStart = parentStart,
               let parentAbsoluteStart = parentAbsoluteStart
            {
                let localMarkerStart = marker.start - parentStart
                if let markerAbsoluteStart = try? parentAbsoluteStart.adding(localMarkerStart, by: .wrapping) {
                    absoluteStart = markerAbsoluteStart
                } else {
                    print("Error offsetting timecode for marker \(marker.name.quoted).")
                }
            } else {
                let pas = parentAbsoluteStart?.stringValue(format: [.showSubFrames]) ?? "missing"
                let ps = parentStart?.stringValue(format: [.showSubFrames]) ?? "missing"
                print(
                    "Error calculating absolute timecode for marker \(marker.name.quoted)."
                    + " Parent absolute start: \(pas) Parent start: \(ps)"
                )
            }
        }
        
        /// Return absolute timecode of innermost parent by calculating aggregate offset of ancestors.
        /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
        private static func aggregateOffset(
            parent: AnyStoryElement, 
            ancestorsOfParent: [AnyStoryElement]
        ) -> Timecode? {
            let ancestors = ancestorsOfParent + [parent] // topmost -> innermost
            
            var pos: Timecode?
            
            func add(_ other: Timecode?) {
                guard let other = other else { return }
                let newTC = pos ?? Timecode(.zero, using: other.properties)
                pos = try? newTC.adding(other, by: .wrapping)
            }
            
            for ancestor in ancestors {
                switch ancestor {
                case let .anyClip(clip):
                    add(clip.offset)
                    
                case .sequence(_ /* let sequence */):
                    // pos = sequence.startTimecode
                    break
                    
                case let .spine(spine):
                    add(spine.offset)
                }
                
            }
            
            return pos
        }
        
        /// Return nearest `start` attribute value, starting from closest parent and traversing up
        /// through ancestors.
        /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
        private static func nearestStart(
            parent: AnyStoryElement,
            ancestorsOfParent: [AnyStoryElement]
        ) -> Timecode? {
            let ancestors = ancestorsOfParent + [parent] // topmost -> innermost
            
            for ancestor in ancestors.reversed() {
                if let start = ancestor.start { return start }
            }
            
            return nil
        }
    }
}

// MARK: - Extraction Logic

extension FCPXMLMarkersExtractable where Self: FCPXMLStoryElement {
    public func extractMarkers(
        settings: FCPXMLMarkersExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement],
        children: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        let ownMarkers = markers.convertToExtractedMarkers(
            settings: settings,
            parent: self.asAnyStoryElement(),
            ancestorsOfParent: ancestorsOfParent
        )
        
        let childAncestors = ancestorsOfParent + [self.asAnyStoryElement()]
        
        let clipsMarkers = children.flatMap {
            $0.extractMarkers(settings: settings, ancestorsOfParent: childAncestors)
        }
        
        return ownMarkers + clipsMarkers
    }
}

extension Collection<FinalCutPro.FCPXML.Marker> {
    func convertToExtractedMarkers(
        settings: FCPXMLMarkersExtractionSettings,
        parent: FinalCutPro.FCPXML.AnyStoryElement,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        compactMap {
            guard !settings.excludeTypes.contains(parent.storyElementType) else { return nil }
            
            return FinalCutPro.FCPXML.ExtractedMarker(
                marker: $0,
                settings: settings,
                parent: parent,
                ancestorsOfParent: ancestorsOfParent
            )
        }
    }
}

#endif
