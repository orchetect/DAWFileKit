//
//  FCPXML TrackingShape.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

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
    public enum TrackingShape { }
}

extension FinalCutPro.FCPXML.TrackingShape {
    // TODO: Add attributes etc.
    
    public static let resourceType: FinalCutPro.FCPXML.ResourceType = .trackingShape
}

#endif
