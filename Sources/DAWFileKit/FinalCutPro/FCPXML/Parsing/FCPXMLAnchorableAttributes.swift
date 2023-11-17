//
//  FCPXMLAnchorableAttributes.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
@_implementationOnly import OTCore

/// Attributes common to anchorable FCPXML objects.
///
/// Equivalent to `%ao_attrs` in the DTD.
public protocol FCPXMLAnchorableAttributes {
    /// Specifies where the object is contained/anchored relative to its parent.
    /// - `0` = contained inside its parent (default)
    /// - `> 0` = anchored above its parent
    /// - `< 0` = anchored below its parent
    var lane: Int? { get }
    
    /// Defines the location of the object in the parent timeline (default is '0').
    var offset: Timecode? { get }
}

public enum FCPXMLAnchorableAttributesKey: String, XMLParsableAttributesKey {
    case lane
    case offset
}

extension FCPXMLAnchorableAttributes {
    fileprivate typealias Key = FCPXMLAnchorableAttributesKey
    
    // MARK: - Raw Values
    
    static func parseAnchorableAttributesRawValues(
        from xmlLeaf: XMLElement
    ) -> [FCPXMLAnchorableAttributesKey: String] {
        xmlLeaf.parseAttributesRawValues(key: Key.self)
    }
    
    /// Parse attributes if present, and return typed values.
    static func parseAnchorableAttributes(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> (
        lane: Int?,
        offset: Timecode?
    ) {
        let rawValues = parseAnchorableAttributesRawValues(from: xmlLeaf)
        
        // `lane`
        let lane = rawValues[.lane]?.int
        
        // `offset`
        let offset = try? FinalCutPro.FCPXML.timecode(
            fromRational: rawValues[.offset] ?? "",
            xmlLeaf: xmlLeaf,
            resources: resources
        )
        
        return (lane: lane, offset: offset)
    }
}

#endif
