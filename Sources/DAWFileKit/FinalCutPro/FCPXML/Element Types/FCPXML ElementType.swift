//
//  FCPXML ElementType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Element types.
    public enum ElementType: Equatable, Hashable {
        /// Story element.
        case story(_ storyElementType: StoryElementType)
        
        /// Structure element.
        case structure(_ structureElementType: StructureElementType)
        
        /// Resources element.
        /// Contains descriptions of media assets and other resources.
        /// Exactly one of these elements is always required within the `fcpxml` element.
        case resources
        
        /// A resource element contained within the `resources` element.
        case resource(ResourceType)
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
        case let .structure(structureElementType):
            return structureElementType.rawValue
        case .resources:
            return "resources"
        case let .resource(resourceType):
            return resourceType.rawValue
        }
    }
}

extension FinalCutPro.FCPXML.ElementType: CaseIterable {
    public static var allCases: [FinalCutPro.FCPXML.ElementType] {
        FinalCutPro.FCPXML.StoryElementType.allCases.map { .story($0) }
            + FinalCutPro.FCPXML.StructureElementType.allCases.map { .structure($0) }
            + [.resources]
            + FinalCutPro.FCPXML.ResourceType.allCases.map { .resource($0) }
    }
}

extension FinalCutPro.FCPXML.ElementType: FCPXMLElementTypeProtocol {
    public var elementType: FinalCutPro.FCPXML.ElementType {
        self
    }
}

#endif
