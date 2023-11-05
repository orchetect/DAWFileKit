//
//  FCPXML AnyResource.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Type-erased container for a shared resource.
    public enum AnyResource: Equatable, Hashable {
        case asset(Asset)
        case effect(Effect)
        case format(Format)
        
        // TODO: additional resource types need to be added
    }
}

extension FinalCutPro.FCPXML.AnyResource {
    /// Shared resource type.
    public enum ResourceType: String {
        case asset
        case effect
        case format
        
        // TODO: additional resource types need to be added
    }
}
#endif
