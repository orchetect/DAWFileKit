//
//  FCPXMLExtractable.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
@_implementationOnly import OTCore

/// A FCPXML element that is capable of extracting its own contents as well as the contents of its
/// children, if any.
public protocol FCPXMLExtractable { // parent/container
    /// Extract elements from the element and optionally recursively from all sub-elements.
    /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
//    func extractElements<Element: _FCPXMLExtractableElement>(
//        settings: FinalCutPro.FCPXML.ExtractionSettings,
//        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
//    ) -> [FinalCutPro.FCPXML.ExtractedElement<Element>]
}

/// A FCPXML element that is capable of being extracted by a ``FCPXMLExtractable``-conforming parent
/// element.
public protocol FCPXMLExtractableElement { }

protocol _FCPXMLExtractableElement: FCPXMLExtractableElement {
    /// Proxy getter for ``FCPXMLExtractableElement``:
    /// Return the `start` attribute value, otherwise `nil`. (Note: not `tcStart`).
    var extractableStart: Timecode? { get }
    
    /// Proxy getter for ``FCPXMLExtractableElement``:
    /// Return the `name` attribute value, otherwise `nil`.
    var extractableName: String? { get }
}

extension FinalCutPro.FCPXML {
    /// Contains an extracted element along with pertinent contextual metadata.
    public struct ExtractedElement<Element: FCPXMLExtractableElement> {
        public var element: Element
        public var context: ElementContext
    }
}

#endif
