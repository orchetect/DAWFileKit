//
//  FCPXMLAnnotationElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

// TODO: will likely factor this out, as it does not align with the DTD's structure.

/// FCPXML annotation elements.
///
/// - `keyword`
/// - `marker`
/// - `chapter-marker`
/// - `analysis-marker`
/// - `rating`
/// - `caption`
///
/// > Final Cut Pro FCPXML 1.11 Reference:
/// >
/// > Many story elements can contain annotations (keyword, markers, and so on) over a range of
/// > time, specified with the start and duration attributes. Add annotations to story elements
/// > using the elements listed under [Annotation and Note Elements](
/// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements
/// > ).
public protocol FCPXMLAnnotationElement: FCPXMLStoryElement where Self: Equatable {
    /// Returns the annotation type enum case.
    var annotationType: FinalCutPro.FCPXML.AnnotationType { get }
    
    /// Returns the annotation as ``FinalCutPro/FCPXML/AnyAnnotation``.
    func asAnyAnnotation() -> FinalCutPro.FCPXML.AnyAnnotation
    
    /// Initialize from an XML leaf (element) using a context builder instance.
    init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    )
}

// MARK: - Sub-Protocol Implementations

extension FCPXMLAnnotationElement /* : FCPXMLStoryElement */ {
    public var storyElementType: FinalCutPro.FCPXML.StoryElementType {
        .anyAnnotation(annotationType)
    }
    
    public func asAnyStoryElement() -> FinalCutPro.FCPXML.AnyStoryElement {
        .anyAnnotation(self.asAnyAnnotation())
    }
}

// MARK: - Equatable

extension FCPXMLAnnotationElement {
    func isEqual(to other: some FCPXMLAnnotationElement) -> Bool {
        self.asAnyAnnotation() == other.asAnyAnnotation()
    }
}

// MARK: - Nested Type Erasure

extension FCPXMLAnnotationElement {
    public func asAnyElement() -> FinalCutPro.FCPXML.AnyElement {
        .story(asAnyStoryElement())
    }
}

extension Collection where Element: FCPXMLAnnotationElement {
    public func asAnyElements() -> [FinalCutPro.FCPXML.AnyElement] {
        map { $0.asAnyElement() }
    }
}

extension Collection<FinalCutPro.FCPXML.AnyAnnotation> {
    public func asAnyStoryElements() -> [FinalCutPro.FCPXML.AnyStoryElement] {
        map { $0.asAnyStoryElement() }
    }
}

extension Collection<FinalCutPro.FCPXML.AnyAnnotation> {
    public func asAnyElements() -> [FinalCutPro.FCPXML.AnyElement] {
        map { $0.asAnyElement() }
    }
}

// MARK: - Collection Methods

extension Collection<FinalCutPro.FCPXML.AnyAnnotation> {
    public func contains(_ annotation: any FCPXMLClip) -> Bool {
        contains(where: { $0.wrapped.isEqual(to: annotation) })
    }
}

extension Dictionary where Value == FinalCutPro.FCPXML.AnyAnnotation {
    public func contains(value annotation: any FCPXMLClip) -> Bool {
        values.contains(annotation)
    }
}

extension Collection where Element: FCPXMLAnnotationElement {
    public func contains(_ annotation: FinalCutPro.FCPXML.AnyAnnotation) -> Bool {
        contains(where: { $0.asAnyAnnotation() == annotation })
    }
}

extension Dictionary where Value: FCPXMLAnnotationElement {
    public func contains(value annotation: FinalCutPro.FCPXML.AnyAnnotation) -> Bool {
        values.contains(where: { $0.asAnyAnnotation() == annotation })
    }
}

#endif
