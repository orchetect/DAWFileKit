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
        
        public var contents: IntermediateMediaType?
        
        public init(
            id: String,
            name: String?,
            contents: IntermediateMediaType? = nil
        ) {
            self.id = id
            self.name = name
            self.contents = contents
        }
    }
}

extension FinalCutPro.FCPXML.Media: FCPXMLResource {
    /// Attributes unique to ``Media``.
    public enum Attributes: String, XMLParsableAttributesKey {
        case id
        case name
    }
    
    /// Children of ``Media``.
    public enum Children: String {
        case multicam
        case sequence
    }
    
    public init?(from xmlLeaf: XMLElement) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        id = rawValues[.id]
        name = rawValues[.name]
        
        // contents
        if let multicamXML = xmlLeaf.first(childNamed: Children.multicam.rawValue)
        {
            contents = .multicam(fromXML: multicamXML, parentMediaXML: xmlLeaf)
        }
        else if let sequenceXML = xmlLeaf.first(childNamed: Children.sequence.rawValue)
        {
            contents = .sequence(fromXML: sequenceXML, parentMediaXML: xmlLeaf)
        }
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == resourceType.rawValue else { return nil }
    }
    
    public var resourceType: FinalCutPro.FCPXML.ResourceType { .media }
    public func asAnyResource() -> FinalCutPro.FCPXML.AnyResource { .media(self) }
}

extension FinalCutPro.FCPXML.Media {
    public enum IntermediateMediaType: Equatable, Hashable {
        // can't store `FinalCutPro.FCPXML.Multicam` because it requires resources to already have
        // been parsed to construct. so as a workaround we'll store raw XML here so we can
        // parse it later after the complete collection of resources have been parsed.
        case multicam(fromXML: XMLElement, parentMediaXML: XMLElement)
        
        // can't store `FinalCutPro.FCPXML.Sequence` because it requires resources to already have
        // been parsed to construct. so as a workaround we'll store raw XML here so we can
        // parse it later after the complete collection of resources have been parsed.
        case sequence(fromXML: XMLElement, parentMediaXML: XMLElement)
    }
}

extension FinalCutPro.FCPXML.Media {
    // TODO: factor out? RefClip AFAIK can only reference a Media resource containing a Sequence, and MCClip can only reference a Media resource containing a Multicam container.
    public enum MediaType: Equatable, Hashable {
        case multicam(_ multicam: FinalCutPro.FCPXML.Media.Multicam)
        case sequence(_ sequence: FinalCutPro.FCPXML.Sequence)
    }
    
    public func generateMediaType(
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) -> MediaType? {
        guard let mediaContents = contents else { return nil }
        
        switch mediaContents {
        case let .multicam(sequenceXML, parentMediaXML):
            guard let multicam = FinalCutPro.FCPXML.Media.Multicam(
                from: sequenceXML,
                breadcrumbs: breadcrumbs + [parentMediaXML],
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            return .multicam(multicam)
            
        case let .sequence(sequenceXML, parentMediaXML):
            guard let sequence = FinalCutPro.FCPXML.Sequence(
                from: sequenceXML,
                breadcrumbs: breadcrumbs + [parentMediaXML],
                resources: resources,
                contextBuilder: contextBuilder
            ) else { return nil }
            return .sequence(sequence)
        }
    }
}

extension FinalCutPro.FCPXML.Media.MediaType: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        []
    }
    
    public func extractableChildren() -> [FinalCutPro.FCPXML.AnyElement] {
        switch self {
        case let .multicam(multicam):
            // `Multicam` doesn't conform to FCPXMLElement and can't be wrapped with AnyElement
            return multicam.extractableChildren()
            
        case let .sequence(sequence):
            return [sequence.asAnyElement()]
        }
    }
}

extension FinalCutPro.FCPXML.Media {
    /// A multi-camera element contains one or more `mc-angle` elements that each manage a series of
    /// other story elements.
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
    }
}

extension FinalCutPro.FCPXML.Media.Multicam {
    public enum Attributes: String, XMLParsableAttributesKey {
        case format
    }
    
    public enum Children: String {
        case mcAngle = "mc-angle"
    }
    
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        // validate element name
        guard xmlLeaf.name == FinalCutPro.FCPXML.Media.Children.multicam.rawValue
        else { return nil }
        
        format = rawValues[.format]
        
        // angles
        angles = Self.parseAngles( // adds xmlLeaf as breadcrumb
            in: xmlLeaf,
            breadcrumbs: breadcrumbs,
            resources: resources,
            contextBuilder: contextBuilder
        )
    }
}

extension FinalCutPro.FCPXML.Media.Multicam: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        []
    }
    
    public func extractableChildren() -> [FinalCutPro.FCPXML.AnyElement] {
        // `Multicam.Angle` doesn't conform to FCPXMLElement and can't be wrapped with AnyElement
        angles.flatMap { $0.contents.asAnyElements() }
    }
}

extension FinalCutPro.FCPXML.Media.Multicam {
    /// A container of story elements organized sequentially in time.
    /// Similar to a `sequence`.
    public struct Angle: Equatable, Hashable {
        /// Angle name.
        public var name: String?
        
        /// Specifies the angle.
        public var angleID: String?
        
        // can't store model story elements because they require resources to already have
        // been parsed to construct. so as a workaround we'll store raw XML here so we can
        // parse it later after the complete collection of resources have been parsed.
        /// Story elements contained in the angle.
        public var contents: [FinalCutPro.FCPXML.AnyStoryElement]
        
        /// Indicates which source to use, if any, from the angle.
        /// Use one of the following: `audio`, `video`, `all`, or `none`.
        public var srcEnable: String?
        
        public init(
            name: String? = nil,
            angleID: String? = nil,
            contents: [FinalCutPro.FCPXML.AnyStoryElement] = [],
            srcEnable: String? = nil
        ) {
            self.name = name
            self.angleID = angleID
            self.contents = contents
            self.srcEnable = srcEnable
        }
    }
    
    static func parseAngles(
        in xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) -> [Angle] {
        let angleChildren = xmlLeaf.children?
            .filter { $0.name == Children.mcAngle.rawValue }
            .compactMap { $0 as? XMLElement }
        ?? []
        
        let angles = angleChildren.compactMap {
            Angle(
                from: $0,
                breadcrumbs: breadcrumbs + [xmlLeaf],
                resources: resources,
                contextBuilder: contextBuilder
            )
        }
        return angles
    }
}

extension FinalCutPro.FCPXML.Media.Multicam.Angle {
    public enum Attributes: String, XMLParsableAttributesKey {
        case name
        case angleID
        case srcEnable
    }
    
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        // validate element name
        guard xmlLeaf.name == FinalCutPro.FCPXML.Media.Multicam.Children.mcAngle.rawValue
        else { return nil }
        
        name = rawValues[.name]
        angleID = rawValues[.angleID]
        srcEnable = rawValues[.srcEnable]
        
        contents = FinalCutPro.FCPXML.storyElements( // adds xmlLeaf as breadcrumb
            in: xmlLeaf,
            breadcrumbs: breadcrumbs,
            resources: resources,
            contextBuilder: contextBuilder
        )
    }
}

#endif
