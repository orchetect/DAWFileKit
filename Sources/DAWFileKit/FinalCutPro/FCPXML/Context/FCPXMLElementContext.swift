//
//  FCPXMLElementContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

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
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> FinalCutPro.FCPXML.ElementContext {
        let tools = FinalCutPro.FCPXML.ContextTools(xmlLeaf: xmlLeaf, resources: resources)
        return contextBuilder(xmlLeaf, resources, tools)
    }
}

extension FinalCutPro.FCPXML {
    /// Context for a model element.
    public typealias ElementContext = [String: Any]
    
    /// Context builder closure for a model element.
    public typealias ElementContextClosure = (
        _ element: XMLElement,
        _ resources: [String: FinalCutPro.FCPXML.AnyResource],
        _ tools: FinalCutPro.FCPXML.ContextTools
    ) -> ElementContext
    
    /// Class instance that provides useful context for a FCPXML element.
    public struct ContextTools {
        var xmlLeaf: XMLElement
        var resources: [String: FinalCutPro.FCPXML.AnyResource]
        
        init(
            xmlLeaf: XMLElement,
            resources: [String: FinalCutPro.FCPXML.AnyResource]
        ) {
            self.xmlLeaf = xmlLeaf
            self.resources = resources
        }
        
        // MARK: - Properties
        
        /// The absolute start timecode of the current element.
        /// This is calculated based on ancestor elements.
        public var absoluteStart: Timecode? {
            FinalCutPro.FCPXML.calculateAbsoluteStart(
                element: xmlLeaf,
                resources: resources
            )
        }
        
        /// Returns the effective format for the current element.
        public var effectiveFormat: Format? {
            FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: xmlLeaf, in: resources)
        }
        
        /// Returns an event name if the current element is a descendent of an event.
        public var ancestorEventName: String? {
            let ancestorEvent = xmlLeaf.first(
                ancestorNamed: FinalCutPro.FCPXML.StructureElementType.event.rawValue
            )
            return FinalCutPro.FCPXML.getNameAttribute(from: ancestorEvent)
        }
        
        /// Returns a project name if the current element is a descendent of a project.
        public var ancestorProjectName: String? {
            let ancestorProject = xmlLeaf.first(
                ancestorNamed: FinalCutPro.FCPXML.StructureElementType.project.rawValue
            )
            return FinalCutPro.FCPXML.getNameAttribute(from: ancestorProject)
        }
        
        /// The parent element's type.
        public var parentType: ElementType? {
            guard let parent = xmlLeaf.parentXMLElement else { return nil }
            guard let nameValue = parent.name else { return nil }
            return FinalCutPro.FCPXML.ElementType(rawValue: nameValue)
        }
        
        /// The parent element's name.
        public var parentName: String? {
            guard let parent = xmlLeaf.parentXMLElement else { return nil }
            return FinalCutPro.FCPXML.getNameAttribute(from: parent)
        }
        
        /// The parent element's absolute start time.
        /// This is calculated based on ancestor elements.
        public var parentAbsoluteStart: Timecode? {
            guard let parent = xmlLeaf.parentXMLElement else { return nil }
            return FinalCutPro.FCPXML.aggregateOffset(
                of: parent,
                resources: resources
            )
        }
        
        /// The parent element's duration.
        public var parentDuration: Timecode? {
            guard let parent = xmlLeaf.parentXMLElement else { return nil }
            guard let durationValue = parent.attributeStringValue(forName: "duration") else { return nil }
            return try? FinalCutPro.FCPXML.timecode(
                fromRational: durationValue,
                xmlLeaf: parent,
                resources: resources
            )
        }
        
        // MARK: - Parsing
        
        /// Returns the value of the given attribute key name.
        public func attributeValue(key: String) -> String? {
            xmlLeaf.attributeStringValue(forName: key)
        }
        
        /// The absolute start timecode of the element.
        /// This is calculated based on ancestor elements.
        public func absoluteStart(of element: XMLElement) -> Timecode? {
            FinalCutPro.FCPXML.calculateAbsoluteStart(
                element: element,
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
