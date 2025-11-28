//
//  TrackArchive Helpers.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions
import SwiftTimecodeCore

// MARK: - Helper methods

extension Cubase.TrackArchive {
    /// Internal use.
    /// Requires main.frameRate to not be nil.
    /// Real Time measured in seconds.
    internal func calculateStartTimecode(ofRealTimeValue: TimeInterval?) -> Timecode? {
        guard let realTimeValue = ofRealTimeValue else { return nil }
        guard let startTimeSeconds = main.startTimeSeconds else { return nil }
        
        let diff = startTimeSeconds + realTimeValue
        
        return calculateLengthTimecode(ofRealTimeValue: diff)
    }
    
    /// Internal use.
    /// Requires main.frameRate to not be nil.
    /// Real Time measured in seconds.
    internal func calculateLengthTimecode(ofRealTimeValue: TimeInterval?) -> Timecode? {
        guard let ofRealTimeValue = ofRealTimeValue else { return nil }
        guard let frameRate = main.frameRate else { return nil }
        
        let tc = try? Cubase.formTimecode(realTime: ofRealTimeValue, at: frameRate)
        
        return tc
    }
    
    /// Internal use.
    /// Requires main.frameRate to not be nil.
    internal func calculateStartTimecode(ofMusicalTimeValue: Double) -> Timecode? {
        let realTimeSeconds = calculateMusicalTimeToRealTime(ofMusicalTimeValue: ofMusicalTimeValue)
        
        return calculateStartTimecode(ofRealTimeValue: realTimeSeconds)
    }
    
    /// Internal use.
    /// Requires main.frameRate to not be nil.
    internal func calculateLengthTimecode(ofMusicalTimeValue: Double) -> Timecode? {
        let realTimeSeconds = calculateMusicalTimeToRealTime(ofMusicalTimeValue: ofMusicalTimeValue)
        
        return calculateLengthTimecode(ofRealTimeValue: realTimeSeconds)
    }
    
    /// Internal use.
    /// Requires `main.frameRate` to not be nil.
    /// Returns a value in Seconds.
    /// Will return `nil` if tempo track has zero events, since at least one originating tempo event
    /// is required to do the calculation.
    internal func calculateMusicalTimeToRealTime(
        ofMusicalTimeValue: Double
    ) -> TimeInterval? {
        enum TempoOperation {
            case jumpToNext
            case rampToNext
            case finalEvent // no tempo events follow
        }
        
        var realTimeAccumulator = 0.0
        
        for index in tempoTrack.events.indices {
            let currentTempoEvent = tempoTrack.events[index]
            
            let tempoCalculationType: TempoOperation
            var isPartialCalculation = false
            var nextTempoEvent: TempoTrack.Event?
            let ppqDuration: Double
            
            let nextIndex = index.advanced(by: 1)
            
            if tempoTrack.events.indices.contains(nextIndex) {
                let _nextTempoEvent = tempoTrack.events[nextIndex]
                nextTempoEvent = _nextTempoEvent
                switch _nextTempoEvent.type {
                case .jump: tempoCalculationType = .jumpToNext
                case .ramp: tempoCalculationType = .rampToNext
                }
                
                if ofMusicalTimeValue < _nextTempoEvent.startTimeAsPPQ {
                    isPartialCalculation = true
                }
                
                // determine PPQ duration to convert to real time
                if isPartialCalculation {
                    ppqDuration = ofMusicalTimeValue - currentTempoEvent.startTimeAsPPQ
                } else {
                    ppqDuration = _nextTempoEvent.startTimeAsPPQ - currentTempoEvent.startTimeAsPPQ
                }
                
            } else {
                // if there are no tempo events to follow this one,
                // it remains static for the remainder of the project timeline
                tempoCalculationType = .finalEvent
                
                // determine PPQ duration to convert to real time
                ppqDuration = ofMusicalTimeValue - currentTempoEvent.startTimeAsPPQ
            }
            
            // perform calculation
            
            switch tempoCalculationType {
            case .jumpToNext,
                 .finalEvent:
                realTimeAccumulator += ppqDuration /
                    (Self.xmlPPQ.double / (60.0 / currentTempoEvent.tempo))
                
            case .rampToNext:
                #warning("> TODO: This calculation is not accurate, it is merely approximate.")
                // Cubase (and other DAWs like Logic Pro X) have mysterious tempo ramp calculation
                // algorithms
                // I was not able to precisely reverse engineer the algo Cubase uses
                // This is as close as I could get to approximate the calculation
                
                let startTempo = currentTempoEvent.tempo
                let endTempo = nextTempoEvent?.tempo ?? 0.0
                
                // get PPQ duration between tempo events, and partial PPQ distance if it's a partial
                // calculation
                let ppqTotalBetweenTempoEvents = (nextTempoEvent?.startTimeAsPPQ ?? 0.0) -
                    currentTempoEvent.startTimeAsPPQ
                let position = ppqDuration / ppqTotalBetweenTempoEvents
                
                // find average tempo at position
                let avg1 = startTempo
                let avg2 = (startTempo + endTempo) / 2
                let avg = avg1 + ((avg2 - avg1) * position)
                
                // this is the theoretical real time value (I think), but Cubase seemingly
                // calculates it differently
                let theoretical = ppqDuration / (Self.xmlPPQ.double / (60.0 / avg))
                
                // now do some janky fakery to try to get closer to Cubase's readings
                let jankfraction = (2.0 / 3.0) / 1000.0
                let jank1 = 1 + (((endTempo - startTempo) * jankfraction * position) * 0.9935)
                
                let deltaref = (endTempo - startTempo) - 60
                let jank2 = 1 + (deltaref * 0.00026757)
                
                realTimeAccumulator += theoretical * jank1 * jank2
            }
            
            if isPartialCalculation {
                // we're done, terminate for-loop iteration
                break
            }
        }
        
        return realTimeAccumulator
        
        // old code - static tempo-based
        
        // #warning("Relies on the session having only one (origin) tempo event. Future improvement
        // here will require calculating real time values for musical timebase events considering
        // the entire tempo track and all tempo events it contains")
        // We're forcing compatibility only with sessions that contain an origin tempo event until
        // such time when I can code the math to work out timecodes from a tempo track containing
        // multiple tempo events
        // The onus is on you to deal with Ramp tempo events, which adds complexity
        
        // let staticTempo = tempoTrack.events.first?.tempo
        //     // provide a standard default
        //     ?? TempoTrack.Event(timeAsPPQ: 0, tempo: 120.0, type: .jump).tempo
        
        // return ofMusicalTimeValue / (Self.xmlPPQ.double / (60.0 / staticTempo))
    }
}

// MARK: - .filter

extension Collection where Element: XMLElement {
    /// DAWFileTools: Filters by the given "name" attribute value.
    internal func filter(whereNameAttributeValue attributeValue: String) -> LazyFilterSequence<Self> {
        filter(whereAttribute: "name") { $0 == attributeValue }
    }
    
    /// DAWFileTools: Filters by the given "class" attribute value.
    internal func filter(whereClassAttributeValue attributeValue: String) -> LazyFilterSequence<Self> {
        filter(whereAttribute: "class") { $0 == attributeValue }
    }
    
    /// DAWFileTools: Returns first having the given "name" attribute value.
    internal func first(whereNameAttributeValue attributeValue: String) -> Element? {
        first(whereAttribute: "name", hasValue: attributeValue)
    }
    
    /// DAWFileTools: Returns first having the given "class" attribute value.
    internal func first(whereClassAttributeValue attributeValue: String) -> Element? {
        first(whereAttribute: "class", hasValue: attributeValue)
    }
}

// MARK: - Debug Helpers

extension Collection where Element: CubaseTrackArchiveMarker {
    /// Formatted/easy to read "pretty" description useful for debugging or logging.
    public var prettyDebugString: String {
        var outputString = ""
        
        for element in self {
            switch element {
            case let marker as Cubase.TrackArchive.Marker:
                outputString += "\(marker.name)".tabbed
                    + marker.startTimecode.stringValue(format: Cubase.timecodeStringFormat)
                    .newLined
                
            case let marker as Cubase.TrackArchive.CycleMarker:
                outputString += "\(marker.name)".tabbed
                    + marker.startTimecode.stringValue(format: Cubase.timecodeStringFormat).tabbed
                    + marker.lengthTimecode.stringValue(format: Cubase.timecodeStringFormat)
                    .newLined
                
            default:
                outputString += "\(element)".newLined
            }
        }
        
        return outputString.trimmingCharacters(in: .newlines)
    }
}

#endif
