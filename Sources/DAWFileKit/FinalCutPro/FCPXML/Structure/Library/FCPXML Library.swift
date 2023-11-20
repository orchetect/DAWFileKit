//
//  FCPXML Library.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import CoreMedia
@_implementationOnly import OTCore

extension FinalCutPro.FCPXML {
    /// Represents a library location on disk.
    public struct Library {
        public let location: URL
        
        // FCPXMLElementContext
        @EquatableAndHashableExempt
        public var context: FinalCutPro.FCPXML.ElementContext
        
        public init(location: URL) {
            self.location = location
            
            // library doesn't have context since it has no parents
            context = .init()
        }
    }
}

extension FinalCutPro.FCPXML.Library: FCPXMLStructureElement {
    /// Attributes unique to ``Library``.
    public enum Attributes: String {
        case location
    }
    
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let locationString = xmlLeaf.attributeStringValue(
            forName: Attributes.location.rawValue
        ) ?? ""
        
        guard let locationURL = URL(string: locationString) else {
            print("Invalid fcpxml library URL: \(locationString.quoted)")
            return nil
        }
        location = locationURL
        
        // library doesn't have context since it has no parents
        context = .init()
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == structureElementType.rawValue else { return nil }
    }
    
    public var structureElementType: FinalCutPro.FCPXML.StructureElementType {
        .library
    }
    
    public func asAnyStructureElement() -> FinalCutPro.FCPXML.AnyStructureElement {
        .library(self)
    }
}

extension FinalCutPro.FCPXML.Library {
    /// Returns the library name.
    public var name: String {
        // will be a file URL that is URL encoded
        let libName = location
            .deletingPathExtension()
            .lastPathComponent
        
        // decode URL encoding
        let libNameDecoded = libName.removingPercentEncoding ?? libName
        
        return libNameDecoded
    }
}

#endif
