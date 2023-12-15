//
//  FCPXML CaptionsExtractionPreset.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// FCPXML extraction preset that extracts closed captions.
    public struct CaptionsExtractionPreset: FCPXMLExtractionPreset {
        public init() { }
        
        public func perform(
            on extractable: XMLElement,
            scope: FinalCutPro.FCPXML.ExtractionScope
        ) async -> [FinalCutPro.FCPXML.ExtractedCaption] {
            let extracted = await extractable.fcpExtract(
                types: [.caption],
                scope: scope
            )
            
            let wrapped = extracted
                .compactMap { ExtractedCaption($0) }
            
            return wrapped
        }
    }
}

extension FCPXMLExtractionPreset where Self == FinalCutPro.FCPXML.CaptionsExtractionPreset {
    /// FCPXML extraction preset that extracts closed captions.
    public static var captions: FinalCutPro.FCPXML.CaptionsExtractionPreset {
        FinalCutPro.FCPXML.CaptionsExtractionPreset()
    }
}

extension FinalCutPro.FCPXML {
    // TODO: XMLElement is not Sendable
    
    /// An extracted caption element with pertinent data.
    public struct ExtractedCaption: FCPXMLExtractedModelElement, @unchecked Sendable {
        public typealias Model = Caption
        public let element: XMLElement
        public let breadcrumbs: [XMLElement]
        public let resources: XMLElement?
        
        init?(_ extractedElement: ExtractedElement) {
            element = extractedElement.element
            breadcrumbs = extractedElement.breadcrumbs
            resources = extractedElement.resources
        }
        
        /// Return the a context value for the element.
        public func value<Value>(
            forContext contextKey: FinalCutPro.FCPXML.ElementContext<Value>
        ) -> Value {
            contextKey.value(from: element, breadcrumbs: breadcrumbs, resources: resources)
        }
        
        // Convenience getters
        
        /// Caption name.
        public var name: String? {
            model.name
        }
        
        /// Caption note, if any.
        public var note: String? {
            model.note
        }
        
        /// Inherited roles from container(s).
        public var roles: [AnyInterpolatedRole] {
            value(forContext: .inheritedRoles)
        }
    }
}

#endif
