//
//  FCPXMLElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

/// Protocol which all FCPXML wrapper model objects conform.
public protocol FCPXMLElement where Self: Equatable, Self: Hashable {
    /// The wrapped XML element object.
    var element: XMLElement { get }
    
    /// The FCPXML element type of the model instance.
    var elementType: FinalCutPro.FCPXML.ElementType { get }
    
    /// All FCPXML element types the model object is capable of handling.
    ///
    /// Most model objects only handle a single type.
    /// However some model objects are 'meta types' and can handle more than one, such as
    /// ``FinalCutPro/FCPXML/Marker`` which handles both `marker` and `chapter-marker`.
    static var supportedElementTypes: Set<FinalCutPro.FCPXML.ElementType> { get }
    
    /// Initialize a new empty element with defaults.
    init()
    
    /// Wrap a FCPXML element.
    /// Returns `nil` if the element does not match the model element type.
    init?(element: XMLElement)
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

// MARK: - Utilities

extension FCPXMLElement {
    func _isElementTypeSupported(element: XMLElement? = nil) -> Bool {
        let e = element ?? self.element
        guard let et = e.fcpElementType,
              Self.supportedElementTypes.contains(et)
        else { return false }
        return true
    }
}

#endif
