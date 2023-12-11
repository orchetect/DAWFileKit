//
//  FCPXML ElementContext Tools.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML.ElementContext {
    /// Class instance that provides useful context for a FCPXML element.
    public struct Tools {
        var element: XMLElement
        var breadcrumbs: [XMLElement]
        var resources: XMLElement? // `resources` container element
        
        init(
            element: XMLElement,
            breadcrumbs: [XMLElement],
            resources: XMLElement? // `resources` container element
        ) {
            self.element = element
            self.breadcrumbs = breadcrumbs
            self.resources = resources
        }
        
        // MARK: - Properties
        
        /// The current element type.
        public var elementType: FinalCutPro.FCPXML.ElementType? {
            element.fcpElementType
        }
        
        /// The absolute start time of the current element in seconds.
        /// This is calculated based on ancestor elements.
        public var absoluteStart: TimeInterval? {
            element._fcpCalculateAbsoluteStart(
                ancestors: breadcrumbs
            )
        }
        
        /// The absolute start time of the current element expressed as timecode.
        /// This is calculated based on ancestor elements.
        public var absoluteStartAsTimecode: Timecode? {
            guard let absoluteStart = absoluteStart else { return nil }
            return try? element._fcpTimecode(
                fromRealTime: absoluteStart,
                resources: resources
            )
        }
        
        /// The absolute end timecode of the current element in seconds.
        /// This is calculated based on ancestor elements.
        public var absoluteEnd: TimeInterval? {
            guard let absoluteStart = absoluteStart,
                  let duration = element.fcpDuration
            else { return nil }
            return absoluteStart + duration.doubleValue
        }
        
        /// The absolute end time of the current element expressed as timecode.
        /// This is calculated based on ancestor elements.
        public var absoluteEndAsTimecode: Timecode? {
            guard let absoluteEnd = absoluteEnd else { return nil }
            return try? element._fcpTimecode(
                fromRealTime: absoluteEnd,
                resources: resources
            )
        }
        
        /// Returns the effective `format` resource for the current element.
        public var effectiveFormat: FinalCutPro.FCPXML.Format? {
            element._fcpFirstFormatResourceForElementOrAncestors(in: resources)
        }
        
        /// Returns an event name if the current element is a descendent of an event.
        public var ancestorEventName: String? {
            let ancestorEvent = element.ancestorElements(includingSelf: false)
                .first(whereFCPElementType: .event)
            return ancestorEvent?.fcpName
        }
        
        /// Returns a project name if the current element is a descendent of a project.
        public var ancestorProjectName: String? {
            let ancestorEvent = element.ancestorElements(includingSelf: false)
                .first(whereFCPElementType: .project)
            return ancestorEvent?.fcpName
        }
        
        /// The parent element's type.
        public var parentType: FinalCutPro.FCPXML.ElementType? {
            parent?.fcpElementType
        }
        
        /// The parent element's name.
        public var parentName: String? {
            parent?.fcpName
        }
        
        /// The parent element's absolute start time in seconds.
        /// This is calculated based on ancestor elements.
        public var parentAbsoluteStart: TimeInterval? {
            guard let parent = parent else { return nil }
            return parent._fcpCalculateAbsoluteStart(
                ancestors: breadcrumbs.dropFirst()
            )
        }
        
        /// The parent element's absolute start time expressed as timecode.
        /// This is calculated based on ancestor elements.
        public var parentAbsoluteStartAsTimecode: Timecode? {
            guard let parentAbsoluteStart = parentAbsoluteStart else { return nil }
            return try? element._fcpTimecode(
                fromRealTime: parentAbsoluteStart,
                resources: resources
            )
        }
        
        /// The parent element's absolute end time in seconds.
        /// This is calculated based on ancestor elements.
        public var parentAbsoluteEnd: TimeInterval? {
            guard let parentAbsoluteStart = parentAbsoluteStart,
                  let parentDuration = parentDuration
            else { return nil }
            return parentAbsoluteStart + parentDuration
        }
        
        /// The parent element's absolute end time expressed as timecode.
        /// This is calculated based on ancestor elements.
        public var parentAbsoluteEndAsTimecode: Timecode? {
            guard let parentAbsoluteEnd = parentAbsoluteEnd else { return nil }
            return try? element._fcpTimecode(
                fromRealTime: parentAbsoluteEnd,
                resources: resources
            )
        }
        
        /// The parent element's duration in seconds.
        public var parentDuration: TimeInterval? {
            guard let parent = parent else { return nil }
            return parent._fcpNearestDuration(
                ancestors: breadcrumbs.dropFirst(),
                includingSelf: true
            )?.doubleValue
        }
        
        /// The parent element's duration expressed as timecode.
        public var parentDurationAsTimecode: Timecode? {
            guard let parentDuration = parentDuration else { return nil }
            return try? element._fcpTimecode(
                fromRealTime: parentDuration,
                resources: resources
            )
        }
        
        /// The element's local roles, if applicable or present.
        /// These roles are either attached to the element itself or in some cases are acquired from
        /// the element's contents.
        public func localRoles(includeDefaultRoles: Bool) -> [FinalCutPro.FCPXML.AnyRole] {
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
        public var inheritedRoles: [FinalCutPro.FCPXML.AnyInterpolatedRole] {
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
                container: parentStart ... parentEnd,
                internalStart: elementStart,
                internalEnd: absoluteEnd
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
        
        /// The absolute start timecode of the element in seconds.
        /// This is calculated based on ancestor elements.
        public func absoluteStart(of element: XMLElement) -> TimeInterval? {
            element._fcpCalculateAbsoluteStart(
                ancestors: breadcrumbs
            )
        }
        
        /// Return nearest `start` attribute value as `Timecode`, starting from the element and
        /// traversing up through ancestors.
        /// Note that this is relative to the element's parent's timeline and may not be absolute
        /// timecode.
        public func nearestStart(includingSelf: Bool = true) -> Fraction? {
            element._fcpNearestStart(includingSelf: includingSelf)
        }
        
        /// Return nearest `tcStart` attribute value as `Timecode`, starting from the element and
        /// traversing up through ancestors.
        public func nearestTCStart(includingSelf: Bool = true) -> Fraction? {
            element._fcpNearestTCStart(includingSelf: includingSelf)
        }
        
        /// If the resource is a `format`, it is returned.
        /// Otherwise, references are followed until a `format` is found.
        public func format(for resource: XMLElement) -> FinalCutPro.FCPXML.Format? {
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
        public func firstAncestor(
            ofType: FinalCutPro.FCPXML.ElementType,
            includeSelf: Bool
        ) -> XMLElement? {
            element
                .ancestorElements(includingSelf: includeSelf)
                .first(whereFCPElementType: ofType)
        }
        
        /// Returns the first ancestor element with the given name.
        public func firstAncestor(named name: String, includeSelf: Bool) -> XMLElement? {
            ((includeSelf ? [element] : []) + breadcrumbs)
                .first(whereElementNamed: name)
        }
        
        /// Returns the first ancestor element with the given name.
        public func firstAncestor(named names: [String], includeSelf: Bool) -> XMLElement? {
            ((includeSelf ? [element] : []) + breadcrumbs)
                .first {
                    guard let name = $0.name else { return false }
                    return names.contains(name)
                }
        }
        
        /// Returns the first ancestor element containing an attribute with the given name.
        public func firstAncestor(withAttribute attrName: String, includeSelf: Bool) -> XMLElement? {
            ((includeSelf ? [element] : []) + breadcrumbs)
                .first(withAttribute: attrName)?.element
        }
        
        /// Types and lanes of the element's ancestors (breadcrumbs).
        public func ancestorElementTypesAndLanes() -> some Swift.Sequence<
            (type: FinalCutPro.FCPXML.ElementType, lane: Int?)
        > {
            element._fcpAncestorElementTypesAndLanes(ancestors: breadcrumbs, includeSelf: false)
        }
        
        /// Returns the ancestor `event`, if the element is an `event` or contained within a `event`.
        public func ancestorEvent() -> FinalCutPro.FCPXML.Event? {
            firstAncestor(ofType: .event, includeSelf: true)?
                .fcpAsEvent
        }
        
        /// Returns the ancestor `project`, if the element is a `project` or contained within a `project`.
        public func ancestorProject() -> FinalCutPro.FCPXML.Project? {
            firstAncestor(ofType: .project, includeSelf: true)?
                .fcpAsProject
        }
        
        /// Returns the ancestor `sequence`, if the element is a `sequence` or contained within a `sequence`.
        public func ancestorSequence() -> FinalCutPro.FCPXML.Sequence? {
            firstAncestor(ofType: .sequence, includeSelf: true)?
                .fcpAsSequence
        }
        
        /// Returns the first ancestor clip, if the element is contained within a clip.
        public func ancestorClip(includeSelf: Bool) -> XMLElement? {
            element.fcpAncestorClip(ancestors: breadcrumbs, includeSelf: includeSelf)
        }
        
        /// Looks up the resource for the element and returns its `media-rep` instance, if any.
        public var mediaRep: FinalCutPro.FCPXML.MediaRep? {
            element._fcpMediaRep(in: resources)
        }
        
        /// Looks up the resource for the element and returns its media url, if any.
        public var mediaURL: URL? {
            element.fcpMediaURL(in: resources)
        }
    }
}

#endif
