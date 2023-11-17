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

extension FinalCutPro.FCPXML.AnyResource: FCPXMLResource {
    public init?(from xmlLeaf: XMLElement) {
        guard let name = xmlLeaf.name else { return nil }
        guard let resourceType = FinalCutPro.FCPXML.ResourceType(rawValue: name) else {
            print("Unrecognized FCPXML resource type: \(name)")
            return nil
        }
        
        switch resourceType {
        case .asset:
            guard let res = FinalCutPro.FCPXML.Asset(from: xmlLeaf) else { return nil }
            self = .asset(res)
        case .media:
            guard let res = FinalCutPro.FCPXML.Media(from: xmlLeaf) else { return nil }
            self = .media(res)
        case .format:
            guard let res = FinalCutPro.FCPXML.Format(from: xmlLeaf) else { return nil }
            self = .format(res)
        case .effect:
            guard let res = FinalCutPro.FCPXML.Effect(from: xmlLeaf) else { return nil }
            self = .effect(res)
        case .locator:
            guard let res = FinalCutPro.FCPXML.Locator(from: xmlLeaf) else { return nil }
            self = .locator(res)
        case .objectTracker:
            guard let res = FinalCutPro.FCPXML.ObjectTracker(from: xmlLeaf) else { return nil }
            self = .objectTracker(res)
        case .trackingShape:
            guard let res = FinalCutPro.FCPXML.TrackingShape(from: xmlLeaf) else { return nil }
            self = .trackingShape(res)
        }
    }
    
    public var resourceType: FinalCutPro.FCPXML.ResourceType { wrapped.resourceType }
    
    /// Redundant, but required to fulfill `FCPXMLResource` protocol requirements.
    public func asAnyResource() -> FinalCutPro.FCPXML.AnyResource { self }
}

extension FinalCutPro.FCPXML.AnyResource {
    /// Returns the unwrapped resource typed as ``FCPXMLResource``.
    public var wrapped: any FCPXMLResource {
        switch self {
        case let .asset(resource): return resource
        case let .media(resource): return resource
        case let .format(resource): return resource
        case let .effect(resource): return resource
        case let .locator(resource): return resource
        case let .objectTracker(resource): return resource
        case let .trackingShape(resource): return resource
        }
    }
}

#endif
