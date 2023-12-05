//
//  FCPXML MediaRep.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
@_implementationOnly import OTCore

extension FinalCutPro.FCPXML {
    /// Media representation.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > References a media representation, that is either the original or a proxy media managed by
    /// > Final Cut Pro.
    /// >
    /// > A media that Final Cut Pro manages in its library can have a proxy media representation,
    /// > in addition to the original media representation. Use the media-rep element to describe a
    /// > media representation, as a child element of the asset element.
    public struct MediaRep: Equatable, Hashable {
        public let element: XMLElement
        
        /// The kind of media representation.
        /// Default: `original-media`
        public var kind: Kind { // only used in `media-rep`
            get {
                let defaultValue: Kind = .originalMedia
                
                guard let value = element.stringValue(forAttributeNamed: Attributes.kind.rawValue)
                else { return defaultValue }
                
                return Kind(rawValue: value) ?? defaultValue
            }
            set {
                element.addAttribute(withName: Attributes.kind.rawValue, value: newValue.rawValue)
            }
        }
        
        /// The unique identifier of a media representation, assigned by Final Cut Pro.
        public var sig: String?
        
        /// Required.
        /// May be a full absolute URL to a local `file://` or remote `https://` resource.
        /// May also be a relative URL based on the location of the FCPXML document itself, for example: `./Media/MyMovie.mov`.
        public var src: URL? {
            get { element.getURL(forAttribute: Attributes.src.rawValue) }
            set { element.set(url: newValue, forAttribute: Attributes.src.rawValue) }
        }
        
        /// The filename string to use when Final Cut Pro manages the media representation file.
        ///
        /// Used when the filename should not be derived from the URL. The appropriate extension
        /// should be included.
        ///
        /// See [FCPXML Reference](
        /// https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/asset/media-rep
        /// ) for details.
        public var suggestedFilename: String? {
            get { element.stringValue(forAttributeNamed: Attributes.suggestedFilename.rawValue) }
            set { element.addAttribute(withName: Attributes.suggestedFilename.rawValue, value: newValue) }
        }
        
        // Children
        
        /// Security-scoped bookmark data in a base64-encoded string.
        /// Access the `stringValue` property on the returned element.
        public var bookmark: XMLElement? {
            element.firstChildElement(named: Children.bookmark.rawValue)
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.MediaRep {
    public enum Element: String {
        case name = "media-rep"
    }
    
    public enum Attributes: String, XMLParsableAttributesKey {
        /// The kind of media representation.
        /// Default: `original-media`
        case kind
        
        /// The unique identifier of a media representation, assigned by Final Cut Pro.
        case sig
        
        /// Required.
        /// May be a full absolute URL to a local `file://` or remote `https://` resource.
        /// May also be a relative URL based on the location of the FCPXML document itself, for example: `./Media/MyMovie.mov`.
        case src
        
        /// The filename string to use when Final Cut Pro manages the media representation file.
        ///
        /// See [FCPXML Reference](
        /// https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/asset/media-rep
        /// ) for details.
        case suggestedFilename
    }
    
    /// Children of ``MediaRep``.
    public enum Children: String {
        case bookmark
    }
}

extension FinalCutPro.FCPXML.MediaRep {
    /// Convenience to returns the `src` filename.
    public func srcFilename() -> String? {
        src?.lastPathComponent
    }
    
    /// Convenience to return the base64-encoded `bookmark` contents as decoded `Data`.
    public func bookmarkData() -> Data? {
        bookmark?.stringValue?.base64DecodedString?.data(using: .utf8)
    }
}

// MARK: - MediaRep Attribute: Kind

extension FinalCutPro.FCPXML.MediaRep {
    public enum Kind: String, Equatable, Hashable, CaseIterable, Sendable {
        case originalMedia = "original-media"
        case proxyMedia = "proxy-media"
    }
}

#endif
