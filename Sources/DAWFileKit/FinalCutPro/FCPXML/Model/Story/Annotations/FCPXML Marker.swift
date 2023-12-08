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
    /// Includes all marker types (standard, to-do, and chapter).
    public struct Marker: Equatable, Hashable {
        public let element: XMLElement
        
        // Element-Specific Attributes
        
        /// Name. (Required)
        public var name: String {
            get { element.fcpValue ?? "" }
            set { element.fcpValue = newValue }
        }
        
        /// Optional note.
        public var note: String? {
            get { element.fcpNote }
            set { element.fcpNote = newValue }
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Marker: FCPXMLElementRequiredStart { }

extension FinalCutPro.FCPXML.Marker: FCPXMLElementOptionalDuration { }

extension FinalCutPro.FCPXML.Marker {
    public static func annotationType(
        for element: XMLElement
    ) -> FinalCutPro.FCPXML.AnnotationType {
        switch element.fcpMarkerKind {
        case .standard, .toDo: 
            return .marker(.marker)
        case .chapter:
            return .marker(.chapterMarker)
        default:
            return .marker(.marker)
        }
    }
    
    public enum Attributes: String, XMLParsableAttributesKey {
        /// Start time. 
        /// Common for all marker types.
        case start
        
        /// Duration. 
        /// Common for all marker types.
        case duration
        
        /// Value (marker name). 
        /// Common for all marker types.
        case value
        
        /// Note. 
        /// Common for all marker types.
        case note
        
        /// Poster Offset. 
        /// Applies to Chapter Marker only.
        case posterOffset
        
        /// Completed state. 
        /// Applies to To-Do Markers only.
        /// If `completed` attribute is present, the marker becomes a to-do item.
        case completed
    }
}

extension XMLElement { // Any Marker
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Marker`` model object.
    /// Call this on a `marker` or `chapter-marker` element only.
    public var fcpAsMarker: FinalCutPro.FCPXML.Marker {
        .init(element: self)
    }
    
    /// FCPXML: Returns the marker type of the element, if the element is a marker.
    /// Call this on a `marker` or `chapter-marker` element.
    public var fcpMarkerType: FinalCutPro.FCPXML.MarkerType? {
        FinalCutPro.FCPXML.MarkerType(from: self)
    }
    
    /// FCPXML: Returns the marker type and state.
    /// Call on a `marker` or `chapter-marker` element.
    public var fcpMarkerState: FinalCutPro.FCPXML.Marker.MarkerState? {
        guard let fcpMarkerType = fcpMarkerType else { return nil }
        
        switch fcpMarkerType {
        case .marker:
            // standard marker or to-do marker
            // "completed" attribute will only exist if marker is a to-do marker
            if let completed = fcpIsCompleted {
                return .toDo(completed: completed)
            } else {
                // marker is a standard marker
                return .standard
            }
            
        case .chapterMarker:
            // posterOffset (thumbnail timecode) is optional, but can a be negative offset
            
            let posterOffset: Fraction
            if let fcpPosterOffset = fcpPosterOffset {
                posterOffset = fcpPosterOffset
            } else {
                print("Error: marker posterOffset could not be decoded.")
                posterOffset = .zero
            }
            
            return .chapter(posterOffset: posterOffset)
        }
    }
}

extension XMLElement { // Chapter Marker
    /// FCPXML: Returns the value of the `isCompleted` attribute.
    /// If `completed` attribute is present, the marker becomes a to-do item.
    /// If `nil` is returned, the marker is a standard marker.
    /// Call this on a `marker` element.
    public var fcpIsCompleted: Bool? {
        get {
            getBool(forAttribute: FinalCutPro.FCPXML.Marker.Attributes.completed.rawValue)
        }
        set {
            set(
                bool: newValue,
                forAttribute: FinalCutPro.FCPXML.Marker.Attributes.completed.rawValue
            )
        }
    }
    
    /// FCPXML: Returns the value of the `posterOffset` attribute as a `CMTime` instance.
    /// Call this on a `chapter-marker` element.
    public var fcpPosterOffset: Fraction? {
        get { 
            _fcpGetFraction(
                forAttribute: FinalCutPro.FCPXML.Marker.Attributes.posterOffset.rawValue
            )
        }
        set {
            _fcpSet(
                fraction: newValue,
                forAttribute: FinalCutPro.FCPXML.Marker.Attributes.posterOffset.rawValue
            )
        }
    }
}

// MARK: - Marker Metadata

extension FinalCutPro.FCPXML.Marker {
    public enum MarkerState: Equatable, Hashable {
        /// Standard Marker.
        /// Contains no additional metadata.
        case standard
        
        /// Chapter Marker.
        ///
        /// - Parameters:
        ///   - posterOffset: The chapter marker's thumbnail location expressed as the distance
        ///     (offset) from the marker's start. This may be a positive or negative time.
        case chapter(posterOffset: Fraction)
        
        /// To Do Marker.
        case toDo(completed: Bool)
    }
}

// MARK: - Marker Type

extension FinalCutPro.FCPXML.Marker {
    // TODO: add `analysisMarker`?
    public enum MarkerKind: CaseIterable {
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

extension XMLElement { // Any Marker
    /// FCPXML: Returns the marker kind.
    /// Call on `marker` or `chapter-marker` elements.
    public var fcpMarkerKind: FinalCutPro.FCPXML.Marker.MarkerKind? {
        guard let fcpMarkerState = fcpMarkerState else { return nil }
        
        switch fcpMarkerState {
        case .standard: return .standard
        case .chapter: return .chapter
        case .toDo: return .toDo
        }
    }
}

// MARK: - Model Structures

extension Sequence<FinalCutPro.FCPXML.Marker> {
    /// Sort collection by marker `start` attribute.
    public func sorted() -> [FinalCutPro.FCPXML.Marker] {
        sorted { lhs, rhs in
            lhs.start < rhs.start
        }
    }
    
    /// Sort collection by marker name.
    public func sortedByName() -> [FinalCutPro.FCPXML.Marker] {
        sorted { lhs, rhs in
            lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }
}

#endif
