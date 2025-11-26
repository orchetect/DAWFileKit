//
//  FCPXML TimeMap.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions
import TimecodeKitCore

extension FinalCutPro.FCPXML {
    /// Clip time map.
    ///
    /// > FCPXML 1.11 DTD:
    /// >
    /// > "A `timeMap` is a container for `timept` elements that change the output speed of the clip's local timeline.
    /// > When present, a `timeMap` defines a new adjusted time range for the clip using the first and last `timept`
    /// > elements. All other time values are interpolated from the specified `timept` elements."
    public struct TimeMap: FCPXMLElement, Equatable, Hashable {
        public let element: XMLElement
        
        public let elementType: ElementType = .timeMap
        
        public static let supportedElementTypes: Set<ElementType> = [.timeMap]
        
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

extension FinalCutPro.FCPXML.TimeMap {
    public init(
        frameSampling: FinalCutPro.FCPXML.FrameSampling = .floor,
        preservesPitch: Bool = true,
        timePoints: (some Sequence<TimePoint>)? = nil as [TimePoint]?
    ) {
        self.init()
        
        self.frameSampling = frameSampling
        self.preservesPitch = preservesPitch
        timePoints?.forEach { element.addChild($0.element) }
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.TimeMap {
    public enum Attributes: String {
        case frameSampling
        case preservesPitch // 0 or 1, default: 1
    }
    
    // contains 0 or more `timept` child elements
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.TimeMap {
    /// Preserves pitch. (Default: true)
    public var preservesPitch: Bool {
        get {
            element.getBool(forAttribute: Attributes.preservesPitch.rawValue) ?? true
        }
        nonmutating set {
            element.set(
                bool: newValue,
                forAttribute: Attributes.preservesPitch.rawValue,
                defaultValue: true,
                removeIfDefault: true,
                useInt: true
            )
        }
    }
}

extension FinalCutPro.FCPXML.TimeMap: FCPXMLElementFrameSampling { }

// MARK: - Children

extension FinalCutPro.FCPXML.TimeMap {
    public var timePoints: some Swift.Sequence<TimePoint> {
        get {
            element.children(whereFCPElement: .timePoint)
        }
        nonmutating set { 
            element._updateChildElements(ofType: .timePoint, with: newValue)
        }
    }
}

// MARK: - Typing

// TimeMap
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/TimeMap`` model object.
    /// Call this on a `timeMap` element only.
    public var fcpAsTimeMap: FinalCutPro.FCPXML.TimeMap? {
        .init(element: self)
    }
}

#endif
