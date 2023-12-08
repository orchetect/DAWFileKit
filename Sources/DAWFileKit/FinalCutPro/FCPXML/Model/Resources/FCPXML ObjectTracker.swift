//
//  FCPXML ObjectTracker.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

extension FinalCutPro.FCPXML {
    /// Object tracker shared resource.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Describe a tracked object such as a face or other moving object in a video clip.
    /// >
    /// > Users can track moving objects in video clips to match their movement to a clip, title,
    /// > logo, generator, or a still image, by using the object-tracker feature in Final Cut Pro.
    /// > They can also track the shape mask of a video effect, for example a blur, highlight, or
    /// > color effect, to a moving object in a video clip.
    /// >
    /// > See [`object-tracker`](https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/object-tracker).
    public struct ObjectTracker: FCPXMLElement {
        public let element: XMLElement
        
        // Children
        
        /// Returns child `tracking-shape` elements.
        public var trackingShapes: LazyCompactMapSequence<[XMLNode], XMLElement> {
            element.childElements
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.ObjectTracker {
    public static let resourceType: FinalCutPro.FCPXML.ResourceType = .objectTracker
    
    // no Attributes
    
    // contains 1 or more `tracking-shape`
}

extension XMLElement { // ObjectTracker
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/ObjectTracker`` model object.
    /// Call this on a `object-tracker` element only.
    public var fcpAsObjectTracker: FinalCutPro.FCPXML.ObjectTracker {
        .init(element: self)
    }
}

#endif
