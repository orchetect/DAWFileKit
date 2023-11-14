//
//  FCPXML ClipType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum ClipType: String, CaseIterable {
        /// References a single media asset.
        case assetClip = "asset-clip"
        
        /// References audio data from an `asset` or `effect` element.
        case audio
        
        /// Represents a basic unit of editing.
        case clip
        
        /// Live drawing.
        case liveDrawing = "live-drawing"
        
        /// References a multicam media.
        case mcClip = "mc-clip"
        
        /// References a compound clip media.
        case refClip = "ref-clip"
        
        /// Contains a clip with its contained and anchored items synchronized.
        case syncClip = "sync-clip"
        
        /// Title.
        case title
        
        /// References video data from an `asset` or `effect` element.
        case video
    }
}

#endif
