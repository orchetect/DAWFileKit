//
//  FCPXML Text.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public struct Text: Equatable, Hashable {
        public var rollUpHeight: String?
        public var position: String?
        public var placement: String?
        public var alignment: String?
        public var textStrings: [TextString]
        
        public init(
            rollUpHeight: String? = nil,
            position: String? = nil,
            placement: String? = nil,
            alignment: String? = nil,
            textStrings: [TextString]
        ) {
            self.rollUpHeight = rollUpHeight
            self.position = position
            self.placement = placement
            self.alignment = alignment
            self.textStrings = textStrings
        }
    }
}

extension FinalCutPro.FCPXML.Text {
    public enum Element: String {
        case name = "text"
    }
    
    /// Attributes unique to ``Text``.
    public enum Attributes: String, XMLParsableAttributesKey {
        case displayStyle = "display-style"
        case rollUpHeight = "roll-up-height"
        case position
        case placement
        case alignment
    }
    
    /// Children of ``Text``.
    public enum Children: String {
        case textStyle = "text-style"
    }
    
    public init?(from xmlLeaf: XMLElement) {
        // validate element name
        guard xmlLeaf.name == Element.name.rawValue else { return nil }
        
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        rollUpHeight = rawValues[.rollUpHeight]
        position = rawValues[.position]
        placement = rawValues[.placement]
        alignment = rawValues[.alignment]
        
        textStrings = Self.parseTextStyles(from: xmlLeaf)
    }
    
    static func parseTextStyles(from xmlLeaf: XMLElement) -> [TextString] {
        (xmlLeaf.children ?? [])
            .filter { $0.name == Children.textStyle.rawValue }
            .compactMap { $0 as? XMLElement }
            .compactMap { TextString(from: $0) }
    }
}

extension FinalCutPro.FCPXML.Text {
    public struct TextString: Equatable, Hashable {
        public var ref: String?
        public var string: String
        
        // TODO: parse potential additional attributes
        
        public init(ref: String? = nil, string: String) {
            self.ref = ref
            self.string = string
        }
    }
}

extension FinalCutPro.FCPXML.Text.TextString {
    /// Attributes unique to ``Text``.
    public enum Attributes: String, XMLParsableAttributesKey {
        case ref
    }
    
    public init?(from xmlLeaf: XMLElement) {
        // validate element name
        guard xmlLeaf.name == FinalCutPro.FCPXML.Text.Children.textStyle.rawValue else { return nil }
        
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        ref = rawValues[.ref]
        
        // caption text is the string value of the element, not an attribute
        string = xmlLeaf.stringValue ?? ""
    }
}

#endif
