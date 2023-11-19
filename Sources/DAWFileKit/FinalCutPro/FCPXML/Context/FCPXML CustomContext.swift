//
//  FCPXML CustomContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Custom context for a model element.
    public struct CustomContext: FCPXMLElementContextBuilder {
        public var contextBuilder: FinalCutPro.FCPXML.ElementContextClosure
        
        public init(contextBuilder: @escaping FinalCutPro.FCPXML.ElementContextClosure) {
            self.contextBuilder = contextBuilder
        }
    }
}

#endif
