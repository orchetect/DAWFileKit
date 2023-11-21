//
//  FCPXML Text.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public struct Text: Equatable, Hashable {
        public var string: String
        public var rollUpHeight: String?
        public var position: String?
        public var placement: String?
        public var alignment: String?
        public var textStyles: [XMLElement]
    }
}

extension FinalCutPro.FCPXML.Text {
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
        case value = "" // TODO: ?
        case textStyle = "text-style"
    }
    
    public init?(from xmlLeaf: XMLElement) {
        // validate element name
        guard xmlLeaf.name == "text" else { return nil }
        
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        // caption text is the string value of the element, not an attribute
        string = xmlLeaf.stringValue ?? ""
        
        rollUpHeight = rawValues[.rollUpHeight]
        position = rawValues[.position]
        placement = rawValues[.placement]
        alignment = rawValues[.alignment]
        
        textStyles = Self.parseTextStyles(from: xmlLeaf)
    }
    
    // TODO: parse XML into strongly typed structs
    static func parseTextStyles(from xmlLeaf: XMLElement) -> [XMLElement] {
        (xmlLeaf.children ?? [])
            .filter { $0.name == Children.textStyle.rawValue }
            .compactMap { $0 as? XMLElement }
    }
}

#endif
