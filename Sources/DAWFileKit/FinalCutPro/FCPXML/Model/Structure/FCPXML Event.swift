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
    public struct Event: FCPXMLElement {
        public let element: XMLElement
        public let elementName: String = "event"
        
        // Element-Specific Attributes
        
        public var name: String {
            get { element.fcpName ?? "" }
            set { element.fcpName = newValue }
        }
        
        public var uid: String? {
            get { element.fcpUID }
            set { element.fcpUID = newValue }
        }
        
        // Children
        
        /// Returns child `project` elements.
        public var projects: LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>> {
            element
                .childElements
                .filter(whereElementType: .structure(.project))
        }
        
        /// Returns child story elements.
        public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpStoryElements
        }
        
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

extension FinalCutPro.FCPXML.Event {
    public static let structureElementType: FinalCutPro.FCPXML.StructureElementType = .event
    
    public enum Attributes: String, XMLParsableAttributesKey {
        // Element-Specific Attributes
        case name
        case uid
    }
    
    // can contain one or more of any:
    //   clip | audition | mc-clip | ref-clip | sync-clip | asset-clip | project
    // can contain one or more of any DTD %collection_item:
    //   collection-folder | keyword-collection | smart-collection
}

extension XMLElement { // Event
    /// FCPXML: Returns the element wrapped in an ``FinalCutPro/FCPXML/Event`` model object.
    /// Call this on an `event` element only.
    public var fcpAsEvent: FinalCutPro.FCPXML.Event? {
        .init(element: self)
    }
}

#endif
