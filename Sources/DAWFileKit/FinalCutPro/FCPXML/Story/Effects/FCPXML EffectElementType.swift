//
//  FCPXML EffectElementType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    // TODO: will likely factor this out, as it does not align with the DTD's structure.
    
    // public enum EffectElementType: String, CaseIterable {
    //     /// Applies transition effects that either stand by itself (no neighboring elements),
    //     /// combine two neighboring elements, or apply to a single element.
    //     ///
    //     /// Transition effect applies to elements contained in a spine or `mc-angle`. Use the
    //     /// `offset` and duration attributes to define the position and extent of the transition
    //     /// effect. The `filter-video` and `filter-audio` elements specify the effect to apply.
    //     case transition
    // 
    //     /// Represents a title with one or more text blocks.
    //     ///
    //     /// A `title` element contains one or more text elements, each of which describes a block of
    //     /// text with custom styles.
    //     case title
    // 
    //     /// Represents a closed-caption or subtitle with one or more text blocks.
    //     ///
    //     /// A `caption` element contains one or more text elements each of which describes a block
    //     /// of text with custom styles.
    //     case caption
    // 
    //     /// A filter element that references an audio effect.
    //     ///
    //     /// Apply audio filters to elements that represent audible media, for example, `audio`,
    //     /// `clip`, `ref-clip`, `audio-source`, and `audio-aux-source` elements. For multicam clips,
    //     /// apply the audio filters to the entire multicam clip, represented by `mc-clip` elements.
    //     case filterAudio = "filter-audio"
    // 
    //     /// A filter element that references a video effect.
    //     ///
    //     /// Apply video filters to elements that represent visual media, for example, `video`,
    //     /// `text`, `clip`, and `ref-clip` elements. For multicam clips, apply the video filters on
    //     /// the individual angles, represented by `mc-source` elements.
    //     case filterVideo = "filter-video"
    // 
    //     // TODO: add additional types
    // }
}

#endif
