//
//  FCPXML Sequence StoryElementType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum StoryElementType: String {
        /// Represents a basic unit of editing.
        case clip
        
        /// References a single media asset.
        case assetClip = "asset-clip"
        
        /// Contains a clip with its contained and anchored items synchronized.
        case syncClip = "sync-clip"
        
        /// References audio data from an `asset` or `effect` element.
        case audio
        
        /// References video data from an `asset` or `effect` element.
        case video
        
        /// References a multicam media.
        case mcClip
        
        /// References a compound clip media.
        case refClip
        
        /// Defines a placeholder element that has no intrinsic audio or video data.
        case gap
        
        /// Contains elements ordered sequentially in time.
        case spine
        
        /// Contains one active story element followed by alternative story elements in the audition
        /// container.
        case audition
        
        /// A container that represents the top-level sequence for a Final Cut Pro project or
        /// compound clip.
        case sequence
        
        // note: `title` is not a story element, but rather an effect element.
    }
}

#endif
