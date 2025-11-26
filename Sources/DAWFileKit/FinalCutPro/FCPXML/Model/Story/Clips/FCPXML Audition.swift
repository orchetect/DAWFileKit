//
//  FCPXML Audition.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import SwiftExtensions

extension FinalCutPro.FCPXML {
    /// Contains one active story element followed by alternative story elements in the audition
    /// > container.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > When exported, the XML lists the currently active item as the first child in the audition
    /// > container.
    public struct Audition: FCPXMLElement {
        public let element: XMLElement
        
        public let elementType: ElementType = .audition
        
        public static let supportedElementTypes: Set<ElementType> = [.audition]
        
        public init() {
            element = XMLElement(name: elementType.rawValue)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementTypeSupported(element: element) else { return nil }
        }
    }
}

// MARK: - Parameterized init

extension FinalCutPro.FCPXML.Audition {
    public init(
        // Anchorable Attributes
        lane: Int? = nil,
        offset: Fraction? = nil,
        // Mod Date
        modDate: String? = nil
    ) {
        self.init()
        
        // Anchorable Attributes
        self.lane = lane
        self.offset = offset
        
        // Mod Date
        self.modDate = modDate
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Audition {
    public enum Attributes: String {
        // Element-Specific Attributes
        case modDate
        
        // Anchorable Attributes
        case lane
        case offset
    }
    
    // can only contain one or more clips
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Audition: FCPXMLElementAnchorableAttributes { }

extension FinalCutPro.FCPXML.Audition: FCPXMLElementOptionalModDate { }

// TODO: remove these? might be better to explicitly have to access the active clip.
extension FinalCutPro.FCPXML.Audition /* Clip Attributes */ {
    /// Get or set the active clip's `name` attribute.
    public var name: String? {
        get { activeClip?.fcpName }
        nonmutating set { activeClip?.fcpName = newValue }
    }
    
    /// Get or set the active clip's `start` attribute.
    public var start: Fraction? {
        get { activeClip?.fcpStart }
        nonmutating set { activeClip?.fcpStart = newValue }
    }
    
    /// Get or set the active clip's `duration` attribute.
    public var duration: Fraction? {
        get { activeClip?.fcpDuration }
        nonmutating set { activeClip?.fcpDuration = newValue }
    }
    
    /// Get or set the active clip's `enabled` attribute.
    public var enabled: Bool {
        get { activeClip?.fcpGetEnabled(default: true) ?? true }
        nonmutating set { activeClip?.fcpSet(enabled: newValue, default: true) }
    }
}

// MARK: - Children

extension FinalCutPro.FCPXML.Audition {
    /// Returns the audition clips.
    /// The first clip is the active audition and subsequent clips are inactive.
    /// The convenience property ``activeClip`` is also available to return the first clip.
    public var clips: LazyCompactMapSequence<[XMLNode], XMLElement> {
        get { element.childElements }
        nonmutating set {
            element.removeAllChildren()
            element.addChildren(newValue)
        }
    }
    
    /// Convenience to return the active audition clip.
    public var activeClip: XMLElement? {
        get { clips.first }
        nonmutating set {
            guard let newValue = newValue else { return }
            guard !clips.isEmpty else {
                element.addChild(newValue)
                return
            }
            element.replaceChild(at: 0, with: newValue)
        }
    }
    
    /// Convenience to return the inactive audition clips, if any.
    public var inactiveClips: LazyCompactMapSequence<[XMLNode], XMLElement>.SubSequence {
        clips.dropFirst()
    }
}

// MARK: - Typing

// Audition
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Audition`` model object.
    /// Call this on a `audition` element only.
    public var fcpAsAudition: FinalCutPro.FCPXML.Audition? {
        .init(element: self)
    }
}

// MARK: - Supporting Types

extension FinalCutPro.FCPXML.Audition {
    public enum AuditionMask: Equatable, Hashable, CaseIterable, Sendable {
        case active
        case all
    }
}

#endif
