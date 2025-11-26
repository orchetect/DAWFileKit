//
//  FCPXML Keyword.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore
import SwiftExtensions

extension FinalCutPro.FCPXML {
    /// Represents a keyword.
    public struct Keyword: FCPXMLElement {
        public let element: XMLElement
        
        public let elementType: ElementType = .keyword
        
        public static let supportedElementTypes: Set<ElementType> = [.keyword]
        
        public init() {
            element = XMLElement(name: elementType.rawValue)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementTypeSupported(element: element) else { return nil }
        }
    }
}

// MARK: - Parameterized init

extension FinalCutPro.FCPXML.Keyword {
    public init(
        keywords: [String],
        start: Fraction,
        duration: Fraction? = nil,
        note: String? = nil
    ) {
        self.init()
        
        self.keywords = keywords
        self.start = start
        self.duration = duration
        self.note = note
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Keyword {
    public enum Attributes: String {
        // Element-Specific Attributes
        case start
        case duration
        case value // comma-separated list of keywords, required
        case note
    }
    
    // no children
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Keyword {
    /// Keywords.
    /// Internally this is stored in the XML as a comma-separated list.
    public var keywords: [String] {
        get {
            element.fcpValue?
                .split(separator: ",")
                .map { String($0) }
            ?? []
        }
        nonmutating set {
            if newValue.isEmpty {
                element.fcpValue = nil
            } else {
                element.fcpValue = newValue.joined(separator: ",")
            }
        }
    }
    
    /// Optional note.
    public var note: String? {
        get { element.fcpNote }
        nonmutating set { element.fcpNote = newValue }
    }
}

extension FinalCutPro.FCPXML.Keyword: FCPXMLElementRequiredStart { }

extension FinalCutPro.FCPXML.Keyword: FCPXMLElementOptionalDuration { }

// MARK: - Typing

// Keyword
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Keyword`` model object.
    /// Call this on a `keyword` element only.
    public var fcpAsKeyword: FinalCutPro.FCPXML.Keyword? {
        .init(element: self)
    }
}

// MARK: - Helpers

extension FinalCutPro.FCPXML.Keyword {
    func absoluteRangeAsTimecode(
        breadcrumbs: [XMLElement]? = nil,
        resources: XMLElement? = nil
    ) -> ClosedRange<Timecode>? {
        // find nearest timeline and determine its absolute start timecode
        guard let (timeline, timelineAncestors) = element.fcpAncestorTimeline(
            ancestors: breadcrumbs,
            includingSelf: true
        )
        else { return nil }
        
        return absoluteRangeAsTimecode(
            timeline: timeline,
            timelineAncestors: timelineAncestors,
            resources: resources
        )
    }
    
    func absoluteRangeAsTimecode(
        timeline: XMLElement,
        timelineAncestors: AnySequence<XMLElement>,
        resources: XMLElement? = nil
    ) -> ClosedRange<Timecode>? {
        guard let kwAbsStart = element._fcpCalculateAbsoluteStart(
            ancestors: [timeline] + timelineAncestors,
            resources: resources
        ),
              let kwAbsStartTimecode = try? element._fcpTimecode(
                fromRealTime: kwAbsStart,
                frameRateSource: .mainTimeline,
                breadcrumbs: [timeline] + timelineAncestors,
                resources: resources
              ),
              let kwDuration = durationAsTimecode()
        else { return nil }
        
        let lbound = kwAbsStartTimecode
        let ubound = lbound + kwDuration
        
        return lbound ... ubound
    }
}

// MARK: - Collection Methods

extension Collection where Element == FinalCutPro.FCPXML.Keyword {
    /// Flattens a collection of keywords by removing duplicates and sorting.
    public func flattenedKeywords() -> [String] {
        flatMap(\.keywords)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .removingDuplicates()
            .sorted()
    }
}

#endif
