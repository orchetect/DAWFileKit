//
//  FCPXML Sequence StoryElementType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum StoryElementType: String {
        /// Contains one active story element followed by alternative story elements in the audition
        /// container.
        case audition
        
        /// Defines a placeholder element that has no intrinsic audio or video data.
        case gap
        
        /// A container that represents the top-level sequence for a Final Cut Pro project or
        /// compound clip.
        case sequence
        
        /// Contains elements ordered sequentially in time.
        case spine
    }
}

#endif
