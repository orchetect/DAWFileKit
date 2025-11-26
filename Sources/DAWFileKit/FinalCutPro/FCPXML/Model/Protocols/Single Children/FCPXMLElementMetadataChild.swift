//
//  FCPXMLElementMetadataChild.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore

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
