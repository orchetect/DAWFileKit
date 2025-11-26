//
//  FCPXML Root Version.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import SwiftExtensions

extension FinalCutPro.FCPXML {
    /// FCPXML format version.
    public struct Version: Equatable, Hashable, Sendable {
        /// Major version number.
        public let major: Int
        
        /// Minor version number.
        public let minor: Int
        
        public init(major: Int, minor: Int) {
            self.major = major
            self.minor = minor
        }
    }
}

// MARK: - Raw String Value

extension FinalCutPro.FCPXML.Version: RawRepresentable {
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        let components = rawValue.split(separator: ".", omittingEmptySubsequences: false)
        
        // allow X.X or X.X.X
        guard (2...3).contains(components.count) else { return nil }
        
        guard let maj = Int(components[0]),
              let min = Int(components[1])
        else { return nil }
        
        // we're not using build/revision number (3rd SemVer place) but if it's present,
        // ensure it's a valid number in order to validate the entire version string
        if components.count > 2 {
            guard let rev = Int(components[2])
            else { return nil }
            
            _ = rev // not used by FCPXML versions, but may be used in future
        }
        
        major = maj
        minor = min
    }
    
    public var rawValue: String {
        "\(major).\(minor)"
    }
}

// MARK: - Static Instances

extension FinalCutPro.FCPXML.Version {
    public static let ver1_0: Self = Self(major: 1, minor: 0)
    public static let ver1_1: Self = Self(major: 1, minor: 1)
    public static let ver1_2: Self = Self(major: 1, minor: 2)
    public static let ver1_3: Self = Self(major: 1, minor: 3)
    public static let ver1_4: Self = Self(major: 1, minor: 4)
    public static let ver1_5: Self = Self(major: 1, minor: 5)
    public static let ver1_6: Self = Self(major: 1, minor: 6)
    public static let ver1_7: Self = Self(major: 1, minor: 7)
    public static let ver1_8: Self = Self(major: 1, minor: 8)
    public static let ver1_9: Self = Self(major: 1, minor: 9)
    
    /// FCPXML 1.10.
    /// Format is a `fcpxmld` bundle.
    public static let ver1_10: Self = Self(major: 1, minor: 10)
    
    /// FCPXML 1.11.
    /// Format is a `fcpxmld` bundle.
    public static let ver1_11: Self = Self(major: 1, minor: 11)
    
    /// FCPXML 1.12 introduced in Final Cut Pro 10.8.
    /// Format is a `fcpxmld` bundle.
    public static let ver1_12: Self = Self(major: 1, minor: 12)
    
    /// FCPXML 1.13 introduced in Final Cut Pro 11.0.
    /// Format is a `fcpxmld` bundle.
    public static let ver1_13: Self = Self(major: 1, minor: 13)
}

extension FinalCutPro.FCPXML.Version: CaseIterable {
    public static let allCases: [FinalCutPro.FCPXML.Version] = [
        .ver1_0,
        .ver1_1,
        .ver1_2,
        .ver1_3,
        .ver1_4,
        .ver1_5,
        .ver1_6,
        .ver1_7,
        .ver1_8,
        .ver1_9,
        .ver1_10,
        .ver1_11,
        .ver1_12,
        .ver1_13
    ]
    
    /// Returns the latest FCPXML format version supported.
    public static var latest: Self { Self.allCases.last! }
}

extension FinalCutPro.FCPXML.Version: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.major < rhs.major { return true }
        if lhs.major > rhs.major { return false }
        return lhs.minor < rhs.minor
    }
}

#endif
