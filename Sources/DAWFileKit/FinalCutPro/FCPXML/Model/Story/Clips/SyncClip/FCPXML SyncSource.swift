//
//  FCPXML SyncSource.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML.SyncClip {
    /// Describes an the audio component of a synchronized clip.
    ///
    /// > FCPXML 1.11 DTD:
    /// > A `sync-source` element defines the role-based audio components to be used
    /// > for a source of a synchronized clip.
    public struct SyncSource: FCPXMLElement {
        public let element: XMLElement
        public let elementName: String = "sync-source"
        
        // Element-Specific Attributes
        
        public var sourceID: SourceID? { // only used in `sync-source`
            get {
                guard let value = element.stringValue(forAttributeNamed: Attributes.sourceID.rawValue)
                else { return nil }
                
                return SourceID(rawValue: value)
            }
            set {
                element.addAttribute(withName: Attributes.sourceID.rawValue, value: newValue?.rawValue)
            }
        }
        
        // Children
        
        /// Returns child `audio-role-source` elements.
        public var audioRoleSources: LazyMapSequence<
            LazyFilterSequence<LazyMapSequence<
                LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>>.Elements,
                FinalCutPro.FCPXML.AudioRoleSource?
            >>,
            FinalCutPro.FCPXML.AudioRoleSource
        > {
            element.fcpAudioRoleSources()
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

extension FinalCutPro.FCPXML.SyncClip.SyncSource {
    public enum Element: String {
        case name = "sync-source"
    }
    
    public enum Attributes: String {
        // Element-Specific Attributes
        
        /// Required.
        /// Synchronization source ID.
        case sourceID // required
    }
    
    public enum Children: String {
        case audioRoleSource = "audio-role-source"
    }
}

extension XMLElement { // SyncClip.SyncSource
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/SyncClip/SyncSource`` model object.
    /// Call this on a `sync-source` element only.
    public var fcpAsSyncSource: FinalCutPro.FCPXML.SyncClip.SyncSource? {
        .init(element: self)
    }
}

extension XMLElement { // SyncClip
    /// FCPXML: Returns child `sync-source` elements.
    /// Use on `sync-clip` elements only.
    public func fcpSyncSources() -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<
        LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>>.Elements,
        FinalCutPro.FCPXML.SyncClip.SyncSource?
    >>, FinalCutPro.FCPXML.SyncClip.SyncSource
    > {
        childElements
            .filter(whereElementNamed: FinalCutPro.FCPXML.SyncClip.Children.syncSource.rawValue)
            .compactMap(\.fcpAsSyncSource)
    }
}

extension FinalCutPro.FCPXML.SyncClip.SyncSource {
    public enum SourceID: String, Equatable, Hashable, CaseIterable {
        case storyline
        case connected
    }
}

#endif
