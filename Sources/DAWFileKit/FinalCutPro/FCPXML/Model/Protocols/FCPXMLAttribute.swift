//
//  FCPXMLAttribute.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

public protocol FCPXMLAttribute {
    /// The XML attribute name.
    static var attributeName: String { get }
}

#endif
