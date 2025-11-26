//
//  FCPXML SyncSource.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore
import SwiftExtensions

extension FinalCutPro.FCPXML.SyncClip {
    /// Describes an the audio component of a synchronized clip.
    ///
    /// > FCPXML 1.11 DTD:
    /// > A `sync-source` element defines the role-based audio components to be used
    /// > for a source of a synchronized clip.
    public struct SyncSource: FCPXMLElement {
        public let element: XMLElement
        
        public let elementType: FinalCutPro.FCPXML.ElementType = .syncSource
        
        public static let supportedElementTypes: Set<FinalCutPro.FCPXML.ElementType> = [.syncSource]
        
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

extension FinalCutPro.FCPXML.SyncClip.SyncSource {
    public init(
        sourceID: SourceID
    ) {
        self.init()
        
        self.sourceID = sourceID
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.SyncClip.SyncSource {
    public enum Attributes: String {
        // Element-Specific Attributes
        
        /// Required.
        /// Synchronization source ID.
        case sourceID // required
    }
    
    // contains DTD audio-role-source*
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.SyncClip.SyncSource {
    public var sourceID: SourceID? { // only used in `sync-source`
        get {
            guard let value = element.stringValue(forAttributeNamed: Attributes.sourceID.rawValue)
            else { return nil }
            
            return SourceID(rawValue: value)
        }
        nonmutating set {
            // required attribute, don't allow setting nil
            guard let newValue = newValue else { return }
            
            element.addAttribute(withName: Attributes.sourceID.rawValue, value: newValue.rawValue)
        }
    }
}

// MARK: - Children

extension FinalCutPro.FCPXML.SyncClip.SyncSource {
    /// Get or set child `audio-role-source` elements.
    public var audioRoleSources: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.AudioRoleSource> {
        get { element.fcpAudioRoleSources }
        nonmutating set { element.fcpAudioRoleSources = newValue }
    }
}

// MARK: - Typing

// SyncClip.SyncSource
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/SyncClip/SyncSource`` model object.
    /// Call this on a `sync-source` element only.
    public var fcpAsSyncSource: FinalCutPro.FCPXML.SyncClip.SyncSource? {
        .init(element: self)
    }
}

// SyncClip
extension XMLElement {
    /// FCPXML: Returns child `sync-source` elements.
    /// Use on `sync-clip` elements only.
    public var fcpSyncSources: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.SyncClip.SyncSource> {
        get { children(whereFCPElement: .syncSource) }
        set { _updateChildElements(ofType: .syncSource, with: newValue) }
    }
}

// MARK: - Attribute Types

extension FinalCutPro.FCPXML.SyncClip.SyncSource {
    public enum SourceID: String, Equatable, Hashable, CaseIterable {
        case storyline
        case connected
    }
}

#endif
