//
//  FCPXML TrackingShape.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Tracking shape shared resource.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Define a shape that the object-tracker uses to match the movement of an object.
    /// >
    /// > In Final Cut Pro, users can track the shape-mask of a video effect such as a blur,
    /// > highlight, or color effect to a moving object in a video clip.
    /// >
    /// > Use the `tracking-shape` element to define the shape that the object-tracker element uses
    /// > to match the movement of a moving object in a video clip. Each object-tracker element
    /// > consists of one or more tracking shapes.
    /// >
    /// > See [`tracking-shape`](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/tracking-shape
    /// > ).
    public struct TrackingShape: Equatable, Hashable {
        // TODO: xml variable is temporary; finish parsing the xml
        public var xml: XMLElement
    }
}

extension FinalCutPro.FCPXML.TrackingShape: FCPXMLResource {
    public init?(from xmlLeaf: XMLElement) {
        xml = xmlLeaf
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == resourceType.rawValue else { return nil }
    }
    
    public var resourceType: FinalCutPro.FCPXML.ResourceType { .trackingShape }
    public func asAnyResource() -> FinalCutPro.FCPXML.AnyResource { .trackingShape(self) }
}

#endif