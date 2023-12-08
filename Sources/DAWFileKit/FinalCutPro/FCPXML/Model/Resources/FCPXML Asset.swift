//
//  FCPXML Asset.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

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
        
        // shared resource attributes
        
        /// Identifier. (Required)
        public var id: String {
            get { element.fcpID ?? "" }
            set { element.fcpID = newValue }
        }
        
        /// Name.
        public var name: String? {
            get { element.fcpName }
            set { element.fcpName = newValue }
        }
        
        // base attributes
        
        /// Asset format ID.
        public var format: String? {
            get { element.fcpFormat }
            set { element.fcpFormat = newValue }
        }
        
        // asset attributes
        
        public var uid: String? {
            get { element.fcpUID }
            set { element.fcpUID = newValue }
        }
        
        // implied asset attributes
        
        /// True if asset contains audio. Default is `0` (false).
        public var hasAudio: Bool {
            get {
                element.getBool(forAttribute: Attributes.hasAudio.rawValue) ?? false
            }
            set {
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
            set {
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
            set {
                element.set(int: newValue, forAttribute: Attributes.audioSources.rawValue)
            }
        }
        
        /// Number of audio channels. Default is `0`.
        public var audioChannels: Int {
            get {
                element.getInt(forAttribute: Attributes.audioChannels.rawValue) ?? 0
            }
            set {
                element.set(int: newValue, forAttribute: Attributes.audioChannels.rawValue)
            }
        }
        
        /// Audio sample rate in Hz.
        public var audioRate: AudioRate? {
            get { element.fcpAudioRate }
            set { element.fcpAudioRate = newValue }
        }
        
        /// Number of video sources. Default is `0`.
        public var videoSources: Int {
            get {
                element.getInt(forAttribute: Attributes.videoSources.rawValue) ?? 0
            }
            set {
                element.set(int: newValue, forAttribute: Attributes.videoSources.rawValue)
            }
        }
        
        // Children
        
        public var mediaRep: XMLElement? { // only used by `asset`
            element.firstChildElement(named: Children.mediaRep.rawValue)
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Asset: FCPXMLElementOptionalStart { }

extension FinalCutPro.FCPXML.Asset: FCPXMLElementOptionalDuration { }

extension FinalCutPro.FCPXML.Asset: FCPXMLElementMetadataChild { }

extension FinalCutPro.FCPXML.Asset {
    public static let resourceType: FinalCutPro.FCPXML.ResourceType = .asset
    
    public enum Attributes: String, XMLParsableAttributesKey {
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
    
    public enum Children: String {
        case mediaRep = "media-rep"
        case metadata
    }
}

extension XMLElement { // Asset
    /// FCPXML: Returns the element wrapped in an ``FinalCutPro/FCPXML/Asset`` model object.
    /// Call this on an `asset` element only.
    public var fcpAsAsset: FinalCutPro.FCPXML.Asset {
        .init(element: self)
    }
    
    /// FCPXML: Returns the `audioRate` attribute value (audio sample rate in Hz).
    /// Call this on an `asset` or `sequence` element only.
    public var fcpAudioRate: FinalCutPro.FCPXML.AudioRate? {
        get {
            guard let value = stringValue(forAttributeNamed: "audioRate")
            else { return nil }
            
            return FinalCutPro.FCPXML.AudioRate(rawValue: value)
        }
        set {
            addAttribute(withName: "audioRate", value: newValue?.rawValue)
        }
    }
}

#endif
