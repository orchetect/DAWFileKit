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
        public let role: String?
        
        // FCPXMLAnchorableAttributes
        public let lane: Int?
        public let offset: Timecode?
        
        // FCPXMLClipAttributes
        public let name: String?
        public let start: Timecode?
        public let duration: Timecode?
        public let enabled: Bool
        
        internal init(
            ref: String,
            role: String?,
            // FCPXMLAnchorableAttributes
            lane: Int?,
            offset: Timecode?,
            // FCPXMLClipAttributes
            name: String?,
            start: Timecode?,
            duration: Timecode?,
            enabled: Bool
        ) {
            self.ref = ref
            self.role = role
            
            // FCPXMLAnchorableAttributes
            self.lane = lane
            self.offset = offset
            
            // FCPXMLClipAttributes
            self.name = name
            self.start = start // TODO: not used?
            self.duration = duration
            self.enabled = enabled
        }
    }
}

extension FinalCutPro.FCPXML.Video: FCPXMLClipAttributes {
    /// Attributes unique to Video clip.
    public enum Attributes: String {
        case ref // resource ID
        case role
    }
    
    internal init(
        from xmlLeaf: XMLElement,
        frameRate: TimecodeFrameRate
    ) {
        ref = FinalCutPro.FCPXML.getRefAttribute(from: xmlLeaf) ?? "" // TODO: error condition?
        role = xmlLeaf.attributeStringValue(forName: Attributes.role.rawValue)
        
        let clipAttributes = Self.parseClipAttributes(
            frameRate: frameRate,
            from: xmlLeaf
        )
        
        // FCPXMLAnchorableAttributes
        lane = clipAttributes.lane
        offset = clipAttributes.offset
        
        // FCPXMLClipAttributes
        name = FinalCutPro.FCPXML.getNameAttribute(from: xmlLeaf)
        start = clipAttributes.start
        duration = clipAttributes.duration
        enabled = clipAttributes.enabled
    }
}

#endif
