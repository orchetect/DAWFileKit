//
//  FCPXML TimecodeFormat.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// `tcFormat` attribute value.
    public enum TimecodeFormat: String, Equatable, Hashable {
        case dropFrame = "DF"
        case nonDropFrame = "NDF"
    }
}

extension FinalCutPro.FCPXML.TimecodeFormat {
    /// Returns `true` if format is drop-frame.
    public var isDrop: Bool {
        switch self {
        case .dropFrame: return true
        case .nonDropFrame: return false
        }
    }
}

#endif
