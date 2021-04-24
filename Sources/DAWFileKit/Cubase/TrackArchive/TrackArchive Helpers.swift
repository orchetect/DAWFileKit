//
//  Cubase/TrackArchive/TrackArchive Helpers.swift
//  DAWFileKit
//
//  Created by Steffan Andrews on 2020-05-14.
//  Copyright © 2020 Steffan Andrews. All rights reserved.
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

// MARK: - Helper methods

extension Cubase.TrackArchive {
	
	/// Internal use
	/// Requires main.frameRate to not be nil.
	/// Real Time measured in seconds.
	internal func CalculateStartTimecode(ofRealTimeValue: TimeInterval?) -> Timecode? {
		
		guard ofRealTimeValue != nil else { return nil }
		guard main.startTimeSeconds != nil else { return nil }
		
		let diff = main.startTimeSeconds! + ofRealTimeValue!
		
		return CalculateLengthTimecode(ofRealTimeValue: diff)
		
	}
	
	/// Internal use
	/// Requires main.frameRate to not be nil.
	/// Real Time measured in seconds.
	internal func CalculateLengthTimecode(ofRealTimeValue: TimeInterval?) -> Timecode? {
		
		guard ofRealTimeValue != nil else { return nil }
		guard main.frameRate != nil else { return nil }
		
		var tc = Timecode(at: main.frameRate!)
		let seconds = ofRealTimeValue!
		tc.setTimecode(fromRealTimeValue: seconds)
		
		return tc
		
	}
	
	/// Internal use
	/// Requires main.frameRate to not be nil.
	internal func CalculateStartTimecode(ofMusicalTimeValue: Double) -> Timecode? {
		
		let realTimeSeconds = CalculateMusicalTimeToRealTime(ofMusicalTimeValue: ofMusicalTimeValue)
		
		return CalculateStartTimecode(ofRealTimeValue: realTimeSeconds)
		
	}
	
	/// Internal use
	/// Requires main.frameRate to not be nil.
	internal func CalculateLengthTimecode(ofMusicalTimeValue: Double) -> Timecode? {
		
		let realTimeSeconds = CalculateMusicalTimeToRealTime(ofMusicalTimeValue: ofMusicalTimeValue)
		
		return CalculateLengthTimecode(ofRealTimeValue: realTimeSeconds)
		
	}
	
	/// Internal use
	/// Requires `main.frameRate` to not be nil.
	/// Returns a value in Seconds.
	/// Will return nil if tempo track has zero events, since at least one originating tempo event is required to do the calculation.
	internal func CalculateMusicalTimeToRealTime(ofMusicalTimeValue: Double) -> Double? {
		
		var realTimeAccumulator = 0.0
		
		for index in 0..<tempoTrack.events.endIndex {
			
			let currentTempoEvent = tempoTrack.events[index]
			var nextTempoEvent: TempoTrack.Event? = nil
			
			if index + 1 < tempoTrack.events.endIndex {
				nextTempoEvent = tempoTrack.events[index + 1]
			}
			
			// determine calculation type
			
			var tempoCalculationType: TempoTrack.Event.TempoEventType = .jump
			
			// look ahead: determine the next tempo event type
			switch nextTempoEvent?.type {
			case .jump?, nil: tempoCalculationType = .jump
			case .ramp?: tempoCalculationType = .ramp
			}
			
			// determine if track event is between the two tempo events
			
			var isPartialCalculation = false
			
			if nextTempoEvent == nil { isPartialCalculation = true }
			
			if !isPartialCalculation
				&& ofMusicalTimeValue < nextTempoEvent?.startTimeAsPPQ ?? 0.0
			{
				isPartialCalculation = true
			}
			
			// (nextTempoEvent! is guaranteed safe now)
			
			// determine PPQ duration to convert to real time
			
			var ppqDuration = 0.0
			
			if isPartialCalculation {
				ppqDuration = ofMusicalTimeValue - currentTempoEvent.startTimeAsPPQ
			} else {
				ppqDuration = nextTempoEvent!.startTimeAsPPQ - currentTempoEvent.startTimeAsPPQ
			}
			
			// perform calculation
			
			switch tempoCalculationType {
			case .jump:
				realTimeAccumulator += ppqDuration / (Self.xmlPPQ.double / (60.0 / currentTempoEvent.tempo))
				
			case .ramp:
				#warning("> This calculation is not accurate, it is merely approximate.")
				// Cubase (and other DAWs like Logic Pro X) have mysterious tempo ramp calculation algorithms
				// I was not able to precisely reverse engineer the algo Cubase uses
				// This is as close as I could get to approximate the calculation
				
				let startTempo = currentTempoEvent.tempo
				let endTempo = nextTempoEvent?.tempo ?? 0.0
				
				// get PPQ duration between tempo events, and partial PPQ distance if it's a partial calculation
				let ppqTotalBetweenTempoEvents = (nextTempoEvent?.startTimeAsPPQ ?? 0.0) - currentTempoEvent.startTimeAsPPQ
				let position = ppqDuration / ppqTotalBetweenTempoEvents
				
				// find average tempo at position
				let avg1 = startTempo
				let avg2 = (startTempo + endTempo) / 2
				let avg = avg1 + ((avg2 - avg1) * position)
				
				// this is the theoretical real time value (I think), but Cubase seemingly calculates it differently
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
		
//		#warning("Relies on the session having only one (origin) tempo event. Future improvement here will require calculating real time values for musical timebase events considering the entire tempo track and all tempo events it contains")
		// We're forcing compatibility only with sessions that contain an origin tempo event until such time when I can code the math to work out timecodes from a tempo track containing multiple tempo events
		// The onus is on you to deal with Ramp tempo events, which adds complexity
		
//		let staticTempo = tempoTrack.events.first?.tempo
//			?? TempoTrack.Event(timeAsPPQ: 0, tempo: 120.0, type: .jump).tempo // provide a standard default
		
//		return ofMusicalTimeValue / (Self.xmlPPQ.double / (60.0 / staticTempo))
	}
	
}


// MARK: - .filter

extension Collection where Element : XMLNode {
	
	/// DAWFileKit: Filters by the given "name" attribute
	internal func filter(nameAttribute: String) -> [XMLNode] {
		
		filter {
			$0.asElement?
				.attribute(forName: "name")?
				.stringValue == nameAttribute
		}
		
	}
	
	/// DAWFileKit: Filters by the given "class" attribute
	internal func filter(classAttribute: String) -> [XMLNode] {
		
		filter {
			$0.asElement?
				.attribute(forName: "class")?
				.stringValue == classAttribute
		}
		
	}
	
}

// MARK: - Debug Helpers

extension Collection where Element == CubaseTrackArchiveMarker {
	
	public var cleanDebugString: String {
		
		var outputString = ""
		
		for element in self {
			
			switch element {
			case let marker as Cubase.TrackArchive.Marker:
				outputString += "\(marker.name)".tabbed + marker.startTimecode.stringValue.newLined
				
			case let marker as Cubase.TrackArchive.CycleMarker:
				outputString += "\(marker.name)".tabbed + marker.startTimecode.stringValue.tabbed + marker.lengthTimecode.stringValue.newLined
				
			default:
				outputString += "\(element)".newLined
			}
			
		}
		
		return outputString.trimmingCharacters(in: .newlines)
		
	}
	
}

#endif
