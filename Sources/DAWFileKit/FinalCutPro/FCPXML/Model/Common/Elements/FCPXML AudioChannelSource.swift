//
//  FCPXML AudioChannelSource.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// FCPXML 1.11 DTD:
    /// "An `audio-channel-source` element adjusts playback settings for a single channel-based
    /// audio component in a clip's primary audio layout.
    /// The primary audio layout is comprised of all audio from elements in the primary (lane 0)
    /// storyline."
    public struct AudioChannelSource: FCPXMLElement, Equatable, Hashable {
        public let element: XMLElement
        
        public let elementType: ElementType = .audioChannelSource
        
        public static let supportedElementTypes: Set<ElementType> = [.audioChannelSource]
        
        public init() {
            element = XMLElement(name: elementType.rawValue)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementTypeSupported(element: element) else { return nil }
        }
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.AudioChannelSource {
    public enum Attributes: String {
        /// Source audio channels (comma separated, 1-based index, ie: "1, 2")
        case sourceChannels = "srcCh"
        /// Output audio channels (comma separated, from: `L,R,C,LFE,Ls,Rs,X`)
        case outputChannels = "outCh"
        /// Output role assignment.
        case role
        
        case start
        case duration
        case enabled
        case active
    }
    
    // contains adjusts
    // contains filters
    // contains mutes
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.AudioChannelSource {
    /// Source audio channels (comma separated, 1-based index, ie: "1, 2")
    public var sourceChannels: String? {
        get { element.fcpSourceChannels }
        set { element.fcpSourceChannels = newValue }
    }
    
    /// Output audio channels (comma separated, from: `L,R,C,LFE,Ls,Rs,X`)
    public var outputChannels: String? {
        get { element.fcpOutputChannels }
        set { element.fcpOutputChannels = newValue }
    }
    
    /// Output role assignment.
    public var role: FinalCutPro.FCPXML.AudioRole? {
        get { element.fcpAudioRole }
        set { element.fcpAudioRole = newValue }
    }
    
    public var start: Fraction? {
        get { element.fcpStart }
        set { element.fcpStart = newValue }
    }
    
    public var duration: Fraction? {
        get { element.fcpDuration }
        set { element.fcpDuration = newValue }
    }
    
    public var enabled: Bool {
        get { element.fcpGetEnabled(default: true) }
        set { element.fcpSet(enabled: newValue, default: true) }
    }
    
    public var active: Bool {
        get { element.fcpGetActive(default: true) }
        set { element.fcpSet(active: newValue, default: true) }
    }
}

// MARK: - Children

extension FinalCutPro.FCPXML.AudioChannelSource {
    /// Returns all child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        element.childElements
    }
    
    // TODO: public var adjusts: []
    // TODO: public var filters: []
    // TODO: public var mutes: []
}

// MARK: - Typing

// AudioChannelSource
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/AudioChannelSource`` model object.
    /// Call this on a `audio-channel-source` element only.
    public var fcpAsAudioChannelSource: FinalCutPro.FCPXML.AudioChannelSource? {
        .init(element: self)
    }
}

// MARK: - Collection Methods

extension Sequence where Element == FinalCutPro.FCPXML.AudioChannelSource {
    /// Convert and wrap the audio channel source roles as ``FinalCutPro/FCPXML/AnyRole``
    public func asAnyRoles() -> [FinalCutPro.FCPXML.AnyRole] {
        compactMap(\.role)
            .compactMap { .audio($0) }
    }
}

#endif
