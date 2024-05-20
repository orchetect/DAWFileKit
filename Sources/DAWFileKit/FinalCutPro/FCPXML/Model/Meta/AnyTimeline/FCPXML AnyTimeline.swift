//
//  FCPXML AnyTimeline.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2024 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Type-erased box containing a FCPXML timeline element.
    public enum AnyTimeline: FCPXMLElement {
        case assetClip(AssetClip)
        // case audition(Audition)
        case clip(Clip)
        case gap(Gap)
        // case liveDrawing(LiveDrawing) // TODO: ?
        case mcAngle(Media.Multicam.Angle)
        case mcClip(MCClip)
        case refClip(RefClip)
        case sequence(Sequence)
        case spine(Spine)
        case syncClip(SyncClip)
        case title(Title)
        case video(Video)
        
        public var element: XMLElement {
            switch self {
            case let .assetClip(model): return model.element
            case let .clip(model): return model.element
            case let .gap(model): return model.element
            case let .mcAngle(model): return model.element
            case let .mcClip(model): return model.element
            case let .refClip(model): return model.element
            case let .sequence(model): return model.element
            case let .spine(model): return model.element
            case let .syncClip(model): return model.element
            case let .title(model): return model.element
            case let .video(model): return model.element
            }
        }
        
        public var elementType: ElementType { model.elementType }
        
        public static let supportedElementTypes: Set<ElementType> = .allTimelineCases
        
        public init() {
            // can't instance without knowing what element type it is
            fatalError()
        }
        
        public init?(element: XMLElement) {
            /**/ if let model = element.fcpAsAssetClip { self = .assetClip(model) }
            else if let model = element.fcpAsClip { self = .clip(model) }
            else if let model = element.fcpAsGap { self = .gap(model) }
            else if let model = element.fcpAsMCAngle { self = .mcAngle(model) }
            else if let model = element.fcpAsMCClip { self = .mcClip(model) }
            else if let model = element.fcpAsRefClip { self = .refClip(model) }
            else if let model = element.fcpAsSequence { self = .sequence(model) }
            else if let model = element.fcpAsSpine { self = .spine(model) }
            else if let model = element.fcpAsSyncClip { self = .syncClip(model) }
            else if let model = element.fcpAsTitle { self = .title(model) }
            else if let model = element.fcpAsVideo { self = .video(model) }
            else { return nil }
            
            // technically this is redundant:
            // guard _isElementTypeSupported(element: element) else { return nil }
        }
    }
}

// MARK: - Meta Conformances

extension FinalCutPro.FCPXML.AnyTimeline: FCPXMLElementMetaTimeline { 
    public func asAnyTimeline() -> FinalCutPro.FCPXML.AnyTimeline { self }
}

// MARK: - Properties

extension FinalCutPro.FCPXML.AnyTimeline {
    /// Return the wrapped model object typed as ``FCPXMLElement``.
    public var model: any FCPXMLElement {
        switch self {
        case let .assetClip(model): return model
        case let .clip(model): return model
        case let .gap(model): return model
        case let .mcAngle(model): return model
        case let .mcClip(model): return model
        case let .refClip(model): return model
        case let .sequence(model): return model
        case let .spine(model): return model
        case let .syncClip(model): return model
        case let .title(model): return model
        case let .video(model): return model
        }
    }
}

// MARK: - Typing

// Spine
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/AnyTimeline`` model object
    /// if the element is a timeline object.
    public var fcpAsAnyTimeline: FinalCutPro.FCPXML.AnyTimeline? {
        .init(element: self)
    }
}

#endif
