//
//  FCPXML TimecodeFormat.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// "tcFormat" attribute.
    public enum TimecodeFormat: String {
        case dropFrame = "DF"
        case nonDropFrame = "NDF"
    }
}

extension FinalCutPro.FCPXML.TimecodeFormat {
    public enum Attributes: String {
        case tcFormat
    }
    
    public var isDrop: Bool {
        switch self {
        case .dropFrame: return true
        case .nonDropFrame: return false
        }
    }
}

#endif
