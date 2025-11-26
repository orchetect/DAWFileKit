//
//  FCPXML Sequence.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore
import CoreMedia
import SwiftExtensions

extension FinalCutPro.FCPXML {
    /// A container that represents the top-level sequence for a Final Cut Pro project or compound
    /// clip.
    public struct Sequence: FCPXMLElement {
        public let element: XMLElement
        
        public let elementType: ElementType = .sequence
        
        public static let supportedElementTypes: Set<ElementType> = [.sequence]
        
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

extension FinalCutPro.FCPXML.Sequence {
    public init(
        spine: FinalCutPro.FCPXML.Spine = .init(),
        audioLayout: FinalCutPro.FCPXML.AudioLayout? = nil,
        audioRate: FinalCutPro.FCPXML.AudioRate? = nil,
        renderFormat: String? = nil,
        keywords: String? = nil,
        // Media Attributes
        format: String,
        duration: Fraction? = nil,
        tcStart: Fraction? = nil,
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat? = nil,
        // Note child
        note: String? = nil,
        // Metadata
        metadata: FinalCutPro.FCPXML.Metadata? = nil
    ) {
        self.init()
        
        self.spine = spine
        
        self.audioLayout = audioLayout
        self.audioRate = audioRate
        self.renderFormat = renderFormat
        self.keywords = keywords
        
        // Media Attributes
        self.format = format
        self.duration = duration
        self.tcStart = tcStart
        self.tcFormat = tcFormat
        
        // Note child
        self.note = note
        
        // Metadata
        self.metadata = metadata
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Sequence {
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
    
    // must contain one `spine`
    // can contain one `note`
    // can contain one `metadata`
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Sequence: FCPXMLElementMediaAttributes { }

extension FinalCutPro.FCPXML.Sequence {
    // only exists on sequence
    public var audioLayout: FinalCutPro.FCPXML.AudioLayout? {
        get {
            guard let value = element.stringValue(forAttributeNamed: Attributes.audioLayout.rawValue)
            else { return nil }
            
            return FinalCutPro.FCPXML.AudioLayout(rawValue: value)
        }
        nonmutating set {
            element.addAttribute(withName: Attributes.audioLayout.rawValue, value: newValue?.rawValue)
        }
    }
    
    /// Audio sample rate in Hz.
    public var audioRate: FinalCutPro.FCPXML.AudioRate? {
        get { element.fcpSequenceAudioRate }
        nonmutating set { element.fcpSequenceAudioRate = newValue }
    }
    
    public var renderFormat: String? {
        get { element.fcpRenderFormat }
        nonmutating set { element.fcpRenderFormat = newValue }
    }
    
    public var keywords: String? { // only exists on sequence
        get {
            element.stringValue(forAttributeNamed: Attributes.keywords.rawValue)
        }
        nonmutating set {
            element.addAttribute(withName: Attributes.keywords.rawValue, value: newValue)
        }
    }
}

// MARK: - Children

extension FinalCutPro.FCPXML.Sequence {
    /// Get or set the child `spine` element. (Required)
    public var spine: FinalCutPro.FCPXML.Spine {
        get {
            element.firstChild(whereFCPElement: .spine, defaultChild: .init())
        }
        nonmutating set {
            element._updateFirstChildElement(
                ofType: .spine,
                withChild: newValue,
                default: .init()
            )
        }
    }
}

extension FinalCutPro.FCPXML.Sequence: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.Sequence: FCPXMLElementMetadataChild { }

// MARK: - Meta Conformances

extension FinalCutPro.FCPXML.Sequence: FCPXMLElementMetaTimeline { 
    public func asAnyTimeline() -> FinalCutPro.FCPXML.AnyTimeline { .sequence(self) }
}

// MARK: - Properties

// Sequence
extension XMLElement {
    /// FCPXML: Returns `renderFormat` attribute value.
    /// Call this on a `sequence` or `multicam` element only.
    public var fcpRenderFormat: String? {
        get { stringValue(forAttributeNamed: "renderFormat") }
        set { addAttribute(withName: "renderFormat", value: newValue) }
    }
    
    /// FCPXML: Returns child `spine` elements.
    /// Typically called on a `sequence` element.
    public var fcpSpines: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.Spine> {
        children(whereFCPElement: .spine)
    }
    
    /// FCPXML: Returns a child `spine` element if it exists.
    /// Typically called on a `sequence` element.
    public func fcpSpine() -> FinalCutPro.FCPXML.Spine? {
        guard let spine = fcpSpines.first else {
            // print("Expected one spine within sequence but found none.")
            return nil
        }
        return spine
    }
    
    /// FCPXML: Returns the `audioRate` attribute value (audio sample rate in Hz).
    /// Call this on a `sequence` element only.
    public var fcpSequenceAudioRate: FinalCutPro.FCPXML.AudioRate? {
        get {
            guard let value = stringValue(forAttributeNamed: "audioRate")
            else { return nil }
            
            return FinalCutPro.FCPXML.AudioRate(rawValueForSequence: value)
        }
        set {
            addAttribute(withName: "audioRate", value: newValue?.rawValueForSequence)
        }
    }
}

// MARK: - Typing

// Sequence
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Sequence`` model object.
    /// Call this on a `sequence` element only.
    public var fcpAsSequence: FinalCutPro.FCPXML.Sequence? {
        .init(element: self)
    }
}

#endif
