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
    public struct Sequence: FCPXMLElement {
        public let element: XMLElement
        public let elementName: String = "sequence"
        
        // Element-Specific Attributes
        
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
        public var audioRate: AudioRate? {
            get { element.fcpSequenceAudioRate }
            set { element.fcpSequenceAudioRate = newValue }
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
        
        // Children
        
        /// Returns the child `spine` element. (Required)
        public var spine: Spine {
            element.fcpSpine() ?? Spine()
        }
        
        // MARK: FCPXMLElement inits
        
        public init() {
            element = XMLElement(name: elementName)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementValid(element: element) else { return nil }
        }
    }
}

extension FinalCutPro.FCPXML.Sequence: FCPXMLElementMediaAttributes { }

extension FinalCutPro.FCPXML.Sequence: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.Sequence: FCPXMLElementMetadataChild { }

extension FinalCutPro.FCPXML.Sequence {
    public static let storyElementType: FinalCutPro.FCPXML.StoryElementType = .sequence
    
    public enum Attributes: String {
        // Element-Specific Attributes
        case audioLayout
        case audioRate
        case renderFormat
        case keywords
        
        // Media Attributes
        case format
        case duration
        case tcStart
        case tcFormat
    }
    
    public enum Children: String {
        case spine // must contain one `spine`
        case note // can contain one `note`
        case metadata // can contain one `metadata`
    }
}

extension XMLElement { // Sequence
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Sequence`` model object.
    /// Call this on a `sequence` element only.
    public var fcpAsSequence: FinalCutPro.FCPXML.Sequence? {
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
    public var fcpSpines: LazyMapSequence<
        LazyFilterSequence<
            LazyMapSequence<
                LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>>.Elements,
                FinalCutPro.FCPXML.Spine?
            >
        >,
        FinalCutPro.FCPXML.Spine
    > {
        childElements
            .filter(whereElementNamed: FinalCutPro.FCPXML.Sequence.Children.spine.rawValue)
            .compactMap(\.fcpAsSpine)
    }
    
    /// FCPXML: Returns a child `spine` element if it exists.
    /// Typically called on a `sequence` element.
    public func fcpSpine() -> FinalCutPro.FCPXML.Spine? {
        guard let spine = fcpSpines.first else {
            print("Expected one spine within sequence but found none.")
            return nil
        }
        return spine
    }
}

#endif
