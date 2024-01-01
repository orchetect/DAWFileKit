//
//  FCPXML FrameSampling.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// `frameSampling` attribute value.
    /// Used in `conform-rate` and `timeMap` elements.
    public enum FrameSampling: String, Equatable, Hashable, CaseIterable, Sendable {
        case floor
        case nearestNeighbor = "nearest-neighbor"
        case frameBlending = "frame-blending"
        case opticalFlowClassic = "optical-flow-classic"
        case opticalFlow = "optical-flow"
    }
}

extension FinalCutPro.FCPXML.FrameSampling: FCPXMLAttribute {
    public static let attributeName: String = "frameSampling"
}

#endif
