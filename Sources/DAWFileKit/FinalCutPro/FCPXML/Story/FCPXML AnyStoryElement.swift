//
//  FCPXML AnyStoryElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Type-erased box containing a story element.
    public enum AnyStoryElement {
        case anyAnnotation(AnyAnnotation)
        case anyClip(AnyClip)
        case sequence(Sequence)
        case spine(Spine)
    }
}

extension FinalCutPro.FCPXML.AnyStoryElement: FCPXMLStoryElement {
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        guard let name = xmlLeaf.name else { return nil }
        
        guard let storyElementType = FinalCutPro.FCPXML.StoryElementType(rawValue: name)
        else { return nil }
        
        switch storyElementType {
        case .anyAnnotation:
            guard let annotation = FinalCutPro.FCPXML.AnyAnnotation(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            )
            else { return nil }
            
            self = .anyAnnotation(annotation)
            
        case .anyClip:
            guard let clip = FinalCutPro.FCPXML.AnyClip(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            )
            else { return nil }
            
            self = .anyClip(clip)
                
        case .sequence:
            guard let element = FinalCutPro.FCPXML.Sequence(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            )
            else {
                print("Failed to parse FCPXML sequence.")
                return nil
            }
            self = .sequence(element)
                
        case .spine:
            guard let element = FinalCutPro.FCPXML.Spine(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            )
            else { return nil }
            self = .spine(element)
        }
    }
    
    public var storyElementType: FinalCutPro.FCPXML.StoryElementType {
        switch self {
        case let .anyAnnotation(annotation): return annotation.storyElementType
        case let .anyClip(clip): return clip.storyElementType
        case .sequence(_): return .sequence
        case .spine(_): return .spine
        }
    }
    
    /// Redundant, but required to fulfill `FCPXMLStoryElement` protocol requirements.
    public func asAnyStoryElement() -> FinalCutPro.FCPXML.AnyStoryElement {
        self
    }
}

extension FinalCutPro.FCPXML.AnyStoryElement {
    /// Returns the unwrapped story element typed as ``FCPXMLStoryElement``.
    public var wrapped: any FCPXMLStoryElement {
        switch self {
        case let .anyAnnotation(storyElement): return storyElement
        case let .anyClip(storyElement): return storyElement
        case let .sequence(storyElement): return storyElement
        case let .spine(storyElement): return storyElement
        }
    }
}

extension FinalCutPro.FCPXML.AnyStoryElement: FCPXMLElementContext {
    public var context: FinalCutPro.FCPXML.ElementContext {
        wrapped.context
    }
}

// MARK: Proxy Properties

extension FinalCutPro.FCPXML.AnyStoryElement {
    // FCPXMLAnchorableAttributes
    
    /// Convenience to return the lane of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var lane: Int? {
        switch self {
        case let .anyAnnotation(clip): return clip.lane
        case let .anyClip(clip): return clip.lane
        case .sequence(_): return nil
        case let .spine(spine): return spine.lane
        }
    }
    
    /// Convenience to return the offset of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var offset: Timecode? {
        switch self {
        case let .anyAnnotation(clip): return clip.offset
        case let .anyClip(clip): return clip.offset
        case .sequence(_): return nil
        case let .spine(spine): return spine.offset
        }
    }
    
    // FCPXMLClipAttributes
    
    /// Convenience to return the name of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var name: String? {
        switch self {
        case let .anyAnnotation(clip): return clip.name
        case let .anyClip(clip): return clip.name
        case .sequence(_): return nil
        case let .spine(spine): return spine.name
        }
    }
    
    /// Convenience to return the start of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var start: Timecode? {
        switch self {
        case let .anyAnnotation(clip): return clip.start
        case let .anyClip(clip): return clip.start
        case .sequence(_): return nil // sequence.startTimecode
        case .spine(_): return nil
        }
    }
    
    /// Convenience to return the duration of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var duration: Timecode? {
        switch self {
        case let .anyAnnotation(clip): return clip.duration
        case let .anyClip(clip): return clip.duration
        case let .sequence(sequence): return sequence.duration
        case .spine(_): return nil
        }
    }
    
    /// Convenience to return the enabled state of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var enabled: Bool {
        switch self {
        case let .anyAnnotation(clip): return clip.enabled
        case let .anyClip(clip): return clip.enabled
        case .sequence(_): return true // can't be disabled
        case .spine(_): return true // can't be disabled
        }
    }
}

extension FinalCutPro.FCPXML.AnyStoryElement: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        switch self {
        case let .anyAnnotation(clip): return clip.extractableElements()
        case let .anyClip(clip): return clip.extractableElements()
        case let .sequence(sequence): return sequence.extractableElements()
        case let .spine(spine): return spine.extractableElements()
        }
    }
    
    public func extractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyElement],
        matching predicate: (_ element: FinalCutPro.FCPXML.AnyElement) -> Bool
    ) -> [FinalCutPro.FCPXML.AnyElement] {
        switch self {
        case let .anyAnnotation(clip):
            return clip.extractElements(
                settings: settings,
                ancestorsOfParent: ancestorsOfParent,
                matching: predicate
            )
        case let .anyClip(clip):
            return clip.extractElements(
                settings: settings,
                ancestorsOfParent: ancestorsOfParent,
                matching: predicate
            )
        case let .sequence(sequence):
            return sequence.extractElements(
                settings: settings,
                ancestorsOfParent: ancestorsOfParent,
                matching: predicate
            )
        case let .spine(spine):
            return spine.extractElements(
                settings: settings,
                ancestorsOfParent: ancestorsOfParent,
                matching: predicate
            )
        }
    }
}

// MARK: - Filtering

extension Collection<FinalCutPro.FCPXML.AnyStoryElement> {
    /// Convenience to filter the FCPXML story element collection and return only annotations.
    public func annotations() -> [FinalCutPro.FCPXML.AnyAnnotation] {
        reduce(into: []) { elements, element in
            if case let .anyAnnotation(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML story element collection and return only clips.
    public func clips() -> [FinalCutPro.FCPXML.AnyClip] {
        reduce(into: []) { elements, element in
            if case let .anyClip(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML story element collection and return only sequences.
    public func sequences() -> [FinalCutPro.FCPXML.Sequence] {
        reduce(into: []) { elements, element in
            if case let .sequence(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML story element collection and return only sequences.
    public func spines() -> [FinalCutPro.FCPXML.Spine] {
        reduce(into: []) { elements, element in
            if case let .spine(element) = element { elements.append(element) }
        }
    }
}

// MARK: - FCPXML Parsing

extension FinalCutPro.FCPXML {
    static func storyElements(
        in xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) -> [AnyStoryElement] {
        xmlLeaf
            .children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .compactMap {
                AnyStoryElement(
                    from: $0,
                    breadcrumbs: breadcrumbs + [xmlLeaf],
                    resources: resources,
                    contextBuilder: contextBuilder
                )
            }
            ?? []
    }
}

#endif
