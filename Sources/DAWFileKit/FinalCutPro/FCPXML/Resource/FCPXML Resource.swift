//
//  FCPXML Resource.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Resource
    public enum Resource: Equatable, Hashable {
        case asset(Asset)
        case effect(Effect)
        case format(Format)
        
        // TODO: additional resource types need to be added
    }
}

extension FinalCutPro.FCPXML.Resource {
    public enum ResourceType: String {
        case asset
        case effect
        case format
        
        // TODO: additional resource types need to be added
    }
}
#endif
