//
//  FCPXML AnyElementModelType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

// MARK: - AnyElementModelType

extension FinalCutPro.FCPXML {
    public struct AnyElementModelType: Sendable {
        public var base: any FCPXMLElementModelTypeProtocol
        
        public var supportedElementTypes: Set<FinalCutPro.FCPXML.ElementType> {
            base.supportedElementTypes
        }
        
        public init<T: FCPXMLElementModelTypeProtocol>(base: T) {
            self.base = base
        }
    }
}

#endif
