//
//  FCPXML Media.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

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
    public struct Media: FCPXMLElement {
        public let element: XMLElement
        
        public let elementType: ElementType = .media
        
        public static let supportedElementTypes: Set<ElementType> = [.media]
        
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

extension FinalCutPro.FCPXML.Media {
    public init(
        // shared resource attributes
        id: String,
        name: String? = nil,
        // asset attributes
        uid: String? = nil,
        projectRef: String? = nil,
        // FCPXMLElementOptionalModDate
        modDate: String? = nil
    ) {
        self.init()
        
        // shared resource attributes
        self.id = id
        self.name = name
        // asset attributes
        self.uid = uid
        self.projectRef = projectRef
        // FCPXMLElementOptionalModDate
        self.modDate = modDate
    }
    
    public init(
        // shared resource attributes
        id: String,
        name: String? = nil,
        // asset attributes
        uid: String? = nil,
        projectRef: String? = nil,
        // FCPXMLElementOptionalModDate
        modDate: String? = nil,
        // multicam or sequence
        multicam: Multicam
    ) {
        self.init(
            id: id,
            name: name,
            uid: uid,
            projectRef: projectRef,
            modDate: modDate
        )
        self.element.addChild(multicam.element)
    }
    
    public init(
        // shared resource attributes
        id: String,
        name: String? = nil,
        // asset attributes
        uid: String? = nil,
        projectRef: String? = nil,
        // FCPXMLElementOptionalModDate
        modDate: String? = nil,
        // multicam or sequence
        sequence: FinalCutPro.FCPXML.Sequence
    ) {
        self.init(
            id: id,
            name: name,
            uid: uid,
            projectRef: projectRef,
            modDate: modDate
        )
        self.element.addChild(sequence.element)
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Media {
    public enum Attributes: String {
        // shared resource attributes
        case id
        case name
        
        // asset attributes
        case uid
        case projectRef
    }
    
    // can contain either one `multicam` or one `sequence`
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Media {
    // shared resource attributes
    
    public var id: String {
        get { element.fcpID ?? "" }
        nonmutating set { element.fcpID = newValue }
    }
    
    public var name: String? {
        get { element.fcpName }
        nonmutating set { element.fcpName = newValue }
    }
    
    public var projectRef: String? {
        get { element.stringValue(forAttributeNamed: Attributes.projectRef.rawValue) }
        nonmutating set { element.addAttribute(withName: Attributes.projectRef.rawValue, value: newValue) }
    }
    
    // asset attributes
    
    public var uid: String? {
        get { element.fcpUID }
        nonmutating set { element.fcpUID = newValue }
    }
}

extension FinalCutPro.FCPXML.Media: FCPXMLElementOptionalModDate { }

// MARK: - Children

extension FinalCutPro.FCPXML.Media {
    /// Returns the `multicam` child element if one exists.
    public var multicam: Multicam? {
        get { element.firstChild(whereFCPElement: .multicam) }
        nonmutating set {
            // there can only be a sequence or multicam, so remove old one if present
            element._removeChildren(ofType: .sequence)
            
            element._updateChildElements(ofType: .multicam, withChild: newValue)
        }
    }
    
    /// Returns the `sequence` child element if one exists.
    public var sequence: FinalCutPro.FCPXML.Sequence? {
        get { element.firstChild(whereFCPElement: .sequence) }
        nonmutating set {
            // there can only be a sequence or multicam, so remove old one if present
            element._removeChildren(ofType: .multicam)
            
            element._updateChildElements(ofType: .sequence, withChild: newValue)
        }
    }
}

// MARK: - Typing

// Media
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Media`` model object.
    /// Call this on a `media` element only.
    public var fcpAsMedia: FinalCutPro.FCPXML.Media? {
        .init(element: self)
    }
}

// MARK: - Supporting Types

extension FinalCutPro.FCPXML.Media {
    public enum MediaType: Equatable, Hashable {
        case multicam
        case sequence
    }
}

#endif
