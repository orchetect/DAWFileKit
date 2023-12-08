//
//  FCPXML Caption.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Represents a closed caption.
    public struct Caption: FCPXMLElement { 
        public let element: XMLElement
        
        // Element-Specific Attributes
        
        /// Role.
        public var role: CaptionRole? {
            get { element.fcpRole(as: CaptionRole.self) }
            set { element.fcpSet(role: newValue) }
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Caption: FCPXMLElementClipAttributes { }

extension FinalCutPro.FCPXML.Caption: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.Caption: FCPXMLElementTextChildren { }

extension FinalCutPro.FCPXML.Caption: FCPXMLElementTextStyleDefinitionChildren { }

extension FinalCutPro.FCPXML.Caption {
    public static let annotationType: FinalCutPro.FCPXML.AnnotationType = .caption
    
    public enum Attributes: String, XMLParsableAttributesKey {
        /// The format is `role-name?captionFormat=captionFormat.subrole`.
        /// ie: `iTT?captionFormat=ITT.en`.
        case role
        case note
        
        // Anchorable Attributes
        case lane
        case offset
        
        // Clip Attributes
        case name
        case start
        case duration
        case enabled // default true
    }
    
    public enum Children: String {
        case text
        case textStyleDef = "text-style-def"
    }
    
    // contains `text` elements
    // contains `text-style-def` elements
}

extension XMLElement { // Caption
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Caption`` model object.
    /// Call this on a `caption` element only.
    public var fcpAsCaption: FinalCutPro.FCPXML.Caption {
        .init(element: self)
    }
}

#endif
