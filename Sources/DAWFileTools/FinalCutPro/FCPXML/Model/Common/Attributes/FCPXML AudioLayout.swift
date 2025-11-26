//
//  FCPXML AudioLayout.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// `audioLayout` attribute value.
    public enum AudioLayout: String, Equatable, Hashable, CaseIterable, Sendable {
        case mono
        case stereo
        case surround
    }
}

extension FinalCutPro.FCPXML.AudioLayout: FCPXMLAttribute {
    public static let attributeName: String = "audioLayout"
}

#endif
