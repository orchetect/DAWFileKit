//
//  FCPXML StoryElementType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Story element types.
    public enum StoryElementType: Equatable, Hashable {
        /// An annotation.
        case annotation(_ annotationType: AnnotationType)
        
        /// A clip.
        case clip(_ clipType: ClipType)
        
        /// A container that represents the top-level sequence for a Final Cut Pro project or
        /// compound clip.
        case sequence
        
        /// Contains elements ordered sequentially in time.
        case spine
    }
}

extension FinalCutPro.FCPXML.StoryElementType: RawRepresentable {
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        guard let match = Self.allCases.first(where: { $0.rawValue == rawValue })
        else { return nil }
        
        self = match
    }
    
    public var rawValue: String {
        switch self {
        case let .annotation(annotationType):
            return annotationType.rawValue
        case let .clip(clipType):
            return clipType.rawValue
        case .sequence:
            return "sequence"
        case .spine:
            return "spine"
        }
    }
}


extension FinalCutPro.FCPXML.StoryElementType: CaseIterable {
    public static var allCases: [FinalCutPro.FCPXML.StoryElementType] {
        FinalCutPro.FCPXML.AnnotationType.allCases.map { .annotation($0) }
            + FinalCutPro.FCPXML.ClipType.allCases.map { .clip($0) }
            + [.sequence, .spine]
    }
}

extension FinalCutPro.FCPXML.StoryElementType: FCPXMLElementTypeProtocol {
    public var elementType: FinalCutPro.FCPXML.ElementType {
        .story(self)
    }
}

#endif
