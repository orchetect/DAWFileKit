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
    public enum AnyStoryElement {
        case anyClip(AnyClip)
        case sequence(Sequence)
        case spine(Spine)
    }
}

extension FinalCutPro.FCPXML.AnyStoryElement: FCPXMLStoryElement {
    /// Clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case name
        
        // case offset // handled with FCPXMLClipAttributes
        // case start // handled with FCPXMLClipAttributes
        // case duration // handled with FCPXMLClipAttributes
        
        case audioRole
        case role // TODO: video role; change name to `videoRole`?
    }
    
    public init?(
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
            guard let element = FinalCutPro.FCPXML.Spine(from: xmlLeaf, resources: resources)
            else { return nil }
            self = .spine(element)
        }
    }
    
    public var storyElementType: FinalCutPro.FCPXML.StoryElementType {
        switch self {
        case let .anyClip(clip): return .anyClip(clip.clipType)
        case .sequence(_): return .sequence
        case .spine(_): return .spine
        }
    }
    
    /// Redundant, but required to fulfill `FCPXMLStoryElement` protocol requirements.
    public func asAnyStoryElement() -> FinalCutPro.FCPXML.AnyStoryElement {
        self
    }
}

// MARK: Convenience Properties

extension FinalCutPro.FCPXML.AnyStoryElement {
    // FCPXMLAnchorableAttributes
    
    /// Convenience to return the lane of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var lane: Int? {
        switch self {
        case let .anyClip(clip): return clip.lane
        case .sequence(_): return nil
        case let .spine(spine): return spine.lane
        }
    }
    
    /// Convenience to return the offset of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var offset: Timecode? {
        switch self {
        case let .anyClip(clip): return clip.offset
        case .sequence(_): return nil
        case let .spine(spine): return spine.offset
        }
    }
    
    // FCPXMLClipAttributes
    
    /// Convenience to return the name of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var name: String? {
        switch self {
        case let .anyClip(clip): return clip.name
        case .sequence(_): return nil
        case let .spine(spine): return spine.name
        }
    }
    
    /// Convenience to return the start of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    /// For `sequence`, returns its absolute `startTimecode`.
    public var start: Timecode? {
        switch self {
        case let .anyClip(clip): return clip.start
        case let .sequence(sequence): return sequence.startTimecode
        case .spine(_): return nil
        }
    }
    
    /// Convenience to return the duration of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var duration: Timecode? {
        switch self {
        case let .anyClip(clip): return clip.duration
        case let .sequence(sequence): return sequence.duration
        case .spine(_): return nil
        }
    }
    
    /// Convenience to return the enabled state of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var enabled: Bool {
        switch self {
        case let .anyClip(clip): return clip.enabled
        case .sequence(_): return true
        case .spine(_): return true
        }
    }
}

extension FinalCutPro.FCPXML.AnyStoryElement: _FCPXMLExtractableElement {
    var extractableStart: Timecode? { start }
    var extractableName: String? { name }
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
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        switch self {
        case let .anyClip(clip):
            return clip.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        case let .sequence(sequence):
            return sequence.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        case let .spine(spine):
            return spine.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        }
    }
}

#endif
