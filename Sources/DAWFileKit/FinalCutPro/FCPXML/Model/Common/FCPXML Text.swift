//
//  FCPXML Text.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

extension FinalCutPro.FCPXML {
    /// Text element.
    public struct Text: Equatable, Hashable {
        public let element: XMLElement
        
        /// For a CEA-608 caption text block.
        public var displayStyle: DisplayStyle? { // used only with `text`
            get {
                guard let value = element.stringValue(forAttributeNamed: Attributes.displayStyle.rawValue)
                else { return nil }
                
                return DisplayStyle(rawValue: value)
            }
            set {
                element.addAttribute(withName: Attributes.displayStyle.rawValue, value: newValue?.rawValue)
            }
        }
        
        /// For a CEA-608 caption text block with roll-up animation.
        public var rollUpHeight: String?
        
        /// For a CEA-608 caption text block, as "x y".
        public var position: String? {
            get { element.fcpPosition }
            set { element.fcpPosition = newValue }
        }
        
        /// For a ITT caption text block.
        public var placement: Placement? { // used only with `text`
            get {
                guard let value = element.stringValue(forAttributeNamed: Attributes.placement.rawValue)
                else { return nil }
                
                return Placement(rawValue: value)
            }
            set {
                element.addAttribute(withName: Attributes.placement.rawValue, value: newValue?.rawValue)
            }
        }
        
        /// For a CEA-608 caption text block.
        public var alignment: Alignment? { // used only with `text`
            get {
                guard let value = element.stringValue(forAttributeNamed: Attributes.alignment.rawValue)
                else { return nil }
                
                return Alignment(rawValue: value)
            }
            set {
                element.addAttribute(withName: Attributes.alignment.rawValue, value: newValue?.rawValue)
            }
        }
        
        // Children
        
        /// Returns child `text-style` elements.
        public var textStrings: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpTextStyles
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Text {
    public enum Element: String {
        case name = "text"
    }
    
    public enum Attributes: String, XMLParsableAttributesKey {
        /// For a CEA-608 caption text block.
        case displayStyle = "display-style"
        
        /// For a CEA-608 caption text block with roll-up animation.
        case rollUpHeight = "roll-up-height"
        
        /// For a CEA-608 caption text block, as "x y".
        case position
        
        /// For a ITT caption text block.
        case placement
        
        /// For a CEA-608 caption text block.
        case alignment
    }
    
    public enum Children: String {
        case textStyle = "text-style"
    }
}

extension XMLElement {
    /// Returns child `text-style` elements.
    /// Use on `text` elements.
    public var fcpTextStyles: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter(whereElementNamed: FinalCutPro.FCPXML.Text.Children.textStyle.rawValue)
    }
}

// MARK: - Text Attribute: DisplayStyle

extension FinalCutPro.FCPXML.Text {
    /// For a CEA-608 caption text block.
    public enum DisplayStyle: String, Equatable, Hashable, CaseIterable, Sendable {
        case popOn = "pop-on"
        case paintOn = "paint-on"
        case rollUp = "roll-up"
    }
}

// MARK: - Text Attribute: Placement

extension FinalCutPro.FCPXML.Text {
    /// For a ITT caption text block.
    public enum Placement: String, Equatable, Hashable, CaseIterable, Sendable {
        case left, right, top, bottom
    }
}

// MARK: - Text Attribute: Alignment

extension FinalCutPro.FCPXML.Text {
    /// For a CEA-608 caption text block.
    public enum Alignment: String, Equatable, Hashable, CaseIterable, Sendable {
        case left, center, right
    }
}

// MARK: - Text Child: TextString

extension FinalCutPro.FCPXML.Text {
    public struct TextString: Equatable, Hashable {
        public let element: XMLElement
        
        public var ref: String? {
            get { element.fcpRef }
            set { element.fcpRef = newValue }
        }
        
        public var string: String? {
            get { element.stringValue }
            set { element.stringValue = newValue }
        }
        
        // TODO: parse potential additional attributes
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Text.TextString {
    public enum Attributes: String, XMLParsableAttributesKey {
        case ref // optional
    }
}

extension XMLElement {
    /// Get or set the value of the `position` attribute.
    /// Use on `text` element for a CEA-608 caption, or an `adjust-transform` element.
    public var fcpPosition: String? {
        get { stringValue(forAttributeNamed: "position") }
        set { addAttribute(withName: "position", value: newValue) }
    }
}

#endif
