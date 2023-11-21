//
//  FCPXML AudioRate.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// `audioRate` attribute value.
    /// These are all of the rates that are selectable within Final Cut Pro 10.6.10.
    public enum AudioRate: String, Equatable, Hashable {
        case rate32kHz = "32k"
        case rate44_1kHz = "44.1k"
        case rate48kHz = "48k"
        case rate88_2kHz = "88.2k"
        case rate96kHz = "96k"
        case rate176_4kHz = "176.4k"
        case rate192kHz = "192k"
    }
}

#endif
