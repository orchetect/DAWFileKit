//
//  FCPXML FoundationElementType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum FoundationElementType: String {
        /// Mandatory root-level XML element which all other elements exist.
        /// Exactly one of these elements is always required at the XML top level.
        case fcpxml
        
        /// Library.
        /// One or zero of these elements may be present within the `fcpxml` element.
        ///
        /// > Note: Starting in FCPXML 1.9, the elements that describe how to organize and use media
        /// > assets are optional. The only required element in the fcpxml root element is the
        /// > resources element.
        case library
        
        /// Contains descriptions of media assets and other resources.
        /// Exactly one of these elements is always required within the `fcpxml` element.
        case resources
    }
}

#endif
