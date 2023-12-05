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
    public struct Caption: Equatable, Hashable { 
        public let element: XMLElement
        
        public var note: String? {
            get { element.fcpNote }
            set { element.fcpNote = newValue }
        }
        
        public var texts: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpTexts()
        }
        
        public var textStyleDefinitions: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpTextStyleDefinitions()
        }
        
        // Anchorable Attributes
        
        public var lane: Int? {
            get { element.fcpLane }
            set { element.fcpLane = newValue }
        }
        
        public var offset: Fraction? {
            get { element.fcpOffset }
            set { element.fcpOffset = newValue }
        }
        
        // Clip Attributes
        
        public var name: String {
            get { element.fcpName ?? "" }
            set { element.fcpName = newValue }
        }
        
        public var start: Fraction? {
            get { element.fcpStart }
            set { element.fcpStart = newValue }
        }
        
        public var duration: Fraction? {
            get { element.fcpDuration }
            set { element.fcpDuration = newValue }
        }
        
        public var enabled: Bool {
            get { element.fcpEnabled ?? true }
            set { element.fcpEnabled = newValue }
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

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
    /// Returns the element wrapped in a ``FinalCutPro/FCPXML/Caption`` model object.
    /// Call this on a `caption` element only.
    public var fcpAsCaption: FinalCutPro.FCPXML.Caption {
        .init(element: self)
    }
}

extension XMLElement { // Caption
    /// Returns child `text` elements.
    public func fcpTexts() -> LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter(whereElementNamed: FinalCutPro.FCPXML.Caption.Children.text.rawValue)
    }
    
    /// Returns child `text-style-def` elements.
    public func fcpTextStyleDefinitions() -> LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter(whereElementNamed: FinalCutPro.FCPXML.Caption.Children.textStyleDef.rawValue)
    }
}

#endif
