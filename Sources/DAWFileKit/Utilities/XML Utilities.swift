//
//  XML Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore

// MARK: Ancestor Walking

extension XMLElement {
    func walkAncestorElements(
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
        _ = Self.walkAncestorElements(
            startingWith: includingSelf ? self : parentElement,
            returning: Void.self,
            block
        )
    }
    
    func walkAncestorElements<T>(
        includingSelf: Bool,
        returning: T.Type,
        _ block: (_ element: XMLElement) -> WalkAncestorsIntermediateResult<T>
    ) -> WalkAncestorsResult<T> {
        Self.walkAncestorElements(
            startingWith: includingSelf ? self : parentElement,
            returning: returning,
            block
        )
    }
    
    private static func walkAncestorElements<T>(
        startingWith element: XMLElement?,
        returning: T.Type,
        _ block: (_ element: XMLElement) -> WalkAncestorsIntermediateResult<T>
    ) -> WalkAncestorsResult<T> {
        guard let element = element else { return .exhaustedAncestors }
        
        let blockResult = block(element)
        
        switch blockResult {
        case .continue:
            guard let parent = element.parentElement else {
                return .exhaustedAncestors
            }
            return walkAncestorElements(startingWith: parent, returning: returning, block)
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
