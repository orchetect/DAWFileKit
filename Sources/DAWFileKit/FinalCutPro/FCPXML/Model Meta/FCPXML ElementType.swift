//
//  FCPXML ElementType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum ElementType: Equatable, Hashable {
        /// Story element.
        case story(StoryElementType)
        
        /// Structure element.
        case structure(StructureElementType)
    }
}

extension FinalCutPro.FCPXML.ElementType: RawRepresentable {
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        guard let match = Self.allCases.first(where: { $0.rawValue == rawValue })
        else { return nil }
        
        self = match
    }
    
    public var rawValue: String {
        switch self {
        case let .story(storyElementType):
            return storyElementType.rawValue
        case let .structure(clipType):
            return clipType.rawValue
        }
    }
}

extension FinalCutPro.FCPXML.ElementType {
    public init?(from xmlLeaf: XMLElement) {
        guard let name = xmlLeaf.name else { return nil }
        self.init(rawValue: name)
    }
}

extension FinalCutPro.FCPXML.ElementType: CaseIterable {
    public static var allCases: [FinalCutPro.FCPXML.ElementType] {
        FinalCutPro.FCPXML.StoryElementType.allCases.map { .story($0) }
            + FinalCutPro.FCPXML.StructureElementType.allCases.map { .structure($0) }
    }
}

#endif
