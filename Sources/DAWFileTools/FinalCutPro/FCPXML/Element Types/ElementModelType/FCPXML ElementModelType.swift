//
//  FCPXML ElementModelType.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

// MARK: - ElementModelType

extension FinalCutPro.FCPXML {
    public struct ElementModelType<ModelType: FCPXMLElement>: FCPXMLElementModelTypeProtocol {
        public var supportedElementTypes: Set<FinalCutPro.FCPXML.ElementType> {
            ModelType.supportedElementTypes
        }
        
        init() { }
    }
}

#endif
