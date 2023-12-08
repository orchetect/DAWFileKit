//
//  FCPXML Keyword.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Represents a keyword.
    public struct Keyword: FCPXMLElement {
        public let element: XMLElement
        public let elementName: String = "keyword"
        
        // Element-Specific Attributes
        
        /// Comma-separated list of keywords.
        public var keywords: String {
            get { element.fcpValue ?? "" }
            set { element.fcpValue = newValue }
        }
        
        /// Optional note.
        public var note: String? {
            get { element.fcpNote }
            set { element.fcpNote = newValue }
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

extension FinalCutPro.FCPXML.Keyword: FCPXMLElementRequiredStart { }

extension FinalCutPro.FCPXML.Keyword: FCPXMLElementOptionalDuration { }

extension FinalCutPro.FCPXML.Keyword {
    public static let annotationType: FinalCutPro.FCPXML.AnnotationType = .keyword
    
    public enum Attributes: String, XMLParsableAttributesKey {
        // Element-Specific Attributes
        case start
        case duration
        case value // comma-separated list of keywords, required
        case note
    }
}

extension XMLElement { // Keyword
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Keyword`` model object.
    /// Call this on a `keyword` element only.
    public var fcpAsKeyword: FinalCutPro.FCPXML.Keyword? {
        .init(element: self)
    }
}

#endif
