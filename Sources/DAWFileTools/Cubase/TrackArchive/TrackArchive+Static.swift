//
//  TrackArchive+Static.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import SwiftTimecodeCore

extension Cubase.TrackArchive {
    /// Array of file types for use with `NSOpenPanel` / `NSSavePanel`.
    public static let fileTypes = ["public.xml", "xml"]
    
    /// Static PPQ value used in Track Archive XML files (allegedly, until proven otherwise?)
    /// Changing PPQbase in Cubase preferences has no effect on this value.
    internal static let xmlPPQ = 480
    
    /// Frame rates and their numeric identifier as stored in the XML.
    internal static let frameRateTable: [Int: TimecodeFrameRate] = [
        02: .fps24,
        03: .fps25,
        04: .fps29_97,
        05: .fps30,
        06: .fps29_97d,
        07: .fps30d,
        12: .fps23_976,
        13: .fps24_98,
        14: .fps50,
        15: .fps59_94,
        16: .fps60
    ]
}

#endif
