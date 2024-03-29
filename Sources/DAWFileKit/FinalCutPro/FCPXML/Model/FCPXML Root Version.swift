//
//  FCPXML Root Version.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

extension FinalCutPro.FCPXML {
    /// FCPXML format version.
    public enum Version: String, Equatable, Hashable, CaseIterable, Sendable {
        case ver1_0 = "1.0"
        case ver1_1 = "1.1"
        case ver1_2 = "1.2"
        case ver1_3 = "1.3"
        case ver1_4 = "1.4"
        case ver1_5 = "1.5"
        case ver1_6 = "1.6"
        case ver1_7 = "1.7"
        case ver1_8 = "1.8"
        case ver1_9 = "1.9"
        case ver1_10 = "1.10"
        case ver1_11 = "1.11"
    }
}

extension FinalCutPro.FCPXML.Version {
    /// Returns the latest FCPXML format version supported.
    public static var latest: Self { Self.allCases.last ?? .ver1_11 }
}

#endif
