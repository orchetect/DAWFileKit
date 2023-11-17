//
//  FCPXML AudioLayout.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// `audioLayout` attribute value.
    public enum AudioLayout: String {
        case mono
        case stereo
        case surround
    }
}

#endif
