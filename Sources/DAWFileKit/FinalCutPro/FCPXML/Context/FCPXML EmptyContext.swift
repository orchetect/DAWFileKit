//
//  FCPXML EmptyContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Empty context for a model element.
    public struct EmptyContext: FCPXMLElementContextBuilder {
        public let contextBuilder: FinalCutPro.FCPXML.ElementContextClosure = { _, _, _, _ in [:] }
        
        public init() { }
    }
}

// MARK: - Static Constructor

extension FCPXMLElementContextBuilder where Self == FinalCutPro.FCPXML.EmptyContext {
    /// Empty context for model elements.
    public static var empty: FinalCutPro.FCPXML.EmptyContext {
        FinalCutPro.FCPXML.EmptyContext()
    }
}

#endif
