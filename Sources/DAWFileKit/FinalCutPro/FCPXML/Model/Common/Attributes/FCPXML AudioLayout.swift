//
//  FCPXML AudioLayout.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// `audioLayout` attribute value.
    public enum AudioLayout: String, Equatable, Hashable, CaseIterable {
        case mono
        case stereo
        case surround
    }
}

extension FinalCutPro.FCPXML.AudioLayout: FCPXMLAttribute {
    public static let attributeName: String = "audioLayout"
}

#endif
