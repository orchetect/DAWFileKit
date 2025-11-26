//
//  FCPXML.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions

// MARK: - root/*

extension FinalCutPro.FCPXML {
    /// Root `fcpxml` element in a FCPXML document.
    public struct Root: FCPXMLElement, Equatable, Hashable {
        public let element: XMLElement
        
        public let elementType: ElementType = .fcpxml
        
        public static let supportedElementTypes: Set<ElementType> = [.fcpxml]
        
        public init() {
            element = XMLElement(name: elementType.rawValue)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementTypeSupported(element: element) else { return nil }
        }
    }
    
    public enum RootChildren: String {
        case fcpxml
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Root {
    public enum Attributes: String {
        case version
    }
    
    // must contain one `resources` container
    // may contain zero or one `library`
    // may contain zero or more `event`
    // may contain zero or more `project`
    
    // AFAIK it's possible to have clips here too
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Root {
    /// Returns the FCPXML format version.
    public var version: FinalCutPro.FCPXML.Version {
        guard let verString = element.stringValue(forAttributeNamed: Attributes.version.rawValue),
              let ver = FinalCutPro.FCPXML.Version(rawValue: verString)
        else { return .latest }
        
        return ver
    }
}

// MARK: - Children

extension FinalCutPro.FCPXML.Root {
    /// Get or set the `resources` XML element.
    /// Exactly one of these elements is always required.
    public var resources: XMLElement {
        get {
            element.firstDefaultedChildElement(whereFCPElementType: .resources)
        }
        nonmutating set {
            element._updateFirstChildElement(
                ofType: .resources,
                withChild: newValue
            )
        }
    }
    
    /// Access the contents of the `resources` XML element as a dictionary of elements
    /// keyed by resource ID.
    public var resourcesDict: [String: XMLElement] {
        get {
            resources
                .childElements
                .mapDictionary {
                    (key: $0.fcpID ?? "", value: $0)
                }
        }
        nonmutating set {
            let sortedElements = newValue.values.sorted(by: {
                ($0.fcpID ?? "")
                    .caseInsensitiveCompare(($1.fcpID ?? ""))
                    == .orderedAscending
            })
            
            let resourcesContainer = XMLElement(name: FinalCutPro.FCPXML.ElementType.resources.rawValue)
            sortedElements.forEach { resourcesContainer.addChild($0) }
            resources = resourcesContainer
        }
    }
    
    /// Utility:
    /// Returns the `fcpxml/library` element if it exists.
    /// One or zero of these elements may be present within the `fcpxml` element.
    public var library: FinalCutPro.FCPXML.Library? {
        element.firstChild(whereFCPElement: .library)
    }
    
    /// Returns child `event` elements.
    public var events: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.Event> {
        element.children(whereFCPElement: .event)
    }
    
    /// Returns child `project` elements.
    public var projects: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.Project> {
        element.children(whereFCPElement: .project)
    }
}

// MARK: - Typing

// `fcpxml`
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Root`` model object.
    /// Call this on a `fcpxml` element only.
    public var fcpAsRoot: FinalCutPro.FCPXML.Root? {
        .init(element: self)
    }
}

#endif
