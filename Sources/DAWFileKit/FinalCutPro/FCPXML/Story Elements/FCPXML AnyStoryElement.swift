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
        case audition(XMLElement)
        case gap(XMLElement)
        case sequence(XMLElement)
        case spine(XMLElement)
        // case transition(XMLElement)
    }
}

extension FinalCutPro.FCPXML.AnyStoryElement {
    init?(
        from xmlLeaf: XMLElement,
        frameRate: TimecodeFrameRate
    ) {
        guard let name = xmlLeaf.name else { return nil }
        
        if let clip = FinalCutPro.FCPXML.AnyClip(from: xmlLeaf, frameRate: frameRate) {
            self = .anyClip(clip)
            return
        }
        
        guard let storyElementType = FinalCutPro.FCPXML.StoryElementType(rawValue: name) else {
            return nil
        }
        
        // TODO: add strong types to replace raw XML
        switch storyElementType {
        case .audition:
            self = .audition(xmlLeaf)
        case .gap:
            self = .gap(xmlLeaf)
        case .sequence:
            self = .sequence(xmlLeaf)
        case .spine:
            self = .spine(xmlLeaf)
        // case .transition:
        //     self = .transition(xmlLeaf)
        }
    }
    
    init?<C: FCPXMLTimelineAttributes>(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        timelineContext: C.Type,
        timelineContextInstance: C
    ) {
        guard let frameRate = FinalCutPro.FCPXML.parseTimecodeFrameRate(
            from: xmlLeaf,
            resources: resources,
            timelineContext: timelineContext,
            timelineContextInstance: timelineContextInstance
        ) else { return nil }
        self.init(from: xmlLeaf, frameRate: frameRate)
    }
}

#endif
