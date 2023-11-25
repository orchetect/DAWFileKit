//
//  FCPXML DefaultContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Default context for a model element.
    ///
    /// Adds the following contextual information:
    ///
    /// - ``FinalCutPro/FCPXML/ContextKey/absoluteStart``
    /// - ``FinalCutPro/FCPXML/ContextKey/roles``
    /// - ``FinalCutPro/FCPXML/ContextKey/inheritedRoles``
    /// - ``FinalCutPro/FCPXML/ContextKey/ancestorElementTypes``
    /// - ``FinalCutPro/FCPXML/ContextKey/ancestorEventName``
    /// - ``FinalCutPro/FCPXML/ContextKey/ancestorProjectName``
    /// - ``FinalCutPro/FCPXML/ContextKey/parentType``
    /// - ``FinalCutPro/FCPXML/ContextKey/parentName``
    /// - ``FinalCutPro/FCPXML/ContextKey/parentAbsoluteStart``
    /// - ``FinalCutPro/FCPXML/ContextKey/parentDuration``
    public struct DefaultContext: FCPXMLElementContextBuilder {
        public init() { }
        
        public var contextBuilder: FinalCutPro.FCPXML.ElementContextClosure {
            { element, breadcrumbs, resources, tools in
                var dict: FinalCutPro.FCPXML.ElementContext = [:]
                dict[.absoluteStart] = tools.absoluteStart
                dict[.roles] = tools.roles(includeDefaultRoles: true)
                dict[.inheritedRoles] = tools.inheritedRoles()
                dict[.ancestorElementTypes] = tools.ancestorElementTypes
                dict[.ancestorEventName] = tools.ancestorEventName
                dict[.ancestorProjectName] = tools.ancestorProjectName
                dict[.parentType] = tools.parentType
                dict[.parentName] = tools.parentName
                dict[.parentAbsoluteStart] = tools.parentAbsoluteStart
                dict[.parentDuration] = tools.parentDuration
                return dict
            }
        }
    }
}

// MARK: - Static Constructor

extension FCPXMLElementContextBuilder where Self == FinalCutPro.FCPXML.DefaultContext {
    /// Default context for a model element.
    ///
    /// Adds the following contextual information:
    ///
    /// - ``FinalCutPro/FCPXML/ContextKey/absoluteStart``
    /// - ``FinalCutPro/FCPXML/ContextKey/roles``
    /// - ``FinalCutPro/FCPXML/ContextKey/inheritedRoles``
    /// - ``FinalCutPro/FCPXML/ContextKey/ancestorElementTypes``
    /// - ``FinalCutPro/FCPXML/ContextKey/ancestorEventName``
    /// - ``FinalCutPro/FCPXML/ContextKey/ancestorProjectName``
    /// - ``FinalCutPro/FCPXML/ContextKey/parentType``
    /// - ``FinalCutPro/FCPXML/ContextKey/parentName``
    /// - ``FinalCutPro/FCPXML/ContextKey/parentAbsoluteStart``
    /// - ``FinalCutPro/FCPXML/ContextKey/parentDuration``
    public static var `default`: FinalCutPro.FCPXML.DefaultContext {
        FinalCutPro.FCPXML.DefaultContext()
    }
}

// MARK: - Dictionary Keys

extension FinalCutPro.FCPXML.ContextKey {
    fileprivate enum Key: String {
        case absoluteStart
        case roles
        case inheritedRoles
        case ancestorElementTypes
        case ancestorEventName
        case ancestorProjectName
        case parentType
        case parentName
        case parentAbsoluteStart
        case parentDuration
    }
    
    /// The absolute start timecode of the element.
    public static var absoluteStart: FinalCutPro.FCPXML.ContextKey<Timecode> {
        .init(key: Key.absoluteStart)
    }
    
    /// The element's own roles, if applicable or present.
    /// Includes default roles if none are specified and if applicable.
    public static var roles: FinalCutPro.FCPXML.ContextKey<Set<FinalCutPro.FCPXML.AnyRole>> {
        .init(key: Key.roles)
    }
    
    /// Returns the effective roles of the element inherited from ancestors.
    /// Includes default roles if none are specified and if applicable.
    public static var inheritedRoles: FinalCutPro.FCPXML.ContextKey<Set<FinalCutPro.FCPXML.AnyInterpolatedRole>> {
        .init(key: Key.inheritedRoles)
    }
    
    /// Types of the element's ancestors (breadcrumbs).
    public static var ancestorElementTypes: FinalCutPro.FCPXML.ContextKey<
        [FinalCutPro.FCPXML.ElementType]
    > {
        .init(key: Key.ancestorElementTypes)
    }
    
    /// Contains an event name if the element is a descendent of an event.
    public static var ancestorEventName: FinalCutPro.FCPXML.ContextKey<String> {
        .init(key: Key.ancestorEventName)
    }
    
    /// Contains a project name if the element is a descendent of a project.
    public static var ancestorProjectName: FinalCutPro.FCPXML.ContextKey<String> {
        .init(key: Key.ancestorProjectName)
    }
    
    /// The parent clip's type.
    public static var parentType: FinalCutPro.FCPXML.ContextKey<FinalCutPro.FCPXML.ElementType> {
        .init(key: Key.parentType)
    }
    
    /// The parent clip's name.
    public static var parentName: FinalCutPro.FCPXML.ContextKey<String> {
        .init(key: Key.parentName)
    }
    
    /// The parent clip's absolute start time.
    public static var parentAbsoluteStart: FinalCutPro.FCPXML.ContextKey<Timecode> {
        .init(key: Key.parentAbsoluteStart)
    }
    
    /// The parent clip's duration.
    public static var parentDuration: FinalCutPro.FCPXML.ContextKey<Timecode> {
        .init(key: Key.parentDuration)
    }
}

#endif
