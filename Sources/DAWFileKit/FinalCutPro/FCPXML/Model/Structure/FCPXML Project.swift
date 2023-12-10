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
        
        public let elementType: ElementType = .project
        
        public static let supportedElementTypes: Set<ElementType> = [.project]
        
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

extension FinalCutPro.FCPXML.Project {
    public enum Attributes: String {
        // Element-Specific Attributes
        case name
        case id
        case uid
        case modDate
    }
    
    // must contain one sequence
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Project {
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
}

extension FinalCutPro.FCPXML.Project: FCPXMLElementOptionalModDate { }

// MARK: - Children

extension FinalCutPro.FCPXML.Project {
    /// Get or set the child `sequence` element. (Required)
    public var sequence: FinalCutPro.FCPXML.Sequence {
        get {
            if let seq = element.firstChild(whereFCPElement: .sequence) {
                return seq
            }
            
            // create new element and attach
            let newSequence = FinalCutPro.FCPXML.Sequence()
            element.addChild(newSequence.element)
            return newSequence
        }
        set {
            let current = sequence
            guard current.element != newValue.element else { return }
            current.element.detach()
            element.addChild(newValue.element)
        }
    }
}

// MARK: - Properties

extension FinalCutPro.FCPXML.Project {
    /// Convenience:
    /// Returns the start timecode of the `sequence` contained within the project.
    public var startTimecode: Timecode? {
        sequence.tcStartAsTimecode
    }
}

// MARK: - Typing

// Project
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Project`` model object.
    /// Call this on a `project` element only.
    public var fcpAsProject: FinalCutPro.FCPXML.Project? {
        .init(element: self)
    }
}

#endif
