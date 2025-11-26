//
//  MIDIFile BuildError.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
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
