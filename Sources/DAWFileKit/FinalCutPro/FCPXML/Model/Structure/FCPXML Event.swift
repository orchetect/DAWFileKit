//
//  FCPXML Event.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

extension FinalCutPro.FCPXML {
    /// Represent a single event in a library.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > An event may contain clips as story elements and projects, along with keyword collections
    /// > and smart collections. The keyword-collection and smart-collection elements organize clips
    /// > by keywords and other matching criteria listed under the Smart Collection Match Elements.
    public struct Event: Equatable, Hashable {
        public let element: XMLElement
        
        public var name: String {
            get { element.fcpName ?? "" }
            set { element.fcpName = newValue }
        }
        
        public var uid: String? {
            get { element.fcpUID }
            set { element.fcpUID = newValue }
        }
        
        /// Returns all child elements.
        public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
            element.childElements
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Event {
    public var structureElementType: FinalCutPro.FCPXML.StructureElementType {
        .event
    }
    
    public enum Attributes: String, XMLParsableAttributesKey {
        case name
        case uid
    }
    
    // contains projects
    // contains clips
    // contains collection folders
    // contains keyword collections
    // contains smart collections
}

extension XMLElement { // Event
    /// Returns the element wrapped in an ``/FinalCutPro/FCPXML/Event`` model object.
    /// Call this on an `event` element only.
    public var asEvent: FinalCutPro.FCPXML.Event {
        .init(element: self)
    }
}
#endif
