//
//  FCPXMLElementContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

public protocol FCPXMLElementContext {
    var context: FinalCutPro.FCPXML.ElementContext { get }
}

#endif
