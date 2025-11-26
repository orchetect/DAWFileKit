//
//  TrackArchive TrackTimeDomain.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    /// Cubase Track Archive track time domain.
    public enum TrackTimeDomain: Int {
        /// Bars & beats timebase - computations are against PPQ base and tempo
        case musical = 0
        
        /// Time linear timebase - real / absolute time
        case linear = 1
    }
}

extension Cubase.TrackArchive.TrackTimeDomain: Equatable { }

extension Cubase.TrackArchive.TrackTimeDomain: Hashable { }

extension Cubase.TrackArchive.TrackTimeDomain: Sendable { }

#endif
