//
//  FCPXML AnyStoryElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Type-erased box containing a story element.
    public enum AnyStoryElement: FCPXMLStoryElement {
        case anyClip(AnyClip)
        case sequence(Sequence)
        case spine(Spine)
    }
}

extension FinalCutPro.FCPXML.AnyStoryElement {
    init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        guard let name = xmlLeaf.name else { return nil }
        
        guard let storyElementType = FinalCutPro.FCPXML.StoryElementType(rawValue: name)
        else { return nil }
        
        switch storyElementType {
        case .anyClip:
            guard let clip = FinalCutPro.FCPXML.AnyClip(from: xmlLeaf, resources: resources)
            else { return nil }
            
            self = .anyClip(clip)
                
        case .sequence:
            guard let element = FinalCutPro.FCPXML.Sequence(from: xmlLeaf, resources: resources)
            else {
                print("Failed to parse FCPXML sequence.")
                return nil
            }
            self = .sequence(element)
                
        case .spine:
            let element = FinalCutPro.FCPXML.Spine(from: xmlLeaf, resources: resources)
            self = .spine(element)
        }
    }
}

extension FinalCutPro.FCPXML.AnyStoryElement: FCPXMLMarkersExtractable {
    public var markers: [FinalCutPro.FCPXML.Marker] {
        switch self {
        case let .anyClip(clip):
            return clip.markers
        case let .sequence(sequence):
            return sequence.markers
        case let .spine(spine):
            return spine.markers
        }
    }
    
    public func extractMarkers(
        settings: FCPXMLMarkersExtractionSettings
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        switch self {
        case let .anyClip(clip):
            return clip.extractMarkers(settings: settings)
        case let .sequence(sequence):
            return sequence.extractMarkers(settings: settings)
        case let .spine(spine):
            return spine.extractMarkers(settings: settings)
        }
    }
}

#endif
