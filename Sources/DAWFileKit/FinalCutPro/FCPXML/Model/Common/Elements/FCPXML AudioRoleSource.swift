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
        
        public let elementType: ElementType = .audioRoleSource
        
        public static let supportedElementTypes: Set<ElementType> = [.audioRoleSource]
        
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

extension FinalCutPro.FCPXML.AudioRoleSource {
    public enum Attributes: String {
        /// Role the audio component is associated with.
        case role
        /// Active state of the audio role source.
        case active // default true
    }
    
    // can contain adjusts
    // can contain filters
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.AudioRoleSource {
    /// Role the audio component is associated with.
    public var role: FinalCutPro.FCPXML.AudioRole {
        get { 
            element.fcpRole(as: FinalCutPro.FCPXML.AudioRole.self)
                ?? .defaultAudioRole
        }
        set { element.fcpSet(role: newValue) }
    }
    
    /// Active state of the audio role source.
    public var active: Bool {
        get { element.fcpGetActive(default: true) }
        set { element.fcpSet(active: newValue, default: true) }
    }
}

// MARK: - Children

extension FinalCutPro.FCPXML.AudioRoleSource {
    /// Returns all child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        element.childElements
    }
}

// MARK: - Typing

// AudioRoleSource
extension XMLElement {
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
            .compactMap { .audio($0) }
    }
}

#endif
