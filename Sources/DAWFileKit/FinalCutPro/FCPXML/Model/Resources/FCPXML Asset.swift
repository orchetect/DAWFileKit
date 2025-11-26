//
//  FCPXML Asset.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore
import SwiftExtensions

extension FinalCutPro.FCPXML {
    /// Asset shared resource.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Define file-based media managed in a Final Cut Pro library.
    /// >
    /// > Use the `asset` element to define a file-based media. A file-based media can have an
    /// > original media representation and a proxy media representation. Describe those using the
    /// > `media-rep` element along with file URLs for the media files.
    /// >
    /// > See [`asset`](https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/asset).
    public struct Asset: FCPXMLElement {
        public let element: XMLElement
        
        public let elementType: ElementType = .asset
        
        public static let supportedElementTypes: Set<ElementType> = [.asset]
        
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

extension FinalCutPro.FCPXML.Asset {
    public init(
        id: String,
        name: String? = nil,
        start: Fraction? = nil,
        duration: Fraction? = nil,
        format: String? = nil,
        uid: String? = nil,
        hasAudio: Bool = false,
        hasVideo: Bool = false,
        audioSources: Int = 0,
        audioChannels: Int = 0,
        audioRate: FinalCutPro.FCPXML.AudioRate? = nil,
        videoSources: Int = 0,
        auxVideoFlags: String? = nil,
        mediaRep: FinalCutPro.FCPXML.MediaRep = .init(),
        metadata: FinalCutPro.FCPXML.Metadata? = nil
    ) {
        self.init()
        
        self.id = id
        self.name = name
        self.start = start
        self.duration = duration
        self.format = format
        self.uid = uid
        self.hasAudio = hasAudio
        self.hasVideo = hasVideo
        self.audioSources = audioSources
        self.audioChannels = audioChannels
        self.audioRate = audioRate
        self.videoSources = videoSources
        self.auxVideoFlags = auxVideoFlags
        self.mediaRep = mediaRep
        self.metadata = metadata
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Asset {
    public enum Attributes: String {
        // shared resource attributes
        /// Identifier. (Required)
        case id // required
        /// Name.
        case name
        
        // base attributes
        /// Local timeline start.
        case start
        /// Asset duration.
        case duration
        /// Asset format ID.
        case format
        
        // asset attributes
        case uid
        
        // implied asset attributes
        /// True if asset contains audio. Default is `0` (false).
        case hasAudio
        /// True if asset contains video. Default is `0` (false).
        case hasVideo
        /// Number of audio sources. Default is `0`.
        case audioSources
        /// Number of audio channels. Default is `0`.
        case audioChannels
        /// Audio sample rate in Hz.
        case audioRate
        /// Number of video sources. Default is `0`.
        case videoSources
        
        case customLUTOverride
        case colorSpaceOverride
        case projectionOverride
        case stereoscopicOverride
        case auxVideoFlags
    }
    
    // contains one or more media-rep
    // can contain metadata
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Asset {
    // shared resource attributes
    
    /// Identifier. (Required)
    public var id: String {
        get { element.fcpID ?? "" }
        nonmutating set { element.fcpID = newValue }
    }
    
    /// Name.
    public var name: String? {
        get { element.fcpName }
        nonmutating set { element.fcpName = newValue }
    }
    
    // base attributes
    
    /// Asset format ID.
    public var format: String? {
        get { element.fcpFormat }
        nonmutating set { element.fcpFormat = newValue }
    }
    
    // asset attributes
    
    public var uid: String? {
        get { element.fcpUID }
        nonmutating set { element.fcpUID = newValue }
    }
    
    // implied asset attributes
    
    /// True if asset contains audio. Default is `0` (false).
    public var hasAudio: Bool {
        get {
            element.getBool(forAttribute: Attributes.hasAudio.rawValue) ?? false
        }
        nonmutating set {
            element._fcpSet(
                bool: newValue,
                forAttribute: Attributes.hasAudio.rawValue,
                defaultValue: false,
                removeIfDefault: true
            )
        }
    }
    
    /// True if asset contains video. Default is `0` (false).
    public var hasVideo: Bool {
        get {
            element.getBool(forAttribute: Attributes.hasVideo.rawValue) ?? false
        }
        nonmutating set {
            element._fcpSet(
                bool: newValue,
                forAttribute: Attributes.hasVideo.rawValue,
                defaultValue: false,
                removeIfDefault: true
            )
        }
    }
    
    /// Number of audio sources. Default is `0`.
    public var audioSources: Int {
        get {
            element.getInt(forAttribute: Attributes.audioSources.rawValue) ?? 0
        }
        nonmutating set {
            element.set(int: newValue, forAttribute: Attributes.audioSources.rawValue)
        }
    }
    
    /// Number of audio channels. Default is `0`.
    public var audioChannels: Int {
        get {
            element.getInt(forAttribute: Attributes.audioChannels.rawValue) ?? 0
        }
        nonmutating set {
            element.set(int: newValue, forAttribute: Attributes.audioChannels.rawValue)
        }
    }
    
    /// Audio sample rate in Hz.
    public var audioRate: FinalCutPro.FCPXML.AudioRate? {
        get { element.fcpAssetAudioRate }
        nonmutating set { element.fcpAssetAudioRate = newValue }
    }
    
    /// Number of video sources. Default is `0`.
    public var videoSources: Int {
        get {
            element.getInt(forAttribute: Attributes.videoSources.rawValue) ?? 0
        }
        nonmutating set {
            element.set(int: newValue, forAttribute: Attributes.videoSources.rawValue)
        }
    }
    
    public var auxVideoFlags: String? { // only used by `asset`
        get { element.stringValue(forAttributeNamed: Attributes.auxVideoFlags.rawValue) }
        nonmutating set { element.addAttribute(withName: Attributes.auxVideoFlags.rawValue, value: newValue) }
    }
}

extension FinalCutPro.FCPXML.Asset: FCPXMLElementOptionalStart { }

extension FinalCutPro.FCPXML.Asset: FCPXMLElementOptionalDuration { }

// MARK: - Children

extension FinalCutPro.FCPXML.Asset {
    // TODO: can contain one or more `media-rep` children. not sure why more than one, but DTD says so.
    // only used by `asset`
    public var mediaRep: FinalCutPro.FCPXML.MediaRep {
        get {
            element.firstChild(whereFCPElement: .mediaRep, defaultChild: .init())
        }
        nonmutating set {
            element._updateFirstChildElement(
                ofType: .mediaRep,
                withChild: newValue,
                default: .init()
            )
        }
    }
}

extension FinalCutPro.FCPXML.Asset: FCPXMLElementMetadataChild { }

// MARK: - Properties

// Asset
extension XMLElement {
    /// FCPXML: Returns the `audioRate` attribute value (audio sample rate in Hz).
    /// Call this on a `asset` element only.
    public var fcpAssetAudioRate: FinalCutPro.FCPXML.AudioRate? {
        get {
            guard let value = stringValue(forAttributeNamed: "audioRate")
            else { return nil }
            
            return FinalCutPro.FCPXML.AudioRate(rawValueForAsset: value)
        }
        set {
            addAttribute(withName: "audioRate", value: newValue?.rawValueForAsset)
        }
    }
}

// MARK: - Typing

// Asset
extension XMLElement {
    /// FCPXML: Returns the element wrapped in an ``FinalCutPro/FCPXML/Asset`` model object.
    /// Call this on an `asset` element only.
    public var fcpAsAsset: FinalCutPro.FCPXML.Asset? {
        .init(element: self)
    }
}

#endif
