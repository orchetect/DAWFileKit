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
    public struct Keyword: Equatable, Hashable {
        public let element: XMLElement
        
        public var start: Fraction {
            get { element.fcpStart ?? .zero }
            set { element.fcpStart = newValue }
        }
        
        public var duration: Fraction? {
            get { element.fcpDuration }
            set { element.fcpDuration = newValue }
        }
        
        public var name: String {
            get { element.fcpValue ?? "" }
            set { element.fcpValue = newValue }
        }
        
        public var note: String? {
            get { element.fcpNote }
            set { element.fcpNote = newValue }
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Keyword {
    public static let annotationType: FinalCutPro.FCPXML.AnnotationType = .keyword
    
    public enum Attributes: String, XMLParsableAttributesKey {
        case value // the keyword name
        case start
        case duration
        case note
    }
}

extension XMLElement { // Keyword
    /// Returns the element wrapped in a ``FinalCutPro/FCPXML/Keyword`` model object.
    /// Call this on a `keyword` element only.
    public var fcpAsKeyword: FinalCutPro.FCPXML.Keyword {
        .init(element: self)
    }
}

#endif
