//
//  FCPXMLExtractionPreset.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

/// Protocol describing an element extraction preset for FCPXML.
public protocol FCPXMLExtractionPreset<Result> {
    associatedtype Result
    
    func perform(
        on extractable: XMLElement,
        scope: FinalCutPro.FCPXML.ExtractionScope
    ) -> Result
}

#endif
