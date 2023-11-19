//
//  FCPXML AnyAnnotation.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Type-erased box containing a specialized annotation instance.
    public enum AnyAnnotation {
        case caption(Caption)
        case keyword(Keyword)
        case marker(Marker)
    }
}

extension FinalCutPro.FCPXML.AnyAnnotation: FCPXMLAnnotationElement {
    public init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        guard let name = xmlLeaf.name else { return nil }
        guard let annotationType = FinalCutPro.FCPXML.AnnotationType(rawValue: name) else {
            print("Unrecognized FCPXML annotation type: \(name)")
            return nil
        }
        
        switch annotationType {
        case .caption:
            guard let caption = FinalCutPro.FCPXML.Caption(
                from: xmlLeaf,
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            self = .caption(caption)
            
        case .keyword:
            guard let keyword = FinalCutPro.FCPXML.Keyword(
                from: xmlLeaf,
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            self = .keyword(keyword)
            
        case .marker, .chapterMarker:
            guard let marker = FinalCutPro.FCPXML.Marker(
                from: xmlLeaf,
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            self = .marker(marker)
        }
    }
    
    public var annotationType: FinalCutPro.FCPXML.AnnotationType {
        wrapped.annotationType
    }
    
    /// Redundant, but required to fulfill `FCPXMLAnnotationElement` protocol requirements.
    public func asAnyAnnotation() -> FinalCutPro.FCPXML.AnyAnnotation {
        self
    }
}

extension FinalCutPro.FCPXML.AnyAnnotation {
    /// Returns the unwrapped clip typed as ``FCPXMLClip``.
    public var wrapped: any FCPXMLAnnotationElement {
        switch self {
        case let .caption(annotation): return annotation
        case let .keyword(annotation): return annotation
        case let .marker(annotation): return annotation
        }
    }
}

extension FinalCutPro.FCPXML.AnyAnnotation: FCPXMLElementContext {
    public var context: FinalCutPro.FCPXML.ElementContext {
        wrapped.context
    }
}

// MARK: Proxy Properties

extension FinalCutPro.FCPXML.AnyAnnotation: FCPXMLClipAttributes {
    // FCPXMLAnchorableAttributes
    
    /// Convenience to return the lane of the clip.
    public var lane: Int? {
        switch self {
        case let .caption(annotation): return annotation.lane // has lane
        case .keyword(_): return nil
        case .marker(_): return nil
        }
    }
    
    /// Convenience to return the offset of the clip.
    public var offset: Timecode? {
        switch self {
        case let .caption(annotation): return annotation.offset // has offset
        case .keyword(_): return nil
        case .marker(_): return nil
        }
    }
    
    // FCPXMLClipAttributes
    
    /// Convenience to return the name of the clip.
    public var name: String? {
        switch self {
        case let .caption(annotation): return annotation.name // has name
        case .keyword(_): return nil
        case .marker(_): return nil
        }
    }
    
    /// Convenience to return the start of the clip.
    public var start: Timecode? {
        switch self {
        case let .caption(annotation): return annotation.start // has start
        case let .keyword(keyword): return keyword.start // has start
        case let .marker(marker): return marker.start // has start
        }
    }
    
    /// Convenience to return the duration of the clip.
    public var duration: Timecode? {
        switch self {
        case let .caption(annotation): return annotation.duration // has duration
        case let .keyword(keyword): return keyword.duration // has duration
        case let .marker(marker): return marker.duration // has duration
        }
    }
    
    /// Convenience to return the enabled state of the clip.
    public var enabled: Bool {
        switch self {
        case let .caption(annotation): return annotation.enabled // has enabled
        case .keyword(_): return true // can't be disabled
        case .marker(_): return true // can't be disabled
        }
    }
}

extension FinalCutPro.FCPXML.AnyAnnotation: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        switch self {
        case let .caption(annotation): return annotation.extractableElements()
        case let .keyword(annotation): return annotation.extractableElements()
        case let .marker(annotation): return annotation.extractableElements()
        }
    }
    
    public func extractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyElement],
        matching predicate: (_ element: FinalCutPro.FCPXML.AnyElement) -> Bool
    ) -> [FinalCutPro.FCPXML.AnyElement] {
        switch self {
        case let .caption(annotation):
            return annotation.extractElements(
                settings: settings,
                ancestorsOfParent: ancestorsOfParent,
                matching: predicate
            )
        case let .keyword(annotation):
            return annotation.extractElements(
                settings: settings,
                ancestorsOfParent: ancestorsOfParent,
                matching: predicate
            )
        case let .marker(annotation):
            return annotation.extractElements(
                settings: settings,
                ancestorsOfParent: ancestorsOfParent,
                matching: predicate
            )
        }
    }
}

// MARK: - Filtering

extension Collection<FinalCutPro.FCPXML.AnyAnnotation> {
    /// Convenience to filter the FCPXML annotation collection and return only captions.
    public func captions() -> [FinalCutPro.FCPXML.Caption] {
        reduce(into: []) { elements, element in
            if case let .caption(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML annotation collection and return only keywords.
    public func keywords() -> [FinalCutPro.FCPXML.Keyword] {
        reduce(into: []) { elements, element in
            if case let .keyword(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML annotation collection and return only markers.
    public func markers() -> [FinalCutPro.FCPXML.Marker] {
        reduce(into: []) { elements, element in
            if case let .marker(element) = element { elements.append(element) }
        }
    }
}

#endif
