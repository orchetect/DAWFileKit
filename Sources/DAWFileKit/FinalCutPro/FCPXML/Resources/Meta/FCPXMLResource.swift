//
//  FCPXMLResource.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

/// FCPXML resource elements.
public protocol FCPXMLResource where Self: Equatable {
    /// Returns the resource type enum case.
    var resourceType: FinalCutPro.FCPXML.ResourceType { get }
    
    /// Returns the resource as ``FinalCutPro/FCPXML/AnyResource``.
    func asAnyResource() -> FinalCutPro.FCPXML.AnyResource
    
    /// Initialize from an XML leaf (element).
    init?(from xmlLeaf: XMLElement)
}

extension FCPXMLResource {
    func isEqual(to other: some FCPXMLResource) -> Bool {
        self.asAnyResource() == other.asAnyResource()
    }
}

// MARK: - Collection Methods

extension Collection<FinalCutPro.FCPXML.AnyResource> {
    public func contains(_ resource: any FCPXMLResource) -> Bool {
        contains(where: { $0.wrapped.isEqual(to: resource) })
    }
}

extension Dictionary where Value == FinalCutPro.FCPXML.AnyResource {
    public func contains(value resource: any FCPXMLResource) -> Bool {
        values.contains(resource)
    }
}

extension Collection<FCPXMLResource> {
    public func contains(_ resource: FinalCutPro.FCPXML.AnyResource) -> Bool {
        contains(where: { $0.asAnyResource() == resource })
    }
}

extension Dictionary where Value: FCPXMLResource {
    public func contains(value resource: FinalCutPro.FCPXML.AnyResource) -> Bool {
        values.contains(where: { $0.asAnyResource() == resource })
    }
}

#endif
