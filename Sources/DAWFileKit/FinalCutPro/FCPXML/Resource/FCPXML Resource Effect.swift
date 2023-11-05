//
//  FCPXML Resource Effect.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML.AnyResource {
    public struct Effect: Equatable, Hashable {
        let name: String
        let uid: String
        
        internal init(name: String, uid: String) {
            self.name = name
            self.uid = uid
        }
        
        init(from xmlLeaf: XMLElement) {
            name = xmlLeaf.attributeStringValue(forName: Attributes.name.rawValue) ?? ""
            
            uid = xmlLeaf.attributeStringValue(forName: Attributes.uid.rawValue) ?? ""
        }
    }
}

extension FinalCutPro.FCPXML.AnyResource.Effect {
    public enum Attributes: String {
        case name
        case uid
    }
}

#endif
