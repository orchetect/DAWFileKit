//
//  FCPXML ResourceType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Shared resource type.
    public enum ResourceType: String, CaseIterable {
        case asset
        case media
        case format
        case effect
        case locator
        case objectTracker = "object-tracker"
        case trackingShape = "tracking-shape"
    }
}

extension FinalCutPro.FCPXML.ResourceType: FCPXMLElementTypeProtocol {
    public var elementType: FinalCutPro.FCPXML.ElementType {
        .resource(self)
    }
}

#endif
