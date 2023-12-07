//
//  FCPXMLElementContextKey.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

// TODO: may not be needed after the refactor?

public protocol FCPXMLElementContextKey {
    associatedtype ValueType
    var key: String { get }
}

extension FinalCutPro.FCPXML {
    /// Wrapper for a dictionary key name that also contains strong type information about its
    /// expected value.
    public struct ContextKey<ValueType>: FCPXMLElementContextKey, Hashable {
        public let key: String
        
        public init(key: String) {
            self.key = key
        }
        
        public init(key: String, valueType: ValueType.Type) {
            self.key = key
        }
        
        public init<R: RawRepresentable>(key: R) where R.RawValue == String {
            self.key = key.rawValue
        }
    }
}

extension FinalCutPro.FCPXML.ElementContext {
    public subscript<ValueType>(_ key: FinalCutPro.FCPXML.ContextKey<ValueType>) -> ValueType? {
        get {
            value(for: key)
        }
        _modify {
            var val = value(for: key)
            yield &val
            self[key.key] = val
        }
        set {
            self[key.key] = newValue
        }
    }
    
    private func value<ValueType>(for key: FinalCutPro.FCPXML.ContextKey<ValueType>) -> ValueType? {
        self[key.key] as? ValueType
    }
}

#endif
