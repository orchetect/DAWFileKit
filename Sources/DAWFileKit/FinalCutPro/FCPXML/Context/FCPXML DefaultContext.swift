//
//  FCPXML DefaultContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Default (empty) context for model elements.
    public struct DefaultContext: FCPXMLElementContextBuilder {
        public var contextBuilder: FinalCutPro.FCPXML.ElementContextClosure {
            { _, _, _ in
                [:]
            }
        }
        
        public init() { }
    }
}

// MARK: - Static Constructor

extension FCPXMLElementContextBuilder where Self == FinalCutPro.FCPXML.DefaultContext {
    /// Default (empty) context for model elements.
    public static var `default`: FinalCutPro.FCPXML.DefaultContext {
        FinalCutPro.FCPXML.DefaultContext()
    }
}

#endif
