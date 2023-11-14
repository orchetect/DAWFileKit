//
//  XML Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore

extension XMLElement {
    /// Returns the first immediate child whose element name matches the given string.
    func first(childNamed name: String) -> XMLElement? {
        children?.first(where: { $0.name == name }) as? XMLElement
    }
    
    /// Returns the first non-nil value for the given attribute name,
    /// starting from the current XML element, then successively traversing ancestors.
    func attributeStringValueTraversingAncestors(forName name: String) -> String? {
        if let value = attributeStringValue(forName: name) {
            return value
        }
        
        // recursively traverse ancestors
        if let parent = parent as? XMLElement {
            return parent.attributeStringValueTraversingAncestors(forName: name)
        }
        
        // no attribute found in any parents
        return nil
    }
    
    /// Starting with the current XML element's parent, traverse ancestors and return
    /// the first ancestor whose element name matches the given string.
    func first(ancestorNamed name: String) -> XMLElement? {
        // recursively traverse ancestors
        guard let parent = parent as? XMLElement else {
            return nil
        }
        if parent.name == name { return parent }
        
        // recursively traverse ancestors
        return parent.first(ancestorNamed: name)
    }
}

#endif
