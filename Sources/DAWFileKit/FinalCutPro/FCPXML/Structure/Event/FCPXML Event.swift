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
        
        public var projects: [Project]
        public var clips: [AnyClip]
        
        // TODO: public var collectionFolders: [CollectionFolder] = []
        // TODO: public var keywordCollections: [KeywordCollection] = []
        // TODO: public var smartCollections: [SmartCollection] = []
        
        public init(
            name: String? = nil,
            uid: String? = nil,
            projects: [Project] = [],
            clips: [AnyClip] = []
        ) {
            self.name = name
            self.uid = uid
            self.projects = projects
            self.clips = clips
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
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        name = xmlLeaf.attributeStringValue(forName: Attributes.name.rawValue)
        uid = xmlLeaf.attributeStringValue(forName: Attributes.uid.rawValue)
        
        projects = FinalCutPro.FCPXML.projects(in: xmlLeaf, resources: resources)
        clips = FinalCutPro.FCPXML.parseClips(in: xmlLeaf, resources: resources)
    }
}

extension FinalCutPro.FCPXML.Event: FCPXMLStructureElement {
    public var structureElementType: FinalCutPro.FCPXML.StructureElementType {
        .event
    }
}

extension FinalCutPro.FCPXML.Event: FCPXMLMarkersExtractable {
    /// Always returns an empty array since an event cannot directly contain markers.
    public var markers: [FinalCutPro.FCPXML.Marker] {
        []
    }
    
    public func extractMarkers(
        settings: FCPXMLMarkersExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        let settings = settings.updating(ancestorEventName: name)
        
        // (can't include self as an ancestor since Event is not a story element)
        
        let projectsMarkers = projects.flatMap {
            $0.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        }
        
        let clipsMarkers = clips.flatMap {
            $0.extractMarkers(settings: settings, ancestorsOfParent: ancestorsOfParent)
        }
        return projectsMarkers + clipsMarkers
    }
}

#endif
