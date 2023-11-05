//
//  FCPXML Format.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Format shared resource.
    public struct Format: Equatable, Hashable {
        public let name: String
        public let frameDuration: String
        public let fieldOrder: String?
        public let width: Int
        public let height: Int
        public let colorSpace: String
        
        internal init(
            name: String,
            frameDuration: String,
            fieldOrder: String?,
            width: Int,
            height: Int,
            colorSpace: String
        ) {
            self.name = name
            self.frameDuration = frameDuration
            self.fieldOrder = fieldOrder
            self.width = width
            self.height = height
            self.colorSpace = colorSpace
        }
        
        init(from xmlLeaf: XMLElement) {
            name = xmlLeaf.attributeStringValue(forName: Attributes.name.rawValue) ?? ""
            
            frameDuration = xmlLeaf.attributeStringValue(forName: Attributes.frameDuration.rawValue) ?? ""
            
            fieldOrder = xmlLeaf.attributeStringValue(forName: Attributes.fieldOrder.rawValue)
            
            width = Int(xmlLeaf.attributeStringValue(forName: Attributes.width.rawValue) ?? "") ?? 0
            
            height = Int(xmlLeaf.attributeStringValue(forName: Attributes.height.rawValue) ?? "") ?? 0
            
            colorSpace = xmlLeaf.attributeStringValue(forName: Attributes.colorSpace.rawValue) ?? ""
        }
    }
}

extension FinalCutPro.FCPXML.Format {
    public enum Attributes: String {
        case name
        case frameDuration
        case fieldOrder // only present if video is interlaced
        case width
        case height
        case colorSpace
    }
}

#endif
