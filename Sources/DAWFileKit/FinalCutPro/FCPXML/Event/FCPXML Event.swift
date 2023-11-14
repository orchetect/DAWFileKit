//
//  FCPXML Event.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import CoreMedia
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Represent a single event in a library.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > An event may contain clips as story elements and projects, along with keyword collections
    /// > and smart collections. The keyword-collection and smart-collection elements organize clips
    /// > by keywords and other matching criteria listed under the Smart Collection Match Elements.
    public struct Event {
        public var name: String?
        public var uid: String?
        
        // TODO: public var auditions: [Audition] = []
        
        public var clips: [AnyClip]
        
        // TODO: public var collectionFolders: [CollectionFolder] = []
        
        // TODO: public var keywordCollections: [KeywordCollection] = []
        
        // TODO: public var smartCollections: [SmartCollection] = []
        
        public var projects: [Project]
        
        public init(
            name: String? = nil,
            uid: String? = nil,
            clips: [AnyClip] = [],
            projects: [Project] = []
        ) {
            self.name = name
            self.uid = uid
            self.clips = clips
            self.projects = projects
        }
    }
}

extension FinalCutPro.FCPXML.Event {
    /// Attributes unique to ``Event``.
    public enum Attributes: String {
        case name
        case uid
    }
    
    init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        frameRate: TimecodeFrameRate
    ) {
        name = xmlLeaf.attributeStringValue(forName: Attributes.name.rawValue)
        uid = xmlLeaf.attributeStringValue(forName: Attributes.uid.rawValue)
        
        // TODO: refactor using resources instead of frameRate?
        clips = FinalCutPro.FCPXML.parseClips(in: xmlLeaf, frameRate: frameRate)
        
        projects = FinalCutPro.FCPXML.projects(in: xmlLeaf, resources: resources)
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
        self.init(from: xmlLeaf, resources: resources, frameRate: frameRate)
    }
}

#endif
