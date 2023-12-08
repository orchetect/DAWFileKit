//
//  FCPXML AudioRoleSource.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// FCPXML 1.11 DTD:
    /// "An `audio-role-source` element adjusts playback settings for a single role-based audio
    /// component in a clip."
    public struct AudioRoleSource: FCPXMLElement, Equatable, Hashable {
        public let element: XMLElement
        public let elementName: String = "audio-role-source"
        
        /// Role the audio component is associated with.
        public var role: AudioRole? {
            get { element.fcpAudioRole }
            set { element.fcpAudioRole = newValue }
        }
        
        /// Active state of the audio role source.
        public var active: Bool {
            get { element.fcpGetActive(default: true) }
            set { element.fcpSet(active: newValue, default: true) }
        }
        
        // Children
        
        /// Returns all child elements.
        public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
            element.childElements
        }
        
        // MARK: FCPXMLElement inits
        
        public init() {
            element = XMLElement(name: elementName)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementValid(element: element) else { return nil }
        }
    }
}

extension FinalCutPro.FCPXML.AudioRoleSource {
    public enum Element: String {
        case name = "audio-role-source"
    }
    
    public enum Attributes: String, XMLParsableAttributesKey {
        /// Role the audio component is associated with.
        case role
        /// Active state of the audio role source.
        case active // default true
    }
    
    // can contain adjusts
    // can contain filters
}

extension XMLElement { // AudioRoleSource
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/AudioRoleSource`` model object.
    /// Call this on a `audio-role-source` element only.
    public var fcpAsAudioRoleSource: FinalCutPro.FCPXML.AudioRoleSource? {
        .init(element: self)
    }
}

// MARK: - Collection Methods

extension Sequence where Element == FinalCutPro.FCPXML.AudioRoleSource {
    /// Convert and wrap the audio role source as ``FinalCutPro/FCPXML/AnyRole``
    public func asAnyRoles() -> [FinalCutPro.FCPXML.AnyRole] {
        compactMap { $0.role }
            .compactMap { FinalCutPro.FCPXML.AnyRole.audio($0) }
    }
}

#endif
