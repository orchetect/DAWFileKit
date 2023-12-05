//
//  FCPXML Sequence.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import CoreMedia
import OTCore

extension FinalCutPro.FCPXML {
    /// A container that represents the top-level sequence for a Final Cut Pro project or compound
    /// clip.
    public struct Sequence: Equatable, Hashable {
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
        
        /// Local timeline duration.
        public var duration: Fraction? {
            get { element.fcpDuration }
            set { element.fcpDuration = newValue }
        }
        
        // sequence attributes
        
        public var audioLayout: AudioLayout? { // only exists on sequence
            get {
                guard let value = element.stringValue(forAttributeNamed: Attributes.audioLayout.rawValue)
                else { return nil }
                
                return AudioLayout(rawValue: value)
            }
            set {
                element.addAttribute(withName: Attributes.audioLayout.rawValue, value: newValue?.rawValue)
            }
        }
        
        /// Audio sample rate in Hz.
        public var audioRate: Int? {
            get { element.fcpAudioRate }
            set { element.fcpAudioRate = newValue }
        }
        
        public var note: String? {
            get { element.fcpNote }
            set { element.fcpNote = newValue }
        }
        
        public var renderFormat: String? {
            get { element.fcpRenderFormat }
            set { element.fcpRenderFormat = newValue }
        }
        
        public var keywords: String? { // only exists on sequence
            get {
                element.stringValue(forAttributeNamed: Attributes.keywords.rawValue)
            }
            set {
                element.addAttribute(withName: Attributes.keywords.rawValue, value: newValue)
            }
        }
        
        // TODO: add metadata
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Sequence {
    public static let storyElementType: FinalCutPro.FCPXML.StoryElementType = .sequence
    
    public enum Attributes: String, XMLParsableAttributesKey {
        // Timeline Attributes
        case format
        case tcStart
        case tcFormat
        case duration
        
        // sequence attributes
        case audioLayout
        case audioRate
        case note
        case renderFormat
        case keywords
    }
    
    public enum Children: String {
        case spine
    }
    
    // can contain metadata
}

extension XMLElement { // Sequence
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Sequence`` model object.
    /// Call this on a `sequence` element only.
    public var fcpAsSequence: FinalCutPro.FCPXML.Sequence {
        .init(element: self)
    }
    
    /// FCPXML: Returns `renderFormat` attribute value.
    /// Call this on a `sequence` or `multicam` element only.
    public var fcpRenderFormat: String? {
        get { stringValue(forAttributeNamed: "renderFormat") }
        set { addAttribute(withName: "renderFormat", value: newValue) }
    }
    
    /// FCPXML: Returns child `spine` elements.
    /// Typically called on a `sequence` element.
    public var fcpSpines: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter(whereElementNamed: FinalCutPro.FCPXML.Sequence.Children.spine.rawValue)
    }
    
    /// FCPXML: Returns a child `spine` element if it exists.
    /// Typically called on a `sequence` element.
    public func fcpSpine() -> XMLElement? {
        guard let spine = fcpSpines.first else {
            print("Expected one spine within sequence but found none.")
            return nil
        }
        return spine
    }
}

#endif
