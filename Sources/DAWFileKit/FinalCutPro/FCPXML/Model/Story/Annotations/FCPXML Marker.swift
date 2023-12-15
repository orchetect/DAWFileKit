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
    /// Marker model meta-type.
    /// Represents a marker event and its contents.
    /// Can represent any marker type (standard, to-do, and chapter).
    public struct Marker: FCPXMLElement {
        public let element: XMLElement
        
        public static let supportedElementTypes: Set<ElementType> = [
            .marker, .chapterMarker
        ]
        
        public var elementType: ElementType {
            guard let eType = element.fcpElementType,
                  Self.supportedElementTypes.contains(eType)
            else {
                assertionFailure("Unexpected element type.")
                return .marker
            }
            return eType
        }
        
        public init() {
            // default to standard marker
            self.init(markerElementNamed: "")
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementTypeSupported(element: element) else { return nil }
        }
    }
}

// MARK: - Parameterized init

extension FinalCutPro.FCPXML.Marker {
    /// Initialize a new marker by providing its name and configuration.
    public init(
        name: String,
        configuration: FinalCutPro.FCPXML.Marker.Configuration,
        start: Fraction,
        duration: Fraction? = nil,
        note: String? = nil
    ) {
        switch configuration.markerElementType {
        case .marker:
            self.init(markerElementNamed: name)
        case .chapterMarker:
            self.init(chapterMarkerElementNamed: name)
        }
        
        self.configuration = configuration
        self.start = start
        self.duration = duration
        self.note = note
    }
    
    /// Initialize a new `marker` element with the given marker name.
    /// This element type may be a standard marker or a to-do marker.
    init(markerElementNamed markerName: String) {
        element = XMLElement(name: FinalCutPro.FCPXML.ElementType.marker.rawValue)
        name = markerName
    }
    
    /// Initialize a new `chapter-marker` element with the given marker name.
    init(chapterMarkerElementNamed markerName: String) {
        element = XMLElement(name: FinalCutPro.FCPXML.ElementType.chapterMarker.rawValue)
        name = markerName
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Marker {
    public enum Attributes: String {
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
    
    // no children
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Marker {
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
    
    public var configuration: Configuration {
        get { element.fcpMarkerConfiguration ?? .standard }
        set { element.fcpMarkerConfiguration = newValue }
    }
}

extension FinalCutPro.FCPXML.Marker: FCPXMLElementRequiredStart { }

extension FinalCutPro.FCPXML.Marker: FCPXMLElementOptionalDuration { }

// MARK: - Properties

// Chapter Marker
extension XMLElement {
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

// Marker or Chapter Marker
extension XMLElement {
    // TODO: needs unit testing :)
    /// FCPXML: Get or set the marker type and configuration. Setting `nil` has no effect.
    /// Call on a `marker` or `chapter-marker` element.
    public var fcpMarkerConfiguration: FinalCutPro.FCPXML.Marker.Configuration? {
        get {
            guard let markerElementType = fcpMarkerElementType
            else { return nil }
            
            switch markerElementType {
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
        set {
            guard let newValue = newValue else { return }
            guard let markerElementType = fcpMarkerElementType else { return }
            
            if newValue.markerElementType != markerElementType {
                // we have to modify the XML element name
                self.name = newValue.markerElementType.elementType.rawValue
                
                // remove incompatible attributes if present
                switch newValue.markerElementType {
                case .marker:
                    removeAttribute(forName: FinalCutPro.FCPXML.Marker.Attributes.posterOffset.rawValue)
                case .chapterMarker:
                    removeAttribute(forName: FinalCutPro.FCPXML.Marker.Attributes.completed.rawValue)
                }
            }
            
            // set new attributes
            switch newValue {
            case .standard:
                // remove non-applicable to-do attributes
                removeAttribute(forName: FinalCutPro.FCPXML.Marker.Attributes.completed.rawValue)
                
            case let .toDo(completed: completed):
                // note: don't allow deletion of this attribute, as the presence of `completed`
                // attribute signifies that this marker is a to-do marker
                set(bool: completed,
                    forAttribute: FinalCutPro.FCPXML.Marker.Attributes.completed.rawValue,
                    defaultValue: true, // N/A
                    removeIfDefault: false,
                    useInt: true)
                
            case let .chapter(posterOffset: posterOffset):
                _fcpSet(fraction: posterOffset,
                        forAttribute: FinalCutPro.FCPXML.Marker.Attributes.posterOffset.rawValue)
            }
        }
    }
}

// MARK: - Typing

// Marker or Chapter Marker
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Marker`` model object.
    /// Call this on a `marker` or `chapter-marker` element only.
    public var fcpAsMarker: FinalCutPro.FCPXML.Marker? {
        .init(element: self)
    }
}

// MARK: - Sequence Methods

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

// MARK: - MarkerElementType

extension FinalCutPro.FCPXML.Marker {
    internal enum MarkerElementType: Equatable, Hashable, CaseIterable, Sendable {
        case marker
        case chapterMarker
        
        var elementType: FinalCutPro.FCPXML.ElementType {
            switch self {
            case .marker: return .marker
            case .chapterMarker: return .chapterMarker
            }
        }
        
        init?(element: XMLElement) {
            switch element.fcpElementType {
            case .marker: self = .marker
            case .chapterMarker: self = .chapterMarker
            default: return nil
            }
        }
    }
}

// MARK: - Typing

// Marker or Chapter Marker
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Marker/MarkerElementType``
    /// model object.
    /// Call this on a `marker` or `chapter-marker` element only.
    internal var fcpMarkerElementType: FinalCutPro.FCPXML.Marker.MarkerElementType? {
        .init(element: self)
    }
}

// MARK: - Configuration

extension FinalCutPro.FCPXML.Marker {
    public enum Configuration: Equatable, Hashable, Sendable {
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

extension FinalCutPro.FCPXML.Marker.Configuration {
    /// Returns the associated element type.
    internal var markerElementType: FinalCutPro.FCPXML.Marker.MarkerElementType {
        switch self {
        case .standard, .toDo: return .marker
        case .chapter: return .chapterMarker
        }
    }
}

// MARK: - MarkerKind

extension FinalCutPro.FCPXML.Marker {
    // TODO: add `analysisMarker`?
    public enum MarkerKind: Equatable, Hashable, CaseIterable, Sendable {
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
        guard let markerConfiguration = fcpMarkerConfiguration else { return nil }
        
        switch markerConfiguration {
        case .standard: return .standard
        case .chapter: return .chapter
        case .toDo: return .toDo
        }
    }
}

#endif
