//
//  FCPXMLElementMetadataChild.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftTimecodeCore

public protocol FCPXMLElementMetadataChild: FCPXMLElement {
    /// Metadata for the element.
    var metadata: FinalCutPro.FCPXML.Metadata? { get nonmutating set }
}

extension FCPXMLElementMetadataChild {
    public var metadata: FinalCutPro.FCPXML.Metadata? {
        get { element.firstChild(whereFCPElement: .metadata) }
        nonmutating set { element._updateChildElements(ofType: .metadata, withChild: newValue) }
    }
}

#endif
