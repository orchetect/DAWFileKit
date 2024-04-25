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
        
        public let elementType: ElementType = .keyword
        
        public static let supportedElementTypes: Set<ElementType> = [.keyword]
        
        public init() {
            element = XMLElement(name: elementType.rawValue)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementTypeSupported(element: element) else { return nil }
        }
    }
}

// MARK: - Parameterized init

extension FinalCutPro.FCPXML.Keyword {
    public init(
        keywords: [String],
        start: Fraction,
        duration: Fraction? = nil,
        note: String? = nil
    ) {
        self.init()
        
        self.keywords = keywords
        self.start = start
        self.duration = duration
        self.note = note
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Keyword {
    public enum Attributes: String {
        // Element-Specific Attributes
        case start
        case duration
        case value // comma-separated list of keywords, required
        case note
    }
    
    // no children
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Keyword {
    /// Keywords.
    /// Internally this is stored in the XML as a comma-separated list.
    public var keywords: [String] {
        get {
            element.fcpValue?
                .split(separator: ",")
                .map { String($0) }
            ?? []
        }
        set {
            if newValue.isEmpty {
                element.fcpValue = nil
            } else {
                element.fcpValue = newValue.joined(separator: ",")
            }
        }
    }
    
    /// Optional note.
    public var note: String? {
        get { element.fcpNote }
        set { element.fcpNote = newValue }
    }
}

extension FinalCutPro.FCPXML.Keyword: FCPXMLElementRequiredStart { }

extension FinalCutPro.FCPXML.Keyword: FCPXMLElementOptionalDuration { }

// MARK: - Typing

// Keyword
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Keyword`` model object.
    /// Call this on a `keyword` element only.
    public var fcpAsKeyword: FinalCutPro.FCPXML.Keyword? {
        .init(element: self)
    }
}

#endif
