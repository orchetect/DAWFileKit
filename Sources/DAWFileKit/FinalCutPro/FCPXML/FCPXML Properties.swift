//
//  FCPXML Properties.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

// MARK: - Main Public Model Getters

extension FinalCutPro.FCPXML {
    /// Convenience:
    /// Returns all events that exist anywhere within the XML hierarchy.
    /// This is computed, so it is best to avoid repeat calls to this method.
    ///
    /// Events may exist within:
    /// - the `fcpxml` element
    /// - the `fcpxml/library` element if it exists
    public func allEvents() -> FlattenSequence<[AnySequence<XMLElement>]> {
        let rootEvents = fcpxmlElement?.childElements
            .filter(whereElementType: .structure(.event))
            
        // technically there can only be one or zero `library` elements,
        // and FCP will not allow exporting more than one library to FCPXML at a time.
        // but there is nothing stopping us from having more than one.
        let libraryEvents = fcpxmlElement?.childElements
            .filter(whereElementType: .structure(.library))
            .filter(whereElementType: .structure(.event))
        
        // need type erasure since the two sequence types are different
        let combined = [rootEvents?.asAnySequence, libraryEvents?.asAnySequence]
            .compactMap { $0 }
            .joined()
        
        return combined
    }
    
    /// Convenience:
    /// Returns all projects that exist anywhere within the XML hierarchy.
    /// This is computed, so it is best to avoid repeat calls to this method.
    ///
    /// Projects may exist within:
    /// - the `fcpxml` element
    /// - an `fcpxml/event` element
    /// - an `fcpxml/library/event` element
    public func allProjects() -> FlattenSequence<[AnySequence<XMLElement>]> {
        let rootProjects = fcpxmlElement?.childElements
            .filter(whereElementType: .structure(.project))
        
        // will get all events and return their projects
        let eventsProjects = allEvents() // [XMLElement]
            .lazy
            .flatMap { $0.childElements.filter(whereElementType: .structure(.project)) }
            
        // need type erasure since the two sequence types are different
        let combined = [rootProjects?.asAnySequence, eventsProjects.asAnySequence]
            .compactMap { $0 }
            .joined()
        
        return combined
    }
}

extension Sequence {
    fileprivate var asAnySequence: AnySequence<Element> {
        AnySequence(self)
    }
}

#endif
