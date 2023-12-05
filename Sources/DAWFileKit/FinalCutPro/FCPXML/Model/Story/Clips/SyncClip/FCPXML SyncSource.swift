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
    public struct SyncSource: Equatable, Hashable {
        public let element: XMLElement
        
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
        public var audioRoleSources: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpAudioRoleSources
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.SyncClip.SyncSource {
    public enum Element: String {
        case name = "sync-source"
    }
    
    public enum Attributes: String, XMLParsableAttributesKey {
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
    public var fcpAsSyncSource: FinalCutPro.FCPXML.SyncClip.SyncSource {
        .init(element: self)
    }
}

extension XMLElement { // SyncClip
    /// FCPXML: Returns child `sync-source` elements.
    /// Use on `sync-clip` elements only.
    public var fcpSyncSources: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.name == FinalCutPro.FCPXML.SyncClip.Children.syncSource.rawValue }
    }
}

extension FinalCutPro.FCPXML.SyncClip.SyncSource {
    public enum SourceID: String, Equatable, Hashable, CaseIterable {
        case storyline
        case connected
    }
}

#endif
