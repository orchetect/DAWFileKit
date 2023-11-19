//
//  FCPXML Media.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Media shared resource.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Describe a compound clip or a multi-camera media definition.
    /// >
    /// > A `media` element describes the construction of a compound clip media or a multicam media.
    /// > Use the `sequence` element to describe a compound clip media, and the `multicam` element
    /// > to describe a multicam media.
    /// >
    /// > See [`media`](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/media
    /// > ).
    public struct Media: Equatable, Hashable {
        public var id: String?
        public var name: String?
        
        public var contents: MediaType?
        
        public init(
            id: String,
            name: String?,
            contents: MediaType? = nil
        ) {
            self.id = id
            self.name = name
            self.contents = contents
        }
    }
}

extension FinalCutPro.FCPXML.Media: FCPXMLResource {
    /// Attributes unique to ``Media``.
    public enum Children: String {
        case multicam
        case sequence
    }
    
    public init?(from xmlLeaf: XMLElement) {
        id = FinalCutPro.FCPXML.getIDAttribute(from: xmlLeaf)
        name = FinalCutPro.FCPXML.getNameAttribute(from: xmlLeaf)
        
        // contents
        if let multicamXML = xmlLeaf.first(childNamed: Children.multicam.rawValue),
           let mc = Multicam(from: multicamXML)
        {
            contents = .multicam(mc)
        }
        else if let sequenceXML = xmlLeaf.first(childNamed: Children.sequence.rawValue)
        {
            contents = .sequence(fromXML: sequenceXML)
        }
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == resourceType.rawValue else { return nil }
    }
    
    public var resourceType: FinalCutPro.FCPXML.ResourceType { .media }
    public func asAnyResource() -> FinalCutPro.FCPXML.AnyResource { .media(self) }
}

extension FinalCutPro.FCPXML.Media {
    public enum MediaType: Equatable, Hashable {
        case multicam(Multicam)
        
        // can't store FinalCutPro.FCPXML.Sequence because it requires resources to already have
        // been parsed to construct. so as a workaround we'll store raw XML here so we can
        // parse it later after the complete collection of resources have been parsed.
        case sequence(fromXML: XMLElement)
    }
}

extension FinalCutPro.FCPXML.Media {
    /// A multicam element contains one or more mc-angle elements that each manage a series of other story elements.
    public struct Multicam: Equatable, Hashable {
        public var format: String?
        
        /// Containers of story elements organized sequentially in time.
        public var angles: [Angle]
        
        public init(
            format: String? = nil,
            angles: [Angle] = []
        ) {
            self.format = format
            self.angles = angles
        }
        
        public enum Attributes: String {
            case format
        }
        
        public enum Children: String {
            case mcAngle = "mc-angle"
        }
        
        public init?(from xmlLeaf: XMLElement) {
            // validate element name
            guard xmlLeaf.name == FinalCutPro.FCPXML.Media.Children.multicam.rawValue
            else { return nil }
            
            format = xmlLeaf.attributeStringValue(forName: Attributes.format.rawValue)
            
            // angles
            let angleChildren = xmlLeaf.children?
                .filter {
                    $0.name == Children.mcAngle.rawValue
                }
                .compactMap { $0 as? XMLElement }
            ?? []
            angles = angleChildren.compactMap { Angle(from: $0) }
        }
    }
}

extension FinalCutPro.FCPXML.Media.Multicam {
    /// A container of story elements organized sequentially in time.
    public struct Angle: Equatable, Hashable {
        /// Angle name.
        public var name: String?
        
        /// Specifies the angle.
        public var angleID: String?
        
        // can't store model story elements because they require resources to already have
        // been parsed to construct. so as a workaround we'll store raw XML here so we can
        // parse it later after the complete collection of resources have been parsed.
        /// Story elements contained in the angle.
        public var contents: [XMLElement]
        
        /// Indicates which source to use, if any, from the angle.
        /// Use one of the following: `audio`, `video`, `all`, or `none`.
        public var srcEnable: String?
        
        public init(
            name: String? = nil,
            angleID: String? = nil,
            contents: [XMLElement] = [],
            srcEnable: String? = nil
        ) {
            self.name = name
            self.angleID = angleID
            self.contents = contents
            self.srcEnable = srcEnable
        }
        
        public enum Attributes: String {
            case name
            case angleID
            case srcEnable
        }
        
        public init?(from xmlLeaf: XMLElement) {
            // validate element name
            guard xmlLeaf.name == FinalCutPro.FCPXML.Media.Multicam.Children.mcAngle.rawValue
            else { return nil }
            
            name = FinalCutPro.FCPXML.getNameAttribute(from: xmlLeaf)
            angleID = xmlLeaf.attributeStringValue(forName: Attributes.angleID.rawValue)
            srcEnable = xmlLeaf.attributeStringValue(forName: Attributes.srcEnable.rawValue)
            
            contents = (xmlLeaf.children ?? []).compactMap { $0 as? XMLElement }
        }
    }
}

#endif
