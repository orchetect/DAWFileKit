//
//  FCPXML AnnotationType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Annotation element types.
    public enum AnnotationType: Equatable, Hashable {
        /// Closed caption.
        case caption
        
        /// Keyword.
        case keyword
        
        /// Marker. Includes standard, to-do and chapter markers.
        case marker(_ markerType: MarkerType)
    }
}

extension FinalCutPro.FCPXML.AnnotationType: RawRepresentable {
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        guard let match = Self.allCases.first(where: { $0.rawValue == rawValue })
        else { return nil }
        
        self = match
    }
    
    public var rawValue: String {
        switch self {
        case .caption:
            return "caption"
        case .keyword:
            return "keyword"
        case let .marker(variant):
            return variant.rawValue
        }
    }
}

extension FinalCutPro.FCPXML.AnnotationType: CaseIterable {
    public static var allCases: [FinalCutPro.FCPXML.AnnotationType] {
        [.caption, .keyword]
            + FinalCutPro.FCPXML.MarkerType.allCases.map { .marker($0) }
    }
}

extension FinalCutPro.FCPXML.AnnotationType: FCPXMLElementTypeProtocol {
    public var elementType: FinalCutPro.FCPXML.ElementType {
        .story(.annotation(self))
    }
}

#endif
