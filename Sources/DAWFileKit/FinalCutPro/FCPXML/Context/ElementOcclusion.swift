//
//  FCPXML ElementOcclusion.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum ElementOcclusion: Equatable, Hashable, CaseIterable {
        case notOccluded
        case partiallyOccluded
        case fullyOccluded
    }
}

#endif
