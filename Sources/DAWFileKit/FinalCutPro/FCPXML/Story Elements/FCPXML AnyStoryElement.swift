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
        case audio(XMLElement)
        case video(XMLElement)
        case audition(XMLElement)
        case gap(XMLElement)
        case transition(XMLElement)
    }
}

extension FinalCutPro.FCPXML {
    /// Story element type.
    public enum StoryElementType: String, CaseIterable {
        case audio
        case video
        case audition
        case gap
        case transition
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
        
        guard let seType = FinalCutPro.FCPXML.StoryElementType(rawValue: name) else {
            return nil
        }
        
        // TODO: add strong types to replace raw XML
        switch seType {
        case .audio:
            self = .audio(xmlLeaf)
        case .video:
            self = .video(xmlLeaf)
        case .audition:
            self = .audition(xmlLeaf)
        case .gap:
            self = .gap(xmlLeaf)
        case .transition:
            self = .transition(xmlLeaf)
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
