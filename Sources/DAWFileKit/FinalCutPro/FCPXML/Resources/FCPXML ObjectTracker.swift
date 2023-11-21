//
//  FCPXML ObjectTracker.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

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
    public struct ObjectTracker: Equatable, Hashable {
        // TODO: xml variable is temporary; finish parsing the xml
        public var xml: XMLElement
    }
}

extension FinalCutPro.FCPXML.ObjectTracker: FCPXMLResource {
    public init?(from xmlLeaf: XMLElement) {
        xml = xmlLeaf
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == resourceType.rawValue else { return nil }
    }
    
    public var resourceType: FinalCutPro.FCPXML.ResourceType { .objectTracker }
    public func asAnyResource() -> FinalCutPro.FCPXML.AnyResource { .objectTracker(self) }
}

#endif
