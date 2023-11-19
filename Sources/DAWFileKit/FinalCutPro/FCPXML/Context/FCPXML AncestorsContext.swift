//
//  FCPXML AncestorsContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Ancestors context for a model element.
    /// Adds context information for an element's parent, as well as absolute timecode information.
    public struct AncestorsContext: FCPXMLElementContextBuilder {
        public init() { }
        
        public var contextBuilder: FinalCutPro.FCPXML.ElementContextClosure {
            { element, resources, tools in
                var dict: FinalCutPro.FCPXML.ElementContext = [:]
                dict[.absoluteStart] = tools.absoluteStart
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

extension FCPXMLElementContextBuilder where Self == FinalCutPro.FCPXML.AncestorsContext {
    /// Ancestors context for a model element.
    /// Adds context information for an element's parent, as well as absolute timecode information.
    public static var ancestors: FinalCutPro.FCPXML.AncestorsContext {
        FinalCutPro.FCPXML.AncestorsContext()
    }
}

// MARK: - Dictionary Keys

extension FinalCutPro.FCPXML.ContextKey {
    fileprivate enum Key: String {
        case absoluteStart
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
