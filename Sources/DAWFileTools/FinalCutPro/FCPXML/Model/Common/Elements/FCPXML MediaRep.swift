//
//  FCPXML MediaRep.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftTimecodeCore
import SwiftExtensions

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
        
        public let elementType: ElementType = .mediaRep
        
        public static let supportedElementTypes: Set<ElementType> = [.mediaRep]
        
        public init() {
            element = XMLElement(name: elementType.rawValue)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementTypeSupported(element: element) else { return nil }
        }
    }
}

// MARK: - Parameterized init

extension FinalCutPro.FCPXML.MediaRep {
    public init(
        kind: Kind = .originalMedia,
        sig: String? = nil,
        src: URL? = nil,
        suggestedFilename: String? = nil,
        bookmark: Data? = nil
    ) {
        self.init()
        
        self.kind = kind
        self.sig = sig
        self.src = src
        self.suggestedFilename = suggestedFilename
        self.bookmarkData = bookmark
    }
    
    public init(
        kind: Kind = .originalMedia,
        sig: String? = nil,
        src: URL? = nil,
        suggestedFilename: String? = nil,
        bookmark: String
    ) {
        self.init()
        
        self.kind = kind
        self.sig = sig
        self.src = src
        self.suggestedFilename = suggestedFilename
        self.bookmarkData = bookmark.data(using: .utf8)
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.MediaRep {
    public enum Attributes: String {
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
    
    // can contain one bookmark
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.MediaRep {
    /// The kind of media representation.
    /// Default: `original-media`
    public var kind: Kind { // only used in `media-rep`
        get {
            let defaultValue: Kind = .originalMedia
            
            guard let value = element.stringValue(forAttributeNamed: Attributes.kind.rawValue)
            else { return defaultValue }
            
            return Kind(rawValue: value) ?? defaultValue
        }
        nonmutating set {
            element.addAttribute(withName: Attributes.kind.rawValue, value: newValue.rawValue)
        }
    }
    
    /// The unique identifier of a media representation, assigned by Final Cut Pro.
    public var sig: String? {
        get { element.stringValue(forAttributeNamed: Attributes.sig.rawValue) }
        nonmutating set { element.addAttribute(withName: Attributes.sig.rawValue, value: newValue) }
    }
    
    /// Required.
    /// May be a full absolute URL to a local `file://` or remote `https://` resource.
    /// May also be a relative URL based on the location of the FCPXML document itself, for example: `./Media/MyMovie.mov`.
    public var src: URL? {
        get { element.getURL(forAttribute: Attributes.src.rawValue) }
        nonmutating set { element.set(url: newValue, forAttribute: Attributes.src.rawValue) }
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
        nonmutating set { element.addAttribute(withName: Attributes.suggestedFilename.rawValue, value: newValue) }
    }
}

// MARK: - Children

extension FinalCutPro.FCPXML.MediaRep: FCPXMLElementBookmarkChild { }

// MARK: - Properties

extension FinalCutPro.FCPXML.MediaRep {
    /// Convenience to returns the `src` filename.
    public func srcFilename() -> String? {
        src?.lastPathComponent
    }
}

// MARK: - Typing

// MediaRep
extension XMLElement {
    /// FCPXML: Returns the element wrapped in an ``FinalCutPro/FCPXML/MediaRep`` model object.
    /// Call this on an `media-rep` element only.
    public var fcpAsMediaRep: FinalCutPro.FCPXML.MediaRep? {
        .init(element: self)
    }
}
// MARK: - Attribute Types

extension FinalCutPro.FCPXML.MediaRep {
    public enum Kind: String, Equatable, Hashable, CaseIterable, Sendable {
        case originalMedia = "original-media"
        case proxyMedia = "proxy-media"
    }
}

#endif
