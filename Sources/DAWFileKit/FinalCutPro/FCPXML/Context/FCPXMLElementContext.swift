//
//  FCPXMLElementContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
@_implementationOnly import OTCore

public protocol FCPXMLElementContext {
    /// Additional contextual metadata for the element.
    /// This is generated during FCPXML parsing by using the context builder.
    var context: FinalCutPro.FCPXML.ElementContext { get }
}

public protocol FCPXMLElementContextBuilder {
    var contextBuilder: FinalCutPro.FCPXML.ElementContextClosure { get }
}

extension FCPXMLElementContextBuilder {
    /// Internal: builds the context for the element.
    func buildContext(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> FinalCutPro.FCPXML.ElementContext {
        let tools = FinalCutPro.FCPXML.ContextTools(xmlLeaf: xmlLeaf, breadcrumbs: breadcrumbs, resources: resources)
        return contextBuilder(xmlLeaf, breadcrumbs, resources, tools)
    }
}

extension FinalCutPro.FCPXML {
    /// Context for a model element.
    public typealias ElementContext = [String: Any]
    
    /// Context builder closure for a model element.
    public typealias ElementContextClosure = (
        _ element: XMLElement,
        _ breadcrumbs: [XMLElement],
        _ resources: [String: FinalCutPro.FCPXML.AnyResource],
        _ tools: FinalCutPro.FCPXML.ContextTools
    ) -> ElementContext
    
    /// Class instance that provides useful context for a FCPXML element.
    public struct ContextTools {
        var xmlLeaf: XMLElement
        var breadcrumbs: [XMLElement]
        var resources: [String: FinalCutPro.FCPXML.AnyResource]
        
        init(
            xmlLeaf: XMLElement,
            breadcrumbs: [XMLElement],
            resources: [String: FinalCutPro.FCPXML.AnyResource]
        ) {
            self.xmlLeaf = xmlLeaf
            self.breadcrumbs = breadcrumbs
            self.resources = resources
        }
        
        // MARK: - Properties
        
        /// The current element type.
        public var elementType: ElementType? {
            ElementType(from: xmlLeaf)
        }
        
        /// The absolute start timecode of the current element.
        /// This is calculated based on ancestor elements.
        public var absoluteStart: Timecode? {
            FinalCutPro.FCPXML.calculateAbsoluteStart(
                of: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources
            )
        }
        
        /// The absolute end timecode of the current element.
        /// This is calculated based on ancestor elements.
        public var absoluteEnd: Timecode? {
            guard let absoluteStart = absoluteStart,
                  let duration = FinalCutPro.FCPXML.duration(
                      of: xmlLeaf,
                      resources: resources
                  )
            else { return nil }
            return absoluteStart + duration
        }
        
        /// Returns the effective format for the current element.
        public var effectiveFormat: Format? {
            FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: xmlLeaf, in: resources)
        }
        
        /// Returns an event name if the current element is a descendent of an event.
        public var ancestorEventName: String? {
            let ancestorEvent = xmlLeaf.firstAncestor(
                named: FinalCutPro.FCPXML.StructureElementType.event.rawValue
            )
            return FinalCutPro.FCPXML.getNameAttribute(from: ancestorEvent)
        }
        
        /// Returns a project name if the current element is a descendent of a project.
        public var ancestorProjectName: String? {
            let ancestorProject = xmlLeaf.firstAncestor(
                named: FinalCutPro.FCPXML.StructureElementType.project.rawValue
            )
            return FinalCutPro.FCPXML.getNameAttribute(from: ancestorProject)
        }
        
        /// The parent element's type.
        public var parentType: ElementType? {
            guard let parent = parent else { return nil }
            guard let nameValue = parent.name else { return nil }
            return FinalCutPro.FCPXML.ElementType(rawValue: nameValue)
        }
        
        /// The parent element's name.
        public var parentName: String? {
            guard let parent = parent else { return nil }
            return FinalCutPro.FCPXML.getNameAttribute(from: parent)
        }
        
        /// The parent element's absolute start time.
        /// This is calculated based on ancestor elements.
        public var parentAbsoluteStart: Timecode? {
            guard let parent = parent else { return nil }
            return FinalCutPro.FCPXML.calculateAbsoluteStart(
                of: parent,
                breadcrumbs: breadcrumbs.dropLast(),
                resources: resources
            )
        }
        
        /// The parent element's absolute end time.
        /// This is calculated based on ancestor elements.
        public var parentAbsoluteEnd: Timecode? {
            guard let parentAbsoluteStart = parentAbsoluteStart,
                  let parentDuration = parentDuration
            else { return nil }
            return parentAbsoluteStart + parentDuration
        }
        
        /// The parent element's duration.
        public var parentDuration: Timecode? {
            guard let parent = parent else { return nil }
            return FinalCutPro.FCPXML.nearestDuration(
                of: parent,
                breadcrumbs: breadcrumbs.dropLast(),
                resources: resources
            )
        }
        
        /// The element's own roles, if applicable or present.
        public func roles(includeDefaultRoles: Bool) -> [AnyRole] {
            let elementRoles = FinalCutPro.FCPXML.roles(
                of: xmlLeaf,
                resources: resources,
                auditions: .active
            )
            if includeDefaultRoles, let elementType = elementType {
                let defaultedRoles = FinalCutPro.FCPXML.addDefaultRoles(for: elementType, to: elementRoles)
                return defaultedRoles.map(\.wrapped)
            } else {
                return elementRoles
            }
        }
        
        /// Returns the effective roles of the element inherited from ancestors.
        public var inheritedRoles: [AnyInterpolatedRole] {
            FinalCutPro.FCPXML.inheritedRoles(
                of: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                auditions: .active
            )
            .flattenedInterpolatedRoles()
        }
        
        /// Returns occlusion information for the current element in relation to its parent.
        public var occlusion: FinalCutPro.FCPXML.ElementOcclusion {
            guard let parentStart = parentAbsoluteStart,
                  let parentEnd = parentAbsoluteEnd,
                  let elementStart = absoluteStart
            else { return .notOccluded }
            
            return FinalCutPro.FCPXML.occlusion(
                area: parentStart ..< parentEnd,
                internalStart: elementStart,
                internalEnd: absoluteEnd
            )
        }
        
        /// Returns the effective occlusion for the current element with regards the main timeline.
        public var effectiveOcclusion: FinalCutPro.FCPXML.ElementOcclusion {
            FinalCutPro.FCPXML.effectiveOcclusion(
                of: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources
            )
        }
        
        // MARK: - Parsing Tools
        
        /// Returns the value of the given attribute key name for the current element.
        public func attributeValue(key: String) -> String? {
            xmlLeaf.attributeStringValue(forName: key)
        }
        
        /// Returns the value of the given attribute key name for the given element.
        public func attributeValue(key: String, of element: XMLElement) -> String? {
            element.attributeStringValue(forName: key)
        }
        
        /// The absolute start timecode of the element.
        /// This is calculated based on ancestor elements.
        public func absoluteStart(of element: XMLElement) -> Timecode? {
            FinalCutPro.FCPXML.calculateAbsoluteStart(
                of: element,
                breadcrumbs: breadcrumbs,
                resources: resources
            )
        }
        
        /// Return nearest `start` attribute value as `Timecode`, starting from the element and
        /// traversing up through ancestors.
        /// Note that this is relative to the element's parent's timeline and may not be absolute
        /// timecode.
        public func nearestStart() -> Timecode? {
            FinalCutPro.FCPXML.nearestStart(of: xmlLeaf, resources: resources)
        }
        
        /// Return nearest `tcStart` attribute value as `Timecode`, starting from the element and
        /// traversing up through ancestors.
        public func nearestTCStart() -> Timecode? {
            FinalCutPro.FCPXML.nearestTCStart(of: xmlLeaf, resources: resources)
        }
        
        /// If the resource is a format, it is returned.
        /// Otherwise, references are followed until a format is found.
        public func format(for resource: AnyResource) -> Format? {
            FinalCutPro.FCPXML.format(for: resource, in: resources)
        }
        
        /// Returns the resource for the element.
        public var resource: AnyResource? {
            FinalCutPro.FCPXML.firstResource(
                forElementOrAncestors: xmlLeaf,
                in: resources
            )
        }
        
        /// The element's immediate parent, if any.
        /// Will usually be the same as the last element of `breadcrumbs` except when
        /// the current element is media sourced from the root `resources` XML element,
        /// in which case the last breadcrumb should be used instead.
        public var parent: XMLElement? {
            guard let parent = xmlLeaf.parentXMLElement else { return nil }
            // assert(parent == breadcrumbs.last)
            return parent
        }
        
        /// Returns the first ancestor element of the given type.
        public func firstAncestor(ofType: ElementType, includeSelf: Bool) -> XMLElement? {
            if includeSelf {
                if xmlLeaf.name == ofType.rawValue { return xmlLeaf }
            }
            return xmlLeaf.firstAncestor(named: ofType.rawValue)
        }
        
        /// Returns the first ancestor element with the given name.
        public func firstAncestor(named name: String, includeSelf: Bool) -> XMLElement? {
            if includeSelf {
                if xmlLeaf.name == name { return xmlLeaf }
            }
            return xmlLeaf.firstAncestor(named: name)
        }
        
        /// Returns the first ancestor element with the given name.
        public func firstAncestor(named names: [String], includeSelf: Bool) -> XMLElement? {
            if includeSelf {
                if let selfName = xmlLeaf.name, names.contains(selfName) { return xmlLeaf }
            }
            return xmlLeaf.firstAncestor(named: names)
        }
        
        /// Returns the first ancestor element containing an attribute with the given name.
        public func firstAncestor(withAttribute attrName: String, includeSelf: Bool) -> XMLElement? {
            if includeSelf {
                if xmlLeaf.attribute(forName: attrName) != nil { return xmlLeaf }
            }
            return xmlLeaf.firstAncestor(withAttribute: attrName)
        }
        
        /// Types of the element's ancestors (breadcrumbs).
        public var ancestorElementTypes: [FinalCutPro.FCPXML.ElementType] {
            breadcrumbs.compactMap {
                FinalCutPro.FCPXML.ElementType(from: $0)
            }
        }
        
        /// Returns the ancestor event, if the element is contained within a event.
        public func ancestorEvent() -> XMLElement? {
            return firstAncestor(ofType: .structure(.event), includeSelf: true)
        }
        
        /// Returns the ancestor project, if the element is contained within a project.
        public func ancestorProject() -> XMLElement? {
            return firstAncestor(ofType: .structure(.project), includeSelf: true)
        }
        
        /// Returns the ancestor sequence, if the element is contained within a sequence.
        public func ancestorSequence() -> XMLElement? {
            return firstAncestor(ofType: .story(.sequence), includeSelf: true)
        }
        
        /// Returns the first ancestor clip, if the element is contained within a clip.
        public func ancestorClip(includeSelf: Bool) -> XMLElement? {
            let clipTypeStrings = ClipType.allCases.map(\.rawValue)
            return firstAncestor(named: clipTypeStrings, includeSelf: includeSelf)
        }
        
        /// Looks up the resource for the element and returns its ``MediaRep`` instance, if any.
        public var mediaRep: FinalCutPro.FCPXML.MediaRep? {
            FinalCutPro.FCPXML.mediaRep(for: xmlLeaf, in: resources)
        }
        
        /// Looks up the resource for the element and returns its media url, if any.
        public var mediaURL: URL? {
            FinalCutPro.FCPXML.mediaURL(for: xmlLeaf, in: resources)
        }
    }
}

public protocol FCPXMLElementContextKey {
    associatedtype ValueType
    var key: String { get }
}

extension FinalCutPro.FCPXML {
    /// Wrapper for a dictionary key name that also contains strong type information about its
    /// expected value.
    public struct ContextKey<ValueType>: FCPXMLElementContextKey, Hashable {
        public let key: String
        
        public init(key: String) {
            self.key = key
        }
        
        public init(key: String, valueType: ValueType.Type) {
            self.key = key
        }
        
        public init<R: RawRepresentable>(key: R) where R.RawValue == String {
            self.key = key.rawValue
        }
    }
}

extension FinalCutPro.FCPXML.ElementContext {
    public subscript<ValueType>(_ key: FinalCutPro.FCPXML.ContextKey<ValueType>) -> ValueType? {
        get {
            value(for: key)
        }
        _modify {
            var val = value(for: key)
            yield &val
            self[key.key] = val
        }
        set {
            self[key.key] = newValue
        }
    }
    
    private func value<ValueType>(for key: FinalCutPro.FCPXML.ContextKey<ValueType>) -> ValueType? {
        self[key.key] as? ValueType
    }
}

#endif
