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

#endif
