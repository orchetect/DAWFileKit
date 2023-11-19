//
//  XMLParsableAttributesKey.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

public protocol XMLParsableAttributesKey: Hashable, RawRepresentable, CaseIterable
where RawValue == String { }

extension XMLElement {
    /// Utility:
    /// Parse an XML element's attributes and return a key-value dictionary,
    /// parsing only the keys contained in the `key` type passed.
    /// Any missing keys will simply be omitted from the returned dictionary.
    public func parseAttributesRawValues<K>(
        key: K.Type
    ) -> [K: String] where K: XMLParsableAttributesKey {
        K.allCases.reduce(into: [:]) { dict, key in
            dict[key] = attributeStringValue(forName: key.rawValue)
        }
    }
}

#endif
