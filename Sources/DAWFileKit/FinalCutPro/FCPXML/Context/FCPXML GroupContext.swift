//
//  FCPXML GroupContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
@_implementationOnly import OTCore

extension FinalCutPro.FCPXML {
    /// Group context for model elements.
    /// Combines the output of one or more element context builders.
    public struct GroupContext: FCPXMLElementContextBuilder {
        public var contextBuilder: FinalCutPro.FCPXML.ElementContextClosure
        
        public init(_ builders: [FCPXMLElementContextBuilder]) {
            contextBuilder = { xmlLeaf, breadcrumbs, resources, tools in
                builders.reduce(into: [:]) { dict, builder in
                    let context = builder.contextBuilder(xmlLeaf, breadcrumbs, resources, tools)
                    dict.merge(context) { _, _ in true }
                }
            }
        }
    }
}

// MARK: - Static Constructor

extension FCPXMLElementContextBuilder where Self == FinalCutPro.FCPXML.GroupContext {
    /// Default (empty) context for model elements.
    public static func group(_ builders: [FCPXMLElementContextBuilder]) -> FinalCutPro.FCPXML.GroupContext {
        FinalCutPro.FCPXML.GroupContext(builders)
    }
}

#endif
