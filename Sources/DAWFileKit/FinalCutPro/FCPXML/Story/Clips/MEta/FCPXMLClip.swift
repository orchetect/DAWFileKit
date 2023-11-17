//
//  FCPXMLClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

public protocol FCPXMLClip: FCPXMLStoryElement where Self: Equatable {
    /// Returns the clip type enum case.
    var clipType: FinalCutPro.FCPXML.ClipType { get }
    
    /// Returns the clip as ``FinalCutPro/FCPXML/AnyClip``.
    func asAnyClip() -> FinalCutPro.FCPXML.AnyClip
    
    init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    )
}

extension FCPXMLClip {
    func isEqual(to other: some FCPXMLClip) -> Bool {
        self.asAnyClip() == other.asAnyClip()
    }
}

// MARK: - Sub-Protocol Implementations

extension FCPXMLClip /* : FCPXMLStoryElement */ {
    public var storyElementType: FinalCutPro.FCPXML.StoryElementType {
        .anyClip(clipType)
    }
    
    public func asAnyStoryElement() -> FinalCutPro.FCPXML.AnyStoryElement {
        .anyClip(self.asAnyClip())
    }
}

// MARK: - Collection Methods

extension Collection<FinalCutPro.FCPXML.AnyClip> {
    public func contains(_ clip: any FCPXMLClip) -> Bool {
        contains(where: { $0.wrapped.isEqual(to: clip) })
    }
}

extension Dictionary where Value == FinalCutPro.FCPXML.AnyClip {
    public func contains(value clip: any FCPXMLClip) -> Bool {
        values.contains(clip)
    }
}

extension Collection<FCPXMLClip> {
    public func contains(_ clip: FinalCutPro.FCPXML.AnyClip) -> Bool {
        contains(where: { $0.asAnyClip() == clip })
    }
}

extension Dictionary where Value: FCPXMLClip {
    public func contains(value clip: FinalCutPro.FCPXML.AnyClip) -> Bool {
        values.contains(where: { $0.asAnyClip() == clip })
    }
}

#endif
