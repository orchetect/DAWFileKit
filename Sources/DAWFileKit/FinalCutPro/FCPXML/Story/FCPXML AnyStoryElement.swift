//
//  FCPXML AnyStoryElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
//import CoreMedia
//@_implementationOnly import OTCore

extension FinalCutPro.FCPXML {
    /// Type-erased box containing a story element.
    public enum AnyStoryElement: FCPXMLStoryElement {
        case anyClip(AnyClip)
        case audition(Audition)
        case gap(Gap)
        case sequence(Sequence)
        case spine(XMLElement) // TODO: replace with new Spine struct
    }
}

extension FinalCutPro.FCPXML.AnyStoryElement {
    init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        guard let name = xmlLeaf.name else { return nil }
        
        if let clip = FinalCutPro.FCPXML.AnyClip(from: xmlLeaf, resources: resources) {
            self = .anyClip(clip)
            return
        }
        
        if let storyElementType = FinalCutPro.FCPXML.StoryElementType(rawValue: name) {
            switch storyElementType {
            case .audition:
                let element = FinalCutPro.FCPXML.Audition(from: xmlLeaf, resources: resources)
                self = .audition(element)
                
            case .gap:
                let element = FinalCutPro.FCPXML.Gap(from: xmlLeaf, resources: resources)
                self = .gap(element)
                
            case .sequence:
                guard let element = FinalCutPro.FCPXML.Sequence(from: xmlLeaf, resources: resources)
                else {
                    print("Failed to parse FCPXML sequence.")
                    return nil
                }
                self = .sequence(element)
                
            case .spine:
                self = .spine(xmlLeaf)
            }
        }
        
        return nil
    }
}

extension FinalCutPro.FCPXML.AnyStoryElement {
    // TODO: refactor using protocol and generics?
    /// Convenience to return markers within the story element.
    /// Operation is not recursive, and only returns markers attached to the clip itself and not markers within nested clips.
    public var markers: [FinalCutPro.FCPXML.Marker] {
        switch self {
        case let .anyClip(clip): 
            return clip.markers
        case let .audition(audition):
            return audition.clips.flatMap { $0.markers }
        case let .gap(gap):
            return gap.markers
        case let .sequence(sequence):
            return sequence.spine.flatMap { $0.markers }
        case .spine(_):
            print("Spine markers parsing: Not yet implemented.")
            return []
        }
    }
    
    // TODO: refactor using protocol and generics?
    /// Convenience to return markers within the story element.
    /// Operation is recursive and returns markers for all nested clips and elements.
    public func markersDeep(
        auditions auditionMask: FinalCutPro.FCPXML.Audition.Mask
    ) -> [FinalCutPro.FCPXML.Marker] {
        switch self {
        case let .anyClip(clip):
            return clip.markersDeep(auditions: auditionMask)
        case let .audition(audition):
            return audition.markersDeep(for: auditionMask)
        case let .gap(gap):
            return gap.markersDeep(auditions: auditionMask)
        case let .sequence(sequence):
            return sequence.spine.flatMap { $0.markersDeep(auditions: auditionMask) }
        case .spine(_):
            print("Spine markers parsing: Not yet implemented.")
            return []
        }
    }
}

#endif
