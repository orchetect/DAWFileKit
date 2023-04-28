//
//  FCPXML.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro {
    /// Final Cut Pro XML file (FCPXML/FCPXMLD)
    ///
    /// [Official FCPXML Apple docs](https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/)
    public struct FCPXML {
        /// Direct access to the FCP XML file.
        public var xml: XMLDocument
    }
}

extension FinalCutPro.FCPXML {
    /// Returns the FCPXML format version.
    public var version: Version? {
        guard let verString = xmlRoot?.attributeStringValue(forName: "version") else { return nil }
        return Version(rawValue: verString)
    }
    
    /// The root "fcpxml" XML element.
    public var xmlRoot: XMLElement? {
        xml.children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .first(where: { $0.name == "fcpxml" })
    }
    
    /// The "resources" XML element.
    var xmlResources: XMLElement? {
        xmlRoot?.elements(forName: "resources").first
    }
    
    /// The "library" XML element.
    public var xmlLibrary: XMLElement? {
        xmlRoot?.elements(forName: "library").first
    }
    
    /// All "event" XML leafs within the library.
    var xmlEvents: [XMLElement] {
        xmlLibrary?.elements(forName: "event") ?? []
    }
}

extension FinalCutPro.FCPXML {
    /// "tcFormat" attribute.
    public enum TimecodeFormat: String {
        case dropFrame = "DF"
        case nonDropFrame = "NDF"
        
        public var isDrop: Bool {
            switch self {
            case .dropFrame: return true
            case .nonDropFrame: return false
            }
        }
    }
    
    /// "audioLayout" attribute.
    public enum AudioLayout: String {
        case mono
        case stereo
        case surround
    }
    
    /// "audioRate" attribute.
    public enum AudioRate: String {
        case rate32kHz = "32k"
        case rate44_1kHz = "44.1k"
        case rate48kHz = "48k"
        case rate88_2kHz = "88.2k"
        case rate96kHz = "96k"
        case rate176_4kHz = "176.4k"
        case rate192kHz = "192k"
    }
}

#endif
