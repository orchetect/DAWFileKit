//
//  FCPXML ExtractedElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

extension FinalCutPro.FCPXML {
    /// Extracted element and its context.
    public struct ExtractedElement {
        public var element: XMLElement
        public var breadcrumbs: [XMLElement]
        var resources: XMLElement?
        
        init(
            element: XMLElement,
            breadcrumbs: [XMLElement],
            resources: XMLElement?
        ) {
            self.element = element
            self.breadcrumbs = breadcrumbs
            self.resources = resources
        }
        
        public func value<Value>(forContext contextKey: ElementContext<Value>) -> Value {
            contextKey.value(from: element, breadcrumbs: breadcrumbs, resources: resources)
        }
    }
}

#endif
