//
//  FCPXML ClipType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum ClipType: String, CaseIterable {
        /// References audio data from an `asset` or `effect` element.
        case audio
        
        /// References video data from an `asset` or `effect` element.
        case video
        
        /// Represents a basic unit of editing.
        case clip
        
        /// Title.
        case title
        
        /// References a multicam media.
        case mcClip = "mc-clip"
        
        /// References a compound clip media.
        case refClip = "ref-clip"
        
        /// Contains a clip with its contained and anchored items synchronized.
        case syncClip = "sync-clip"
        
        /// References a single media asset.
        case assetClip = "asset-clip"
        
        /// Contains one active story element followed by alternative story elements in the audition
        /// container.
        case audition
        
        /// Defines a placeholder element that has no intrinsic audio or video data.
        case gap
        
        case liveDrawing = "live-drawing"
    }
}

#endif
