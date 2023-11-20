//
//  FCPXMLTestCase.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

protocol FCPXMLUtilities { }

extension FCPXMLUtilities {
    static func tc(_ timecodeString: String, _ fr: TimecodeFrameRate) -> Timecode {
        try! Timecode(.string(timecodeString), at: fr, base: .max80SubFrames)
    }
    
    static func tc(frames: Int, _ fr: TimecodeFrameRate) -> Timecode {
        try! Timecode(.frames(frames), at: fr, base: .max80SubFrames)
    }
    
    static func tc(_ rational: Fraction, _ fr: TimecodeFrameRate) -> Timecode {
        try! Timecode(.rational(rational), at: fr, base: .max80SubFrames)
    }
    
    static func tcInterval(frames: Int, _ fr: TimecodeFrameRate) -> TimecodeInterval {
        if frames < 0 {
            return .negative(tc(frames: abs(frames), fr))
        } else {
            return .positive(tc(frames: frames, fr))
        }
    }
    
    static func debugString(for em: FinalCutPro.FCPXML.Marker) -> String {
        let absTC: String
        if let absoluteStart = em.context[.absoluteStart] {
            absTC = absoluteStart.stringValue(format: [.showSubFrames]) + " @ " + absoluteStart.frameRate.stringValue
        } else {
            absTC = "??:??:??:??.?? @ ??"
        }
        
        let name = em.name.quoted
        let note = em.note != nil ? " note:\(em.note!.quoted)" : ""
        let durTC = em.duration?.stringValue(format: [.showSubFrames]) ?? "?"
        
        let parentName = em.context[.parentName]?.quoted ?? "<<missing>>"
        return "\(absTC): \(name)\(note) dur:\(durTC) parent:\(parentName)"
    }
    
    static func debugString(for extractedMarkers: some Collection<FinalCutPro.FCPXML.Marker>) -> String {
        extractedMarkers.map { debugString(for: $0) }.joined(separator: "\n")
    }
    
    static func convert(
        absoluteStartOf marker: FinalCutPro.FCPXML.Marker,
        to newFR: TimecodeFrameRate
    ) throws -> FinalCutPro.FCPXML.Marker {
        guard let absoluteStart = marker.context[.absoluteStart] else { return marker }
        guard absoluteStart.frameRate != newFR else { return marker }
        var copy = marker
        copy.context[.absoluteStart] = try copy.context[.absoluteStart]?.converted(to: newFR)
        return copy
    }
}

class FCPXMLTestCase: XCTestCase, FCPXMLUtilities { }

#endif
