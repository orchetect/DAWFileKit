//
//  XML Utilities.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions

// TODO: forced Sendable conformance
extension XMLElement: @retroactive @unchecked Sendable { }

// MARK: - Ancestor Walking

// TODO: remove or refactor?

extension XMLElement {
    /// Utility:
    /// Walk ancestors of the element.
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
    
    /// Utility:
    /// Walk ancestors of the element.
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
    
    /// Utility Helper:
    /// Walk ancestors of the element.
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

extension XMLElement {
    /// Utility:
    /// Returns ancestor elements beginning from closest ancestor.
    /// If `replacement` is non-nil it will be used instead of the element's ancestors.
    /// 
    /// - Parameters:
    ///   - replacement: Optional replacement for ancestors. Ordered nearest to furthest ancestor.
    ///   - includingSelf: Include `self` as the first ancestor.
    /// - Returns: Sequence of ancestors, optionally including `self`.
    func ancestorElements<S: Sequence<XMLElement>>(
        overrideWith replacement: S?,
        includingSelf: Bool
    ) -> AnySequence<XMLElement> {
        if let replacement = replacement {
            if includingSelf {
                return ([self] + replacement).asAnySequence
            } else {
                return replacement.asAnySequence
            }
        } else {
            return ancestorElements(includingSelf: includingSelf).asAnySequence
        }
    }
}

#endif
