//
//  FCPXMLClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

public protocol FCPXMLClip: FCPXMLStoryElement {
    /// Returns the clip type enum case.
    var clipType: FinalCutPro.FCPXML.ClipType { get }
    
    /// Returns the clip as ``FinalCutPro/FCPXML/AnyClip``.
    func asAnyClip() -> FinalCutPro.FCPXML.AnyClip
}

extension FCPXMLClip /* : FCPXMLStoryElement */ {
    public var storyElementType: FinalCutPro.FCPXML.StoryElementType {
        .anyClip(clipType)
    }
    
    public func asAnyStoryElement() -> FinalCutPro.FCPXML.AnyStoryElement {
        .anyClip(self.asAnyClip())
    }
}

#endif
