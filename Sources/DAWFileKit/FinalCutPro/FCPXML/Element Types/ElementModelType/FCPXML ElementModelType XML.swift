//
//  FCPXML ElementModelType XML.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions

// MARK: - Typealiases

public typealias LazyFCPXMLChildrenSequence<Model: FCPXMLElement> = LazyCompactMapSequence<
    LazyCompactMapSequence<[XMLNode], XMLElement>, Model
>

// MARK: - Sequence First (Strongly-Typed)

extension Sequence where Element == XMLElement {
    /// FCPXML: Returns the first element with the given concrete element type.
    public func first<Model: FCPXMLElement>(
        whereFCPElement concreteModelType: Model.Type
    ) -> Model? {
        self.lazy.first(whereFCPElement: concreteModelType)
    }
    
    /// FCPXML: Returns the first element with the given element type.
    public func first<Model>(
        whereFCPElement elementType: FinalCutPro.FCPXML.ElementModelType<Model>
    ) -> Model? {
        self.lazy.first(whereFCPElement: elementType)
    }
}

// MARK: - LazySequence First (Strongly-Typed)

extension LazySequence where Element == XMLElement {
    /// FCPXML: Returns the first element with the given concrete element type.
    public func first<Model: FCPXMLElement>(
        whereFCPElement concreteModelType: Model.Type
    ) -> Model? {
        compactMap { Model(element: $0) }.first
    }
    
    /// FCPXML: Returns the first element with the given element type.
    public func first<Model>(
        whereFCPElement elementType: FinalCutPro.FCPXML.ElementModelType<Model>
    ) -> Model? {
        compactMap { Model(element: $0) }.first
    }
}

// MARK: - Sequence Filter (Strongly-Typed)

extension Sequence where Element == XMLElement {
    /// FCPXML: Filter the element sequence by a specific concrete FCPXML model type.
    public func filter<Model: FCPXMLElement>(
        whereFCPElement concreteModelType: Model.Type
    ) -> LazyCompactMapSequence<LazySequence<Self>.Elements, Model> {
        self.lazy.compactMap { Model(element: $0) }
    }
    
    /// FCPXML: Filter the element sequence by a specific concrete FCPXML model type.
    public func filter<Model>(
        whereFCPElement elementType: FinalCutPro.FCPXML.ElementModelType<Model>
    ) -> LazyCompactMapSequence<LazySequence<Self>.Elements, Model> {
        self.lazy.compactMap { Model(element: $0) }
    }
}

// MARK: - LazySequence Filter (Strongly-Typed)

extension LazySequence where Element == XMLElement {
    /// FCPXML: Filter the element sequence by a specific concrete FCPXML model type.
    public func filter<Model: FCPXMLElement>(
        whereFCPElement concreteModelType: Model.Type
    ) -> LazyCompactMapSequence<Base, Model?> {
        compactMap { Model(element: $0) }
    }
    
    /// FCPXML: Filter the element sequence by a specific concrete FCPXML model type.
    public func filter<Model>(
        whereFCPElement modelType: FinalCutPro.FCPXML.ElementModelType<Model>
    ) -> LazyCompactMapSequence<Base, Model?> {
        compactMap { Model(element: $0) }
    }
}

// MARK: - Children (Strongly-Typed)

extension XMLElement {
    /// FCPXML: Returns child elements of the given type wrapped in a concrete model object.
    public func children<Model: FCPXMLElement>(
        whereFCPElement concreteModelType: Model.Type
    ) -> LazyFCPXMLChildrenSequence<Model> {
        childElements
            .filter(whereFCPElement: concreteModelType)
    }
    
    /// FCPXML: Returns child elements of the given type wrapped in a model object.
    public func children<Model>(
        whereFCPElement modelType: FinalCutPro.FCPXML.ElementModelType<Model>
    ) -> LazyFCPXMLChildrenSequence<Model> {
        childElements
            .filter(whereFCPElement: modelType)
    }
    
    /// FCPXML: Returns the first child element of the given element type wrapped in a model object.
    public func firstChild<Model>(
        whereFCPElement modelType: FinalCutPro.FCPXML.ElementModelType<Model>
    ) -> Model? {
        childElements
            .first(whereFCPElement: modelType)
    }
    
    /// FCPXML: Returns the first child element of the given element type wrapped in a model object.
    /// If no matching child is found, the default is added as a child and returned.
    ///
    /// - Warning: Ensure the `defaultChild` is a new instance not already attached to any parent.
    public func firstChild<Model>(
        whereFCPElement modelType: FinalCutPro.FCPXML.ElementModelType<Model>,
        defaultChild: @autoclosure () -> Model
    ) -> Model {
        if let existingChild = childElements
            .first(whereFCPElement: modelType)
        {
            return existingChild
        } else {
            let dc = defaultChild()
            addChild(dc.element)
            return dc
        }
    }
}

#endif
