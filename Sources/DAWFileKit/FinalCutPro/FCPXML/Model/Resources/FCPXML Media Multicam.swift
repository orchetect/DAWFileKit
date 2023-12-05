//
//  FCPXML Media Multicam.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML.Media {
    /// A multi-camera element contains one or more `mc-angle` elements that each manage a series of
    /// other story elements.
    public struct Multicam: Equatable, Hashable {
        public let element: XMLElement
        
        /// Format ID.
        public var format: String? {
            get { element.fcpFormat }
            set { element.fcpFormat = newValue }
        }
        
        /// Local timeline start.
        public var tcStart: Fraction? {
            get { element.fcpTCStart }
            set { element.fcpTCStart = newValue }
        }
        
        /// Local timeline timecode format.
        public var tcFormat: FinalCutPro.FCPXML.TimecodeFormat? {
            get { element.fcpTCFormat }
            set { element.fcpTCFormat = newValue }
        }
        
        /// Returns child `mc-angle` elements.
        /// Call on a `multicam` element.
        public var angles: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpMCAngles
        }
        
        /// Returns audio and video `mc-angle` elements for the given `mc-source` collection.
        /// Call on a `multicam` element.
        public func audioVideoMCAngles<S: Sequence<XMLElement>>(
            forMulticamSources sources: S
        ) -> (audioMCAngle: XMLElement?, videoMCAngle: XMLElement?) {
            element.fcpAudioVideoMCAngles(forMulticamSources: sources)
        }
        
        /// Returns the child `mc-angle` with the given angle identifier.
        /// Call on a `multicam` element.
        func mcAngle(
            forAngleID angleID: String?
        ) -> XMLElement? {
            element.fcpMCAngle(forAngleID: angleID)
        }
                            
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Media.Multicam {
    public enum Attributes: String, XMLParsableAttributesKey {
        /// Multicam format.
        case format
        
        /// Multicam local timeline start.
        case tcStart
        
        /// Multicam local timeline timecode format.
        case tcFormat
    }
    
    public enum Children: String {
        case mcAngle = "mc-angle"
    }
}

extension XMLElement { // Multicam
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Media/Multicam`` model object.
    /// Call this on a `multicam` element only.
    public var fcpAsMulticam: FinalCutPro.FCPXML.Media.Multicam {
        .init(element: self)
    }
    
    /// FCPXML: Returns child `mc-angle` elements.
    /// Call on a `multicam` element.
    public var fcpMCAngles: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter(\.fcpIsMCAngle)
    }
    
    /// FCPXML: Returns audio and video `mc-angle` elements for the given `mc-source` collection.
    /// Call on a `multicam` element.
    public func fcpAudioVideoMCAngles<S: Sequence<XMLElement>>(
        forMulticamSources sources: S
    ) -> (audioMCAngle: XMLElement?, videoMCAngle: XMLElement?) {
        let (audioAngleID, videoAngleID) = sources.fcpAudioVideoAngleIDs()
        
        let audioMCAngle = fcpMCAngle(forAngleID: audioAngleID)
        let videoMCAngle = fcpMCAngle(forAngleID: videoAngleID)
        
        return (audioMCAngle: audioMCAngle, videoMCAngle: videoMCAngle)
    }
    
    /// FCPXML: Returns the child `mc-angle` with the given angle identifier.
    /// Call on a `multicam` element.
    public func fcpMCAngle(
        forAngleID angleID: String?
    ) -> XMLElement? {
        guard let angleID = angleID else { return nil }
        return fcpMCAngles
            .first(whereAttribute: FinalCutPro.FCPXML.Media.Multicam.Children.mcAngle.rawValue,
                   hasValue: angleID)
    }
    
    /// FCPXML: Returns `true` if element is an `mc-angle`.
    public var fcpIsMCAngle: Bool {
        name == FinalCutPro.FCPXML.Media.Multicam.Children.mcAngle.rawValue
    }
}

#endif
