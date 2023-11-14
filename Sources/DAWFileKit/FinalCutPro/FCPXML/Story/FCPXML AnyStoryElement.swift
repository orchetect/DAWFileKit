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
        // case transition(XMLElement)
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
        
        guard let storyElementType = FinalCutPro.FCPXML.StoryElementType(rawValue: name) else {
            return nil
        }
        
        // TODO: add strong types to replace raw XML
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
            
        // case .transition:
        //     self = .transition(xmlLeaf)
        }
    }
}

#endif
