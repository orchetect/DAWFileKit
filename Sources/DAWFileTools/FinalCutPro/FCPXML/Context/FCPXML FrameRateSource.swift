//
//  FCPXML FrameRateSource.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore
import SwiftExtensions

extension FinalCutPro.FCPXML {
    /// Frame rate source for an extracted element.
    public enum FrameRateSource {
        /// Derive frame rate from main timeline.
        case mainTimeline
        
        /// Derive frame rate from the element's local timeline or closest parent timeline.
        case localToElement
        
        /// Provide an arbitrary frame rate to use.
        ///
        /// This is generally not recommended unless conversion to a different frame rate than the
        /// one used is desired.
        case rate(_ rate: TimecodeFrameRate)
    }
}

extension FinalCutPro.FCPXML.FrameRateSource: Sendable { }

#endif
