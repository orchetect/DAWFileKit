//
//  FCPXMLElementAudioStartAndDuration.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore

/// FCPXML 1.11 DTD:
///
/// Use `audioStart` and `audioDuration` attributes to define J/L cuts (i.e., split edits) on
/// composite A/V clips.
public protocol FCPXMLElementAudioStartAndDuration: FCPXMLElement {
    var audioStart: Fraction? { get nonmutating set }
    var audioDuration: Fraction? { get nonmutating set }
}

extension FCPXMLElementAudioStartAndDuration {
    public var audioStart: Fraction? {
        get { element.fcpAudioStart }
        nonmutating set { element.fcpAudioStart = newValue }
    }
    
    public var audioDuration: Fraction? {
        get { element.fcpAudioDuration }
        nonmutating set { element.fcpAudioDuration = newValue }
    }
}

#endif
