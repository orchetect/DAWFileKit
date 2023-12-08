//
//  FCPXMLElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

public protocol FCPXMLElement where Self: Equatable, Self: Hashable {
    /// The wrapped XML element.
    var element: XMLElement { get }
}

extension FCPXMLElement /* : Equatable */ {
    public static func == <O: FCPXMLElement>(lhs: Self, rhs: O) -> Bool {
        lhs.element == rhs.element
    }
    
    public static func == (lhs: XMLElement, rhs: Self) -> Bool {
        lhs == rhs.element
    }
    
    public static func == (lhs: Self, rhs: XMLElement) -> Bool {
        lhs.element == rhs
    }
}

extension FCPXMLElement /* : Hashable */ {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(element)
    }
}

#endif
