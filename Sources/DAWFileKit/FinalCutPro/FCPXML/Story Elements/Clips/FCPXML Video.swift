//
//  FCPXML Video.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    // <video ref="r7" offset="869600/2500s" name="Clouds" start="3600s" duration="250300/2500s" role="Sample Role.Sample Role-1">
    /// Video Clip.
    public struct Video: FCPXMLStoryElement {
        public let ref: String // resource ID
        public let name: String
        
        // FCPXMLTimingAttributes
        public let offset: Timecode
        public let start: Timecode
        public let duration: Timecode
        
        public let role: String
        
        internal init(
            ref: String,
            name: String,
            offset: Timecode,
            start: Timecode,
            duration: Timecode,
            role: String
        ) {
            self.ref = ref
            self.name = name
            self.offset = offset
            self.start = start
            self.duration = duration
            self.role = role
        }
    }
}

extension FinalCutPro.FCPXML.Video: FCPXMLTimingAttributes {
    /// Video clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case name
        // case offset // handled with FCPXMLTimingAttributes
        // case start // handled with FCPXMLTimingAttributes
        // case duration // handled with FCPXMLTimingAttributes
        case role
    }
    
    internal init(
        from xmlLeaf: XMLElement,
        frameRate: TimecodeFrameRate,
        resources: [String: FinalCutPro.FCPXML.Resource]
    ) {
        // `ref`
        ref = FinalCutPro.FCPXML.AnyStoryElement.getRef(from: xmlLeaf)
        
        // `name`
        name = FinalCutPro.FCPXML.AnyStoryElement.getName(from: xmlLeaf)
        
        let timingAttributes = Self.parseTimingAttributesDefaulted(
            frameRate: frameRate,
            from: xmlLeaf,
            resources: resources
        )
        
        // `offset`
        offset = timingAttributes.offset
        
        // `start`
        start = timingAttributes.start
        
        // `duration`
        duration = timingAttributes.duration
        
        // `role`
        role = xmlLeaf.attributeStringValue(forName: Attributes.role.rawValue) ?? ""
    }
}

#endif
