//
//  FCPXML Marker.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import CoreMedia

extension FinalCutPro.FCPXML {
    /// Represents a marker event and its contents.
    public struct Marker: Hashable {
        public var start: Timecode // required
        public var duration: Timecode?
        public var name: String // a.k.a. `value`, required
        public var metaData: MarkerMetaData // required
        public var note: String?
        
        // FCPXMLElementContext
        @EquatableAndHashableExempt
        public var context: FinalCutPro.FCPXML.ElementContext
        
        public init(
            start: Timecode,
            duration: Timecode?,
            name: String,
            metaData: MarkerMetaData = .standard,
            note: String?,
            // FCPXMLElementContext
            context: FinalCutPro.FCPXML.ElementContext = .init()
        ) {
            self.start = start
            self.duration = duration
            self.name = name
            self.metaData = metaData
            self.note = note
            
            // FCPXMLElementContext
            self.context = context
        }
    }
}

extension FinalCutPro.FCPXML.Marker: FCPXMLAnnotationElement {
    /// Attributes unique to Marker.
    public enum Attributes: String, XMLParsableAttributesKey {
        // common for all marker types
        case start
        case duration
        case value // a.k.a name
        case note
        
        // Chapter Marker only
        case posterOffset
        
        // To Do Marker only
        case completed
    }
    
    public init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let rawValues = xmlLeaf.parseAttributesRawValues(key: Attributes.self)
        
        // validate element name and determine marker type
        guard let leafName = xmlLeaf.name,
              let nodeType = MarkerNodeType(rawValue: leafName)
        else { return nil }
        
        // parse common attributes that all markers share
        
        // `start`
        guard let startValue = try? FinalCutPro.FCPXML.timecode(
            fromRational: rawValues[.start] ?? "",
            xmlLeaf: xmlLeaf,
            resources: resources
        ) else { return nil }
        start = startValue
        
        // `duration`
        duration = try? FinalCutPro.FCPXML.timecode(
            fromRational: rawValues[.duration] ?? "",
            xmlLeaf: xmlLeaf,
            resources: resources
        )
        
        // `value` - marker name
        guard let nameValue = rawValues[.value] else { return nil }
        self.name = nameValue
        
        // "note"
        note = rawValues[.note]
        
        // check marker type to parse additional metadata
        
        switch nodeType {
        case .marker: // standard marker or to-do marker
            // "completed" attribute will only exist if marker is a to-do marker
            if let completed = rawValues[.completed] {
                metaData = .toDo(completed: completed == "1")
            } else {
                // marker is a standard marker
                metaData = .standard
            }
            
        case .chapterMarker:
            // posterOffset (thumbnail timecode) is optional, but can a be negative offset
            // so we need to use TimecodeInterval
            
            var posterOffset: TimecodeInterval? = nil
            if let posterOffsetString = rawValues[.posterOffset] {
                if let tc = try? FinalCutPro.FCPXML.timecodeInterval(
                    fromRational: posterOffsetString,
                    xmlLeaf: xmlLeaf,
                    resources: resources
                ) {
                    posterOffset = tc
                } else {
                    print("Error: marker posterOffset could not be decoded.")
                    posterOffset = nil
                }
            }
            metaData = .chapter(posterOffset: posterOffset)
        }
        
        // FCPXMLElementContext
        context = contextBuilder.buildContext(from: xmlLeaf, resources: resources)
    }
    
    public var annotationType: FinalCutPro.FCPXML.AnnotationType {
        switch markerType {
        case .standard, .toDo: return .marker
        case .chapter: return .chapterMarker
        }
    }
    
    public func asAnyAnnotation() -> FinalCutPro.FCPXML.AnyAnnotation {
        .marker(self)
    }
}

extension FinalCutPro.FCPXML.Marker: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        [self.asAnyElement()]
    }
    
    public func extractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyElement],
        matching predicate: (_ element: FinalCutPro.FCPXML.AnyElement) -> Bool
    ) -> [FinalCutPro.FCPXML.AnyElement] {
        []
    }
}

extension Collection<FinalCutPro.FCPXML.Marker> {
    /// Sorts collection by marker's `start` attribute.
    public func sortedByStart() -> [FinalCutPro.FCPXML.Marker] {
        sorted { lhs, rhs in
            lhs.start < rhs.start
        }
    }
    
    /// Sorts collection by marker's absolute start timecode.
    public func sortedByAbsoluteStart() -> [FinalCutPro.FCPXML.Marker] {
        sorted { lhs, rhs in
            guard let lhsAbsoluteStart = lhs.context[.absoluteStart],
                  let rhsAbsoluteStart = rhs.context[.absoluteStart]
            else {
                // sort by `start` attribute as fallback
                return lhs.start < rhs.start
            }
            return lhsAbsoluteStart < rhsAbsoluteStart
        }
    }
}

// MARK: - Marker Type

extension FinalCutPro.FCPXML.Marker {
    // TODO: add `analysisMarker`?
    public enum MarkerType: CaseIterable {
        case standard
        case chapter
        case toDo
        
        public var name: String {
            switch self {
            case .standard: return "Standard"
            case .chapter: return "Chapter"
            case .toDo: return "To Do"
            }
        }
    }
}

extension FinalCutPro.FCPXML.Marker {
    /// Returns the marker type.
    public var markerType: MarkerType {
        switch metaData {
        case .standard: return .standard
        case .chapter: return .chapter
        case .toDo: return .toDo
        }
    }
}

// MARK: - Marker Node Type

extension FinalCutPro.FCPXML.Marker {
    public enum MarkerNodeType: String, CaseIterable {
        case marker
        case chapterMarker = "chapter-marker"
    }
}

// MARK: - Marker Metadata

extension FinalCutPro.FCPXML.Marker {
    public enum MarkerMetaData: Equatable, Hashable {
        /// Standard Marker.
        /// Contains no additional metadata.
        case standard
        
        /// Chapter Marker.
        ///
        /// `posterOffset` is the chapter marker's thumbnail location expressed as a delta distance (offset) from the marker's position.
        /// This may be positive or negative which is why it is encapsulated in a `TimecodeInterval`.
        case chapter(posterOffset: TimecodeInterval?)
        
        /// To Do Marker.
        case toDo(completed: Bool)
    }
}

#endif
