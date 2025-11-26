//
//  FCPXMLAttribute.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore

public protocol FCPXMLAttribute {
    /// The XML attribute name.
    static var attributeName: String { get }
}

#endif
