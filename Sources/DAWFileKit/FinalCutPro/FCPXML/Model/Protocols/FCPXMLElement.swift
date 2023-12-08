//
//  FCPXMLElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

public protocol FCPXMLElement where Self: Equatable, Self: Hashable {
    /// The wrapped XML element.
    var element: XMLElement { get }
}

#endif
