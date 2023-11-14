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
    init?(
        from xmlLeaf: XMLElement
    ) {
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
            let res = FinalCutPro.FCPXML.Media(from: xmlLeaf)
            self = .media(res)
        case .format:
            guard let res = FinalCutPro.FCPXML.Format(from: xmlLeaf) else { return nil }
            self = .format(res)
        case .effect:
            guard let res = FinalCutPro.FCPXML.Effect(from: xmlLeaf) else { return nil }
            self = .effect(res)
        case .locator:
            let res = FinalCutPro.FCPXML.Locator(from: xmlLeaf)
            self = .locator(res)
        case .objectTracker:
            let res = FinalCutPro.FCPXML.ObjectTracker(from: xmlLeaf)
            self = .objectTracker(res)
        case .trackingShape:
            let res = FinalCutPro.FCPXML.TrackingShape(from: xmlLeaf)
            self = .trackingShape(res)
        }
    }
}

// MARK: - Collection Methods
// TODO: refactor using new `FCPXMLResource` protocol and generics

extension Collection<FinalCutPro.FCPXML.AnyResource> {
    public func contains(_ resource: FinalCutPro.FCPXML.Asset) -> Bool {
        contains(where: { element in
            if case let .asset(rsc) = element { return resource == rsc }
            return false
        })
    }
    
    public func contains(_ resource: FinalCutPro.FCPXML.Media) -> Bool {
        contains(where: { element in
            if case let .media(rsc) = element { return resource == rsc }
            return false
        })
    }
    
    public func contains(_ resource: FinalCutPro.FCPXML.Format) -> Bool {
        contains(where: { element in
            if case let .format(rsc) = element { return resource == rsc }
            return false
        })
    }
    
    public func contains(_ resource: FinalCutPro.FCPXML.Effect) -> Bool {
        contains(where: { element in
            if case let .effect(rsc) = element { return resource == rsc }
            return false
        })
    }
    
    public func contains(_ resource: FinalCutPro.FCPXML.Locator) -> Bool {
        contains(where: { element in
            if case let .locator(rsc) = element { return resource == rsc }
            return false
        })
    }
    
    public func contains(_ resource: FinalCutPro.FCPXML.ObjectTracker) -> Bool {
        contains(where: { element in
            if case let .objectTracker(rsc) = element { return resource == rsc }
            return false
        })
    }
    
    public func contains(_ resource: FinalCutPro.FCPXML.TrackingShape) -> Bool {
        contains(where: { element in
            if case let .trackingShape(rsc) = element { return resource == rsc }
            return false
        })
    }
}

extension Dictionary where Value == FinalCutPro.FCPXML.AnyResource {
    public func contains(_ resource: FinalCutPro.FCPXML.Asset) -> Bool {
        values.contains(resource)
    }
    
    public func contains(_ resource: FinalCutPro.FCPXML.Media) -> Bool {
        values.contains(resource)
    }
    
    public func contains(_ resource: FinalCutPro.FCPXML.Format) -> Bool {
        values.contains(resource)
    }
    
    public func contains(_ resource: FinalCutPro.FCPXML.Effect) -> Bool {
        values.contains(resource)
    }
    
    public func contains(_ resource: FinalCutPro.FCPXML.Locator) -> Bool {
        values.contains(resource)
    }
    
    public func contains(_ resource: FinalCutPro.FCPXML.ObjectTracker) -> Bool {
        values.contains(resource)
    }
    
    public func contains(_ resource: FinalCutPro.FCPXML.TrackingShape) -> Bool {
        values.contains(resource)
    }
}

#endif
