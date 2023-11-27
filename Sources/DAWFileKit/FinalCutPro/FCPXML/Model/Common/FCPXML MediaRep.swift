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
        /// The kind of media representation. Either `original-media` or `proxy-media`.
        public var kind: String?
        
        /// The unique identifier of a media representation, assigned by Final Cut Pro.
        public var sig: String?
        
        /// May be a full absolute URL to a local `file://` or remote `https://` resource.
        /// May also be a relative URL based on the location of the FCPXML document itself, for example: "./Media/MyMovie.mov"
        public var src: URL?
        
        /// The filename string to use when Final Cut Pro manages the media representation file.
        ///
        /// See [FCPXML Reference](
        /// https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/asset/media-rep
        /// ) for details.
        public var suggestedFilename: String?
        
        /// Security-scoped bookmark data in a base64-encoded string.
        public var bookmark: String?
        
        public init(
            kind: String? = nil,
            sig: String? = nil,
            src: URL? = nil,
            suggestedFilename: String? = nil,
            bookmark: String? = nil
        ) {
            self.kind = kind
            self.sig = sig
            self.src = src
            self.suggestedFilename = suggestedFilename
            self.bookmark = bookmark
        }
    }
}

extension FinalCutPro.FCPXML.MediaRep {
    public enum Element: String {
        case name = "media-rep"
    }
    
    /// Attributes unique to ``MediaRep``.
    public enum Attributes: String, XMLParsableAttributesKey {
        case kind
        case sig
        case src
        case suggestedFilename
    }
    
    /// Children of ``MediaRep``.
    public enum Children: String {
        case bookmark
    }
    
    public init?(from xmlLeaf: XMLElement) {
        // validate element name
        guard xmlLeaf.name == Element.name.rawValue else { return nil }
        
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        kind = rawValues[.kind]
        sig = rawValues[.sig]
        
        // TODO: handle relative file URLs - probably needs library path passed into this init.
        guard let urlString = rawValues[.src],
              let src = URL(string: urlString)
        else { return nil }
        self.src = src
        
        suggestedFilename = rawValues[.suggestedFilename]
        
        // bookmark is a child string, not an attribute
        bookmark = xmlLeaf.first(childNamed: Children.bookmark.rawValue)?.stringValue
    }
}

extension FinalCutPro.FCPXML.MediaRep {
    /// Returns the `src` filename.
    public func srcFilename() -> String? {
        src?.lastPathComponent
    }
    
    /// Returns the base64-encoded `bookmark` contents as decoded `Data`.
    public func bookmarkData() -> Data? {
        bookmark?.base64DecodedString?.data(using: .utf8)
    }
    
}
#endif
