//
//  FCPXML ExtractedElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Extracted element and its context.
    public struct ExtractedElement {
        /// The extracted XML element.
        public var element: XMLElement
        
        /// XML breadcrumbs that were followed during the extraction process.
        ///
        /// This provides necessary element traversal history needed to infer context values
        /// that cannot be provided from the XML document layout.
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
        
        /// Return the a context value for the element.
        public func value<Value>(forContext contextKey: ElementContext<Value>) -> Value {
            contextKey.value(from: element, breadcrumbs: breadcrumbs, resources: resources)
        }
    }
}

extension FinalCutPro.FCPXML.ExtractedElement {
    /// Absolute timecode position within the outermost timeline.
    public func timecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .mainTimeline
    ) -> Timecode? {
        value(forContext: .absoluteStartAsTimecode(frameRateSource: frameRateSource))
    }
    
    /// Duration expressed as a length of timecode.
    public func duration(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .mainTimeline
    ) -> Timecode? {
        guard let duration = element.fcpDuration else { return nil }
        return try? element._fcpTimecode(
            fromRational: duration,
            frameRateSource: frameRateSource,
            breadcrumbs: breadcrumbs,
            resources: resources
        )
    }
}

#endif
