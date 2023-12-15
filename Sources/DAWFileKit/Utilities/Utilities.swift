//
//  Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

@propertyWrapper
public struct EquatableExempt<Value>: Equatable {
    public var wrappedValue: Value
    
    public static func == (lhs: EquatableExempt<Value>, 
                           rhs: EquatableExempt<Value>) -> Bool {
        true
    }
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
public struct EquatableAndHashableExempt<Value>: Equatable, Hashable {
    public var wrappedValue: Value
    
    public static func == (lhs: EquatableAndHashableExempt<Value>, 
                           rhs: EquatableAndHashableExempt<Value>) -> Bool {
        true
    }
    
    public func hash(into hasher: inout Hasher) { }
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension Sequence {
    /// Wraps the sequence in a `AnySequence` instance.
    var asAnySequence: AnySequence<Element> {
        AnySequence(self)
    }
}
