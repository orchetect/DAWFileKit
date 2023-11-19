//
//  XML Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore

// MARK: Generic XML Utilities

extension XMLElement {
    var parentXMLElement: XMLElement? {
        parent as? XMLElement
    }
    
    /// Returns the first immediate child whose element name matches the given string.
    func first(childNamed name: String) -> XMLElement? {
        children?.first(where: { $0.name == name }) as? XMLElement
    }
}

// MARK: Ancestor Triage

extension XMLElement {
    /// Returns the first non-nil value for the given attribute name,
    /// starting from the current XML element, then successively traversing ancestors.
    func attributeStringValueTraversingAncestors(
        forName name: String,
        skippingWhere skipPredicate: ((_ element: XMLElement) -> Bool)? = nil
    ) -> (value: String, inElement: XMLElement)? {
        if !(skipPredicate?(self) ?? false) {
            if let value = attributeStringValue(forName: name) {
                return (value: value, inElement: self)
            }
        }
        
        // recursively traverse ancestors
        if let parent = parentXMLElement {
            return parent.attributeStringValueTraversingAncestors(
                forName: name,
                skippingWhere: skipPredicate
            )
        }
        
        // no attribute found in any parents
        return nil
    }
    
    /// Starting with the current XML element's parent, traverse ancestors and return
    /// the first ancestor whose element name matches the given string.
    func firstAncestor(named name: String) -> XMLElement? {
        // recursively traverse ancestors
        guard let parent = parent as? XMLElement else {
            return nil
        }
        if parent.name == name { return parent }
        
        // recursively traverse ancestors
        return parent.firstAncestor(named: name)
    }
    
    /// Starting with the current XML element's parent, traverse ancestors and return
    /// the first ancestor whose element name matches any of the given strings.
    func firstAncestor(named names: [String]) -> XMLElement? {
        // recursively traverse ancestors
        guard let parent = parent as? XMLElement else {
            return nil
        }
        if let parentName = parent.name, names.contains(parentName) { return parent }
        
        // recursively traverse ancestors
        return parent.firstAncestor(named: names)
    }
    
    /// Starting with the current XML element's parent, traverse ancestors and return
    /// the first ancestor which contains an attribute with the given name.
    func firstAncestor(withAttribute name: String) -> XMLElement? {
        // recursively traverse ancestors
        guard let parent = parent as? XMLElement else {
            return nil
        }
        
        if parent.attribute(forName: name) != nil { return parent }
        
        // recursively traverse ancestors
        return parent.firstAncestor(withAttribute: name)
    }
}

// MARK: Ancestor Walking

extension XMLElement {
    func walkAncestors(
        includingSelf: Bool,
        _ block: (_ element: XMLElement) -> Bool
    ) {
        let block: (_ element: XMLElement) -> WalkAncestorsIntermediateResult<Void> = { element in
            if block(element) {
                return .continue
            } else {
                return .return(withValue: ())
            }
        }
        _ = Self.walkAncestors(
            startingWith: includingSelf ? self : parentXMLElement,
            returning: Void.self,
            block
        )
    }
    
    func walkAncestors<T>(
        includingSelf: Bool,
        returning: T.Type,
        _ block: (_ element: XMLElement) -> WalkAncestorsIntermediateResult<T>
    ) -> WalkAncestorsResult<T> {
        Self.walkAncestors(
            startingWith: includingSelf ? self : parentXMLElement,
            returning: returning,
            block
        )
    }
    
    private static func walkAncestors<T>(
        startingWith element: XMLElement?,
        returning: T.Type,
        _ block: (_ element: XMLElement) -> WalkAncestorsIntermediateResult<T>
    ) -> WalkAncestorsResult<T> {
        guard let element = element else { return .exhaustedAncestors }
        
        let blockResult = block(element)
        
        switch blockResult {
        case .continue:
            guard let parent = element.parentXMLElement else {
                return .exhaustedAncestors
            }
            return walkAncestors(startingWith: parent, returning: returning, block)
        case .return(let value):
            return .value(value)
        case .failure:
            return .failure
        }
    }
    
    enum WalkAncestorsIntermediateResult<T> {
        case `continue`
        case `return`(withValue: T)
        case failure
    }
    
    enum WalkAncestorsResult<T> {
        case exhaustedAncestors
        case value(_ value: T)
        case failure
    }
}

#endif
