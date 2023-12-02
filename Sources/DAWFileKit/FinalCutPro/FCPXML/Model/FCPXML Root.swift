//
//  FCPXML.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

// MARK: - root/*

extension FinalCutPro.FCPXML {
    public enum RootChildren: String {
        case fcpxml
    }
}

// MARK: - root/fcpxml/*

extension FinalCutPro.FCPXML {
    public enum Attributes: String {
        case version
    }
    
    public enum Children: String {
        case resources // structure element
        case library // structure element
        case event // structure element
        case project // structure element
        
        // AFAIK it's possible to have clips here too
    }
}

extension FinalCutPro.FCPXML {
    /// Utility:
    /// Returns the root `fcpxml` XML element if it exists.
    public var fcpxmlElement: XMLElement? {
        xml.childElements
            .first(whereElementNamed: RootChildren.fcpxml.rawValue)
    }
    
    /// Utility:
    /// Returns the `fcpxml/resources` XML element if it exists.
    /// Exactly one of these elements is always required, regardless of the version of the FCPXML.
    public var resourcesElement: XMLElement? {
        fcpxmlElement?.firstChildElement(named: Children.resources.rawValue)
    }
    
    /// Utility:
    /// Returns the `fcpxml/library` XML element if it exists.
    /// One or zero of these elements may be present within the `fcpxml` element.
    public var libraryElement: XMLElement? {
        fcpxmlElement?.firstChildElement(named: Children.library.rawValue)
    }
}

#endif
