//
//  FCPXML Audition.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Contains one active story element followed by alternative story elements in the audition
    /// > container.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > When exported, the XML lists the currently active item as the first child in the audition
    /// > container.
    public struct Audition: Equatable, Hashable {
        public let element: XMLElement
        
        // Anchorable Attributes
        
        public var lane: Int? {
            get { element.fcpLane }
            set { element.fcpLane = newValue }
        }
        
        public var offset: Fraction? {
            get { element.fcpOffset }
            set { element.fcpOffset = newValue }
        }
        
        // TODO: public var dateModified: Date?
        
        // Children
        
        /// Returns the audition clips.
        /// The first clip is the active audition and subsequent clips are inactive.
        /// The convenience property ``activeClip`` is also available to return the first clip.
        public var clips: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpStoryElements
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Audition /* Clip Attributes */ {
    /// Returns the active clip's `name` attribute.
    public var name: String? {
        activeClip?.name
    }
    
    /// Returns the active clip's `start` attribute.
    public var start: Fraction? {
        activeClip?.fcpStart
    }
    
    /// Returns the active clip's `duration` attribute.
    public var duration: Fraction? {
        activeClip?.fcpDuration
    }
    
    /// Returns the active clip's `enabled` attribute.
    public var enabled: Bool {
        activeClip?.fcpEnabled ?? true
    }
}

extension FinalCutPro.FCPXML.Audition {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .audition
    
    public enum Attributes: String, XMLParsableAttributesKey {
        // Anchorable Attributes
        case lane
        case offset
        
        case modDate
    }
    
    // contains one or more clips
}

extension FinalCutPro.FCPXML.Audition {
    /// Convenience to return the active audition clip.
    public var activeClip: XMLElement? {
        clips.first
    }
    
    /// Convenience to return the inactive audition clips, if any.
    public var inactiveClips: LazyFilterSequence<
        LazyCompactMapSequence<[XMLNode], XMLElement>.Elements
    >.SubSequence {
        clips.dropFirst()
    }
}

extension FinalCutPro.FCPXML.Audition {
    public enum Mask: Equatable, Hashable, CaseIterable, Sendable {
        case active
        case activeAndAlternates
    }
}

#endif
