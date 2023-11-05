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
        case media(Media)
        case format(Format)
        case effect(Effect)
        case locator(Locator)
        case objectTracker(ObjectTracker)
        case trackingShape(TrackingShape)
    }
}

extension FinalCutPro.FCPXML.AnyResource {
    /// Shared resource type.
    public enum ResourceType: String {
        case asset
        case media
        case format
        case effect
        case locator
        case objectTracker = "object-tracker"
        case trackingShape = "tracking-shape"
    }
}

#endif
