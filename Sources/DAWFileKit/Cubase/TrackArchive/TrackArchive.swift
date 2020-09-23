//
//  Cubase/TrackArchive/TrackArchive.swift
//  DAWFileKit
//
//  Created by Steffan Andrews on 2020-05-11.
//  Copyright © 2020 Steffan Andrews. All rights reserved.
//

import Foundation
import TimecodeKit

// MARK: - Cubase.TrackArchive

extension Cubase {
	
	/// Contains parsed data after reading a Cubase Track Archive XML file.
	public struct TrackArchive {
		
		// MARK: Contents
		
		/// Meta data contained in the main header of the data file.
		public var main = Main()
		
		/// Tempo track
		/// (essentially, a session can contain only one, but there is not a "tempo track" in the XML file;
		/// instead, tempo events are written to the first actual track)
		public var tempoTrack = TempoTrack()
		
		/// Tracks listing.
		public var tracks: [CubaseTrackArchiveTrack]?
		
		// MARK: Constants
		
		/// Static PPQ value used in Track Archive XML files (allegedly, until proven otherwise?)
		/// Changing PPQbase in Cubase preferences has no effect on this value.
		internal static let xmlPPQ = 480
		
		/// Array of file types for use with NSOpenPanel / NSSavePanel
		public static let fileTypes = ["public.xml" ,"xml"]
		
		// MARK: init
		
		public init() { }
		
	}
	
}

extension Cubase.TrackArchive {
	
	/// Contains the global session meta data
	public struct Main {
		
		public var startTimecode: Timecode?		// Start.Time (float, load as double)
		public var startTimeSeconds: Double?		// Start.Time (float, load as double)
		
//		public var startTimeDomain: ?				// Start.Domain.Type & Start.Domain.Period
		public var lengthTimecode: Timecode?		// Length.Time (float, load as double)
//		public var lengthTimeDomain: ?				// Length.Domain.Type & Start.Domain.Period
		
		public var frameRate: Timecode.FrameRate?	// FrameType
		
//		public var timeType: ?						// TimeType
		public var barOffset: Int?					// BarOffset
		
		public var sampleRate: Double?				// SampleRate
		public var bitDepth: Int?					// SampleSize
		
													// SampleFormatSize
													
													// RecordFile
													// RecordFileType ...
													
													// PanLaw
													// VolumeMax
													
													// HmtType
		public var HMTDepth: Int?					// HmtDepth (percentage)
		
	}
	
	internal static var FrameRateTable: [Int : Timecode.FrameRate] = [2 : ._24,
																		3 : ._25,
																		4 : ._29_97,
																		5 : ._30,
																		6 : ._29_97_drop,
																		7 : ._30_drop,
																		12 : ._23_976,
																		13 : ._24_98,
																		14 : ._50,
																		15 : ._59_94,
																		16 : ._60]
		
	public enum TimeType: Int {
		case secondsOrBarsAndBeats = 0 // seconds and bars+beats both show up as 0
		case timecode = 4 // and 13?
		case samples = 10
		case user = 11
	}
	
}

public protocol CubaseTrackArchiveTrack {
	var name: String? { get set }
}

public protocol CubaseTrackArchiveMarker {
	var name: String { get set }
	
	var startTimecode: Timecode { get set }
	var startRealTime: TimeValue? { get set }
}

extension Cubase.TrackArchive {
	
	internal static var TrackTypeTable: [String : CubaseTrackArchiveTrack.Type] =
		["MMarkerTrackEvent" : MarkerTrack.self]
	
	public enum TrackTimeDomain: Int {
		/// Bars & beats timebase - computations are against PPQ base and tempo
		case musical = 0
		/// Time linear timebase (real / absolute time)
		case linear = 1
	}
	
	/// Represents a marker event and its contents
	public struct Marker: CubaseTrackArchiveMarker {
		public var name: String = ""
		
		public var startTimecode: Timecode
		public var startRealTime: TimeValue?
		
		public init(name: String, startTimecode: Timecode, startRealTime: TimeValue? = nil) {
			self.name = name
			self.startTimecode = startTimecode
			self.startRealTime = startRealTime
		}
	}
	
	/// Represents a cycle marker event and its contents
	public struct TempoTrack: CubaseTrackArchiveTrack {
		public var name: String?
		
		public var events: [Event] = []
		
		public struct Event {
			public var startTimeAsPPQ: Double
			public var tempo: Double
			public var type: TempoEventType
			
			public enum TempoEventType {
				case jump
				case ramp
			}
		}
		
	}
	
	/// Represents a cycle marker event and its contents
	public struct CycleMarker: CubaseTrackArchiveMarker {
		public var name: String = ""
		
		public var startTimecode: Timecode
		public var startRealTime: TimeValue?
		
		public var lengthTimecode: Timecode
		public var lengthRealTime: TimeValue?
	}
	
	/// Represents a track and its contents
	public struct MarkerTrack: CubaseTrackArchiveTrack {
		public var name: String?
		
		public var events: [CubaseTrackArchiveMarker] = []
		
		public init() { }
	}
	
	public struct OrphanTrack: CubaseTrackArchiveTrack {
		public var name: String?
		
		public let rawXMLContent: String
	}
	
}
