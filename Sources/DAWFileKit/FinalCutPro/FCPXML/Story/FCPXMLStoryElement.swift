//
//  FCPXMLStoryElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

/// FCPXML story elements.
///
/// - `clip`
/// - `asset-clip`
/// - `sync-clip`
/// - `audio`
/// - `video`
/// - `mc-clip`
/// - `ref-clip`
/// - `gap`
/// - `spine`
/// - `audition`
/// - `sequence`
///
/// > Final Cut Pro FCPXML 1.11 Reference:
/// >
/// > Use Story Elements to arrange video or audio materials and titles or generators into a
/// > timeline, in the order you want them to appear when it plays on the timeline.
/// > Use the [Timing Attributes](
/// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements
/// > ) for additional control over their precise timing.
/// >
/// > Anchor one or more other story elements to each story element. An anchored item has a positive
/// > or negative lane index that either positions the item above or below its base element in the
/// > timeline.
/// >
/// > For video elements, lane order also implies compositing order — items with higher lane indexes
/// > composite over elements with lower lane indexes. For audio elements, lane order doesn’t affect
/// > compositing. Items that reside inside, rather than above or below, a container are called
/// > contained items and have an implied lane index of zero.
/// >
/// > Many story elements can contain annotations (keyword, markers, and so on) over a range of
/// > time, specified with the start and duration attributes. Add annotations to story elements
/// > using the elements listed under [Annotation and Note Elements](
/// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements
/// > ).
public protocol FCPXMLStoryElement: FCPXMLElement where Self: Equatable {
    /// Returns the story element type enum case.
    var storyElementType: FinalCutPro.FCPXML.StoryElementType { get }
    
    /// Returns the story element as ``FinalCutPro/FCPXML/AnyStoryElement``.
    func asAnyStoryElement() -> FinalCutPro.FCPXML.AnyStoryElement
    
    init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    )
}

// MARK: - Sub-Protocol Implementations

extension FCPXMLStoryElement /* : FCPXMLElement */ {
    public var elementType: FinalCutPro.FCPXML.ElementType { .story(storyElementType) }
}

// MARK: - Equatable

extension FCPXMLStoryElement {
    func isEqual(to other: some FCPXMLStoryElement) -> Bool {
        self.asAnyStoryElement() == other.asAnyStoryElement()
    }
}

// MARK: - Nested Type Erasure

extension FCPXMLStoryElement {
    public func asAnyElement() -> FinalCutPro.FCPXML.AnyElement {
        .story(asAnyStoryElement())
    }
}

extension Collection where Element: FCPXMLStoryElement {
    public func asAnyElements() -> [FinalCutPro.FCPXML.AnyElement] {
        map { $0.asAnyElement() }
    }
}

extension Collection<FinalCutPro.FCPXML.AnyStoryElement> {
    public func asAnyElements() -> [FinalCutPro.FCPXML.AnyElement] {
        map { $0.asAnyElement() }
    }
}

// MARK: - Collection Methods

extension Collection<FinalCutPro.FCPXML.AnyStoryElement> {
    public func contains(_ storyElement: any FCPXMLStoryElement) -> Bool {
        contains(where: { $0.wrapped.isEqual(to: storyElement) })
    }
}

extension Dictionary where Value == FinalCutPro.FCPXML.AnyStoryElement {
    public func contains(value storyElement: any FCPXMLStoryElement) -> Bool {
        values.contains(storyElement)
    }
}

extension Collection where Element: FCPXMLStoryElement {
    public func contains(_ storyElement: FinalCutPro.FCPXML.AnyStoryElement) -> Bool {
        contains(where: { $0.asAnyStoryElement() == storyElement })
    }
}

extension Dictionary where Value: FCPXMLStoryElement {
    public func contains(value storyElement: FinalCutPro.FCPXML.AnyStoryElement) -> Bool {
        values.contains(where: { $0.asAnyStoryElement() == storyElement })
    }
}

#endif
