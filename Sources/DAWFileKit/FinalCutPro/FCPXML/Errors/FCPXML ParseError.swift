//
//  FCPXML ParseError.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

extension FinalCutPro.FCPXML {
    /// Final Cut Pro FCPXML file parsing error.
    public enum ParseError: Error {
        case general(String)
    }
}

#endif
