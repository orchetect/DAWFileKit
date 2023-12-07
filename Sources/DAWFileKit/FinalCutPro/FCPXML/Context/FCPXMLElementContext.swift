//
//  FCPXMLElementContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

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
        from element: XMLElement,
        breadcrumbs: [XMLElement],
        resources: XMLElement
    ) -> FinalCutPro.FCPXML.ElementContext {
        let tools = FinalCutPro.FCPXML.ContextTools(element: element, breadcrumbs: breadcrumbs, resources: resources)
        return contextBuilder(element, breadcrumbs, resources, tools)
    }
}

extension FinalCutPro.FCPXML {
    /// Context for a model element.
    public typealias ElementContext = [String: Any]
    
    /// Context builder closure for a model element.
    /// `breadcrumbs` (ancestors) are ordered nearest to furthest ancestor.
    public typealias ElementContextClosure = (
        _ element: XMLElement,
        _ breadcrumbs: [XMLElement],
        _ resources: XMLElement,
        _ tools: FinalCutPro.FCPXML.ContextTools
    ) -> ElementContext
    
    /// Class instance that provides useful context for a FCPXML element.
    public struct ContextTools {
        var element: XMLElement
        var breadcrumbs: [XMLElement]
        var resources: XMLElement
        
        init(
            element: XMLElement,
            breadcrumbs: [XMLElement],
            resources: XMLElement
        ) {
            self.element = element
            self.breadcrumbs = breadcrumbs
            self.resources = resources
        }
        
        // MARK: - Properties
        
        /// The current element type.
        public var elementType: ElementType? {
            element.fcpElementType
        }
        
        /// The absolute start time of the current element.
        /// This is calculated based on ancestor elements.
        public var absoluteStart: Fraction? {
            element._fcpCalculateAbsoluteStart(
                ancestors: breadcrumbs
            )
        }
        
        /// The absolute end timecode of the current element.
        /// This is calculated based on ancestor elements.
        public var absoluteEnd: Fraction? {
            guard let absoluteStart = absoluteStart,
                  let duration = element.fcpDuration
            else { return nil }
            return absoluteStart + duration
        }
        
        /// Returns the effective `format` resource for the current element.
        public var effectiveFormat: XMLElement? {
            element._fcpFirstFormatResourceForElementOrAncestors(in: resources)
        }
        
        /// Returns an event name if the current element is a descendent of an event.
        public var ancestorEventName: String? {
            let ancestorEvent = element.ancestorElements(includingSelf: false)
                .first(whereElementType: .structure(.event))
            return ancestorEvent?.fcpName
        }
        
        /// Returns a project name if the current element is a descendent of a project.
        public var ancestorProjectName: String? {
            let ancestorEvent = element.ancestorElements(includingSelf: false)
                .first(whereElementType: .structure(.project))
            return ancestorEvent?.fcpName
        }
        
        /// The parent element's type.
        public var parentType: ElementType? {
            parent?.fcpElementType
        }
        
        /// The parent element's name.
        public var parentName: String? {
            parent?.fcpName
        }
        
        /// The parent element's absolute start time.
        /// This is calculated based on ancestor elements.
        public var parentAbsoluteStart: Fraction? {
            guard let parent = parent else { return nil }
            return parent._fcpCalculateAbsoluteStart(
                ancestors: breadcrumbs.dropFirst()
            )
        }
        
        /// The parent element's absolute end time.
        /// This is calculated based on ancestor elements.
        public var parentAbsoluteEnd: Fraction? {
            guard let parentAbsoluteStart = parentAbsoluteStart,
                  let parentDuration = parentDuration
            else { return nil }
            return parentAbsoluteStart + parentDuration
        }
        
        /// The parent element's duration.
        public var parentDuration: Fraction? {
            guard let parent = parent else { return nil }
            return parent._fcpNearestDuration(
                ancestors: breadcrumbs.dropFirst(),
                includingSelf: false
            )
        }
        
        /// The element's local roles, if applicable or present.
        /// These roles are either attached to the element itself or in some cases are acquired from
        /// the element's contents.
        public func localRoles(includeDefaultRoles: Bool) -> [AnyRole] {
            var elementRoles = element._fcpLocalRoles(
                resources: resources,
                auditions: .active
            )
            
            if includeDefaultRoles, let elementType = elementType {
                elementRoles = FinalCutPro.FCPXML.addDefaultRoles(for: elementType, to: elementRoles)
            }
            
            return elementRoles.map(\.wrapped)
        }
        
        /// Returns the effective roles of the element inherited from ancestors.
        public var inheritedRoles: [AnyInterpolatedRole] {
            element._fcpInheritedRoles(
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
            
            return FinalCutPro.FCPXML._occlusion(
                containerTimeRange: parentStart ... parentEnd,
                internalStartTime: elementStart,
                internalEndTime: absoluteEnd
            )
        }
        
        /// Returns the effective occlusion for the current element with regards the main timeline.
        public var effectiveOcclusion: FinalCutPro.FCPXML.ElementOcclusion {
            element._fcpEffectiveOcclusion(
                ancestors: breadcrumbs
            )
        }
        
        // MARK: - Parsing Tools
        
        /// Returns the value of the given attribute key name for the current element.
        public func attributeValue(key: String) -> String? {
            element.stringValue(forAttributeNamed: key)
        }
        
        /// Returns the value of the given attribute key name for the given element.
        public func attributeValue(key: String, of element: XMLElement) -> String? {
            element.stringValue(forAttributeNamed: key)
        }
        
        /// The absolute start timecode of the element.
        /// This is calculated based on ancestor elements.
        public func absoluteStart(of element: XMLElement) -> Fraction? {
            element._fcpCalculateAbsoluteStart(
                ancestors: breadcrumbs
            )
        }
        
        /// Return nearest `start` attribute value as `Timecode`, starting from the element and
        /// traversing up through ancestors.
        /// Note that this is relative to the element's parent's timeline and may not be absolute
        /// timecode.
        public func nearestStart() -> Fraction? {
            element._fcpNearestStart(includingSelf: true)
        }
        
        /// Return nearest `tcStart` attribute value as `Timecode`, starting from the element and
        /// traversing up through ancestors.
        public func nearestTCStart() -> Fraction? {
            element._fcpNearestTCStart(includingSelf: true)
        }
        
        /// If the resource is a `format`, it is returned.
        /// Otherwise, references are followed until a `format` is found.
        public func format(for resource: XMLElement) -> XMLElement? {
            resource._fcpFormatResource(in: resources)
        }
        
        /// Returns the resource element for the element.
        public var resource: XMLElement? {
            element._fcpFirstResourceForElementOrAncestors(in: resources)
        }
        
        /// The element's immediate parent, if any.
        /// Will usually be the same as the last element of `breadcrumbs` except when
        /// the current element is media sourced from the root `resources` XML element,
        /// in which case the last breadcrumb should be used instead.
        public var parent: XMLElement? {
            guard let parent = element.parentElement else { return nil }
            // assert(parent == breadcrumbs.last)
            return parent
        }
        
        /// Returns the first ancestor element of the given type.
        public func firstAncestor(ofType: ElementType, includeSelf: Bool) -> XMLElement? {
            element
                .ancestorElements(includingSelf: includeSelf)
                .first(whereElementType: ofType)
        }
        
        /// Returns the first ancestor element with the given name.
        public func firstAncestor(named name: String, includeSelf: Bool) -> XMLElement? {
            element
                .ancestorElements(includingSelf: includeSelf)
                .first(whereElementNamed: name)
        }
        
        /// Returns the first ancestor element with the given name.
        public func firstAncestor(named names: [String], includeSelf: Bool) -> XMLElement? {
            element
                .ancestorElements(includingSelf: includeSelf)
                .first {
                    guard let name = $0.name else { return false }
                    return names.contains(name)
                }
        }
        
        /// Returns the first ancestor element containing an attribute with the given name.
        public func firstAncestor(withAttribute attrName: String, includeSelf: Bool) -> XMLElement? {
            element
                .ancestorElements(includingSelf: includeSelf)
                .first(withAttribute: attrName)?.element
        }
        
        /// Types of the element's ancestors (breadcrumbs).
        public var ancestorElementTypes: [(lane: Int?, type: FinalCutPro.FCPXML.ElementType)] {
            breadcrumbs.compactMap {
                guard let type = $0.fcpElementType else { return nil }
                let laneStr = $0.fcpLane
                let lane: Int? = laneStr != nil ? Int(laneStr!) : nil
                return (lane: lane, type: type)
            }
        }
        
        /// Returns the ancestor `event`, if the element is an `event` or contained within a `event`.
        public func ancestorEvent() -> XMLElement? {
            return firstAncestor(ofType: .structure(.event), includeSelf: true)
        }
        
        /// Returns the ancestor `project`, if the element is a `project` or contained within a `project`.
        public func ancestorProject() -> XMLElement? {
            return firstAncestor(ofType: .structure(.project), includeSelf: true)
        }
        
        /// Returns the ancestor `sequence`, if the element is a `sequence` or contained within a `sequence`.
        public func ancestorSequence() -> XMLElement? {
            return firstAncestor(ofType: .story(.sequence), includeSelf: true)
        }
        
        /// Returns the first ancestor clip, if the element is contained within a clip.
        public func ancestorClip(includeSelf: Bool) -> XMLElement? {
            let clipTypeStrings = ClipType.allCases.map(\.rawValue)
            return firstAncestor(named: clipTypeStrings, includeSelf: includeSelf)
        }
        
        /// Looks up the resource for the element and returns its `media-rep` instance, if any.
        public var mediaRep: XMLElement? {
            element._fcpMediaRep(in: resources)
        }
        
        /// Looks up the resource for the element and returns its media url, if any.
        public var mediaURL: URL? {
            element.fcpMediaURL(in: resources)
        }
    }
}

#endif
