//
//  MIDIFile BuildError.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import MIDIKitSMF

extension MIDIFile {
    /// Cubase track archive XML parsing error.
    public enum BuildError: Error {
        case general(String)
    }
}
