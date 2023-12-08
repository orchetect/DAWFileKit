//
//  FCPXML Project.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import CoreMedia
import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Project element.
    public struct Project: FCPXMLElement {
        public let element: XMLElement
        
        // Element-Specific Attributes
        
        public var name: String? {
            get { element.fcpName }
            set { element.fcpName = newValue }
        }
        
        public var id: String? {
            get { element.fcpID }
            set { element.fcpID = newValue }
        }
        
        public var uid: String? {
            get { element.fcpUID }
            set { element.fcpUID = newValue }
        }
        
        // Children
        
        public var sequence: XMLElement? {
            get { element.firstChildElement(named: Children.sequence.rawValue) }
            set {
                if let sequence = sequence, let newValue = newValue {
                    sequence.detach()
                    element.addChild(newValue)
                }
            }
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Project: FCPXMLElementOptionalModDate { }

extension FinalCutPro.FCPXML.Project {
    public static let structureElementType: FinalCutPro.FCPXML.StructureElementType = .project
    
    public enum Attributes: String, XMLParsableAttributesKey {
        // Element-Specific Attributes
        case name
        case id
        case uid
        case modDate
    }
    
    public enum Children: String {
        case sequence
    }
}

extension XMLElement { // Project
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Project`` model object.
    /// Call this on a `project` element only.
    public var fcpAsProject: FinalCutPro.FCPXML.Project {
        .init(element: self)
    }
}

extension FinalCutPro.FCPXML.Project {
    /// Convenience:
    /// Returns the start timecode of the `sequence` contained within the project.
    public var startTimecode: Timecode? {
        sequence?.fcpAsSequence.tcStartAsTimecode
    }
}

#endif
