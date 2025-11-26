//
//  FCPXML ObjectTracker TrackingShape.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML.ObjectTracker {
    /// Tracking shape used by an object tracker resource.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Define a shape that the `object-tracker` uses to match the movement of an object.
    /// >
    /// > In Final Cut Pro, users can track the `shape-mask` of a video effect such as a blur,
    /// > highlight, or color effect to a moving object in a video clip.
    /// >
    /// > Use the `tracking-shape` element to define the shape that the `object-tracker` element
    /// > uses to match the movement of a moving object in a video clip. Each `object-tracker`
    /// > element consists of one or more tracking shapes.
    /// >
    /// > See [`tracking-shape`](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/tracking-shape
    /// > ).
    public struct TrackingShape: FCPXMLElement {
        public let element: XMLElement
        
        public let elementType: FinalCutPro.FCPXML.ElementType = .trackingShape
        
        public static let supportedElementTypes: Set<FinalCutPro.FCPXML.ElementType> = [.trackingShape]
        
        public init() {
            element = XMLElement(name: elementType.rawValue)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementTypeSupported(element: element) else { return nil }
        }
    }
}

// MARK: - Parameterized init

extension FinalCutPro.FCPXML.ObjectTracker.TrackingShape {
    // TODO: add init after adding attribute properties
}

// MARK: - Structure

extension FinalCutPro.FCPXML.ObjectTracker.TrackingShape {
    public enum Attributes: String {
        case id // required
        case name
        case offsetEnabled // 0 or 1, Default: 0
        case analysisMethod // enum case
        case dataLocator
    }
    
}

// MARK: - Attributes

// TODO: Add attributes etc.

// MARK: - Typing

// ObjectTracker.TrackingShape
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/ObjectTracker/TrackingShape``
    /// model object.
    /// Call this on a `tracking-shape` element only.
    public var fcpAsTrackingShape: FinalCutPro.FCPXML.ObjectTracker.TrackingShape? {
        .init(element: self)
    }
}

#endif
