//
//  FCPXML Project.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import CoreMedia
import Foundation

extension FinalCutPro.FCPXML {
    /// Project element.
    public struct Project: Equatable, Hashable {
        public let element: XMLElement
        
        public var name: String {
            get { element.fcpName ?? "" }
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
        
        public var sequence: XMLElement? {
            get { element.firstChildElement(named: Attributes.sequence.rawValue) }
            set {
                if let sequence = sequence, let newValue = newValue {
                    sequence.detach()
                    element.addChild(newValue)
                }
            }
        }
        
        // TODO: add modDate
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Project {
    public static let structureElementType: FinalCutPro.FCPXML.StructureElementType = .project
    
    public enum Attributes: String, XMLParsableAttributesKey {
        case name
        case id
        case uid
        case modDate
        case sequence
    }
}

#endif
