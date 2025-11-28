//
//  FCPXML Root Parsing.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions
import SwiftTimecodeCore

extension XMLElement {
    /// FCPXML: Returns the root-level `fcpxml` element.
    /// This may be called on any element within a FCPXML.
    public var fcpRoot: XMLElement? {
        rootDocument?
            .rootElement() // `fcpxml` element
    }
}

#endif
