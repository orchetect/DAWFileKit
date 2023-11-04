//
//  FCPXML Sequence ClipType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum ClipType: String {
        case assetClip = "asset-clip"
        case title
        case video
        
        // TODO: add additional clip types
    }
}

#endif
