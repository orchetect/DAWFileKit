//
//  FCPXMLExtractedElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

/// Protocol for extracted elements that adds contextual properties.
public protocol FCPXMLExtractedElement where Self: Sendable {
    /// The extracted XML element.
    var element: XMLElement { get }
    
    /// XML breadcrumbs that were followed during the extraction process.
    ///
    /// This provides necessary element traversal history needed to infer context values
    /// that cannot be provided from the XML document layout.
    var breadcrumbs: [XMLElement] { get }
    
    /// Resources. If `nil`, resources will be acquired from the XML document.
    var resources: XMLElement? { get }
    
    /// Return the a context value for the element.
    func value<Value>(
        forContext contextKey: FinalCutPro.FCPXML.ElementContext<Value>
    ) -> Value
}

// MARK: - Convenience Properties

extension FCPXMLExtractedElement {
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
            autoScale: true,
            breadcrumbs: breadcrumbs,
            resources: resources
        )
    }
}

// MARK: - Sequence Methods

extension Sequence where Element: FCPXMLExtractedElement {
    /// Sort collection by absolute start timecode.
    public func sortedByAbsoluteStartTimecode() -> [Element] {
        sorted { lhs, rhs in
            guard let lhsTimecode = lhs.timecode(),
                  let rhsTimecode = rhs.timecode()
            else {
                // sort by `start` attribute as fallback
                return lhs.element.fcpStart ?? .zero < rhs.element.fcpStart ?? .zero
            }
            return lhsTimecode < rhsTimecode
        }
    }
    
    /// Sort collection by element `name`.
    /// If no `name` attribute exists, the `value` attribute will be used.
    public func sortedByName() -> [Element] {
        sorted { lhs, rhs in
            if let lhsName = lhs.element.fcpName,
               let rhsName = rhs.element.fcpName
            {
                return lhsName.localizedStandardCompare(rhsName) == .orderedAscending
            }
            if let lhsValue = lhs.element.fcpValue,
               let rhsValue = rhs.element.fcpValue
            {
                return lhsValue.localizedStandardCompare(rhsValue) == .orderedAscending
            }
            return true
        }
    }
}

#endif
