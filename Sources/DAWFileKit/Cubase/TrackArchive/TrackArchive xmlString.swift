//
//  Cubase/TrackArchive/TrackArchive xmlString.swift
//  DAWFileKit
//
//  Created by Steffan Andrews on 2020-06-07.
//  Copyright © 2020 Steffan Andrews. All rights reserved.
//

import Foundation
import OTCore

extension Cubase.TrackArchive {
	
	// MARK: xmlString
	
	/// Compiles the struct's contents and returns a representation as Cubase XML file contents
	public var xmlString: String? {
		
		resetIDcounter()
		
		let xmlOptions: XMLNode.Options = [.nodePrettyPrint, .nodeCompactEmptyElement]
		
		// xml doc
		
		let xml = XMLDocument(kind: .document, options: xmlOptions)
		xml.version = "1.0"
		xml.characterEncoding = "utf-8"
		xml.setRootElement(XMLElement(name: "root"))
		
		// root
		
		guard let root = xml.rootElement() else { return nil }
		root.name = "tracklist2"
		
		// track list
		
		__addTrackListAndTempoEvents(root)
		
		// setup
		
		__addSetup(root)
		
		// return data
		
		return xml.xmlString(options: xmlOptions)
		
	}
	
}

extension Cubase.TrackArchive {
	
	// MARK: __addSetup
	
	fileprivate func __addSetup(_ root: XMLElement) {
		
		let setupNode = XMLElement(name: "obj",
							   attributes: [("class", "PArrangeSetup"),
											("name", "Setup"),
											("ID", getNewID().string)])
		
		// frame rate
		if let value = Self.FrameRateTable.first(where: { $0.value == main.frameRate })?.key {
			setupNode.addChild(XMLElement(name: "int",
										  attributes: [("name", "FrameType"),
													   ("value", value.string)]))
		}
		
		// start time
		if let stc = main.startTimecode {
			let startNode = XMLElement(name: "member",
									   attributes: [("name","Start")])
			
			let value = stc.realTime.seconds.stringValueHighPrecision
			
			startNode.addChild(XMLElement(name: "float",
										  attributes: [("name", "Time"),
													   ("value", value)]))
			
			startNode.addChild(try! XMLElement(xmlString: #"<member name="Domain"><int name="Type" value="1"/><float name="Period" value="1"/></member>"#))
			
			setupNode.addChild(startNode)
		}
		
		// length
		if let ltc = main.lengthTimecode {
			let startNode = XMLElement(name: "member",
									   attributes: [("name","Length")])
			
			let value = ltc.realTime.seconds.string
			
			startNode.addChild(XMLElement(name: "float",
										  attributes: [("name", "Time"),
													   ("value", value)]))
			
			startNode.addChild(try! XMLElement(xmlString: #"<member name="Domain"><int name="Type" value="1"/><float name="Period" value="1"/></member>"#))
			
			setupNode.addChild(startNode)
		}
		
		
		// TimeType - not implemented yet
		
		// bar offset
		if let value = main.barOffset {
			setupNode.addChild(XMLElement(name: "int",
										  attributes: [("name", "BarOffset"),
													   ("value", value.string)]))
		}
		
		// sample rate
		if let value = main.sampleRate {
			setupNode.addChild(XMLElement(name: "float",
										  attributes: [("name", "SampleRate"),
													   ("value", value.stringValueHighPrecision)]))
		}
		
		// bit depth
		if let value = main.bitDepth {
			setupNode.addChild(XMLElement(name: "int",
										  attributes: [("name", "SampleSize"),
													   ("value", value.string)]))
		}
		
		// SampleFormatSize - not implemented yet
		
		// RecordFile - not implemented yet
		
		// RecordFileType ... - not implemented yet
		
		// PanLaw - not implemented yet
		
		// VolumeMax - not implemented yet
		
		// HmtType - not implemented yet
		
		// HMTDepth
		if let value = main.HMTDepth {
			setupNode.addChild(XMLElement(name: "int",
										  attributes: [("name", "HmtDepth"),
													   ("value", value.string)]))
		}
		
		root.addChild(setupNode)
		
	}
	
}

extension Cubase.TrackArchive {
	
	// MARK: __addTrackListAndTempoEvents
	
	fileprivate func __addTrackListAndTempoEvents(_ root: XMLElement) {
		
		let listNode = XMLElement(name: "list",
							  attributes: [("name", "track"),
										   ("type", "obj")])
		
		#warning("needs coding - add tracks and tempo events")
		
		for track in tracks ?? [] {
			
			let newTrack = XMLElement()
			
			// Flags
			// ***** not sure what this value is for, but Cubase will refuse to open the XML if it's absent
			newTrack.addChild(XMLElement(name: "int",
										 attributes: [("name", "Flags"),
													  ("value", "1")]))
			
			// Start
			newTrack.addChild(XMLElement(name: "float",
										 attributes: [("name", "Start"),
													  ("value", "0")]))
			
			// Length - needed?
			
			// MListNode
			let mlistNode = XMLElement(name: "obj",
									   attributes: [("class", "MListNode"),
													("name","Node"),
													("ID", getNewID().string)])
			newTrack.addChild(mlistNode)
			
			// Track Name
			mlistNode.addChild(XMLElement(name: "string",
										  attributes: [("name", "Name"),
													   ("value", track.name ?? "")]))
			
			// Time domain
			let Domain = XMLElement(name: "member",
									attributes: [("name", "Domain")])
			Domain.addChild(XMLElement(name: "int",
									   attributes: [("name", "Type"),
													("value", "1")]))
			Domain.addChild(XMLElement(name: "float",
									   attributes: [("name", "Period"),
													("value", "1")]))
			mlistNode.addChild(Domain)
			
			// track-specific contents
			
			switch track {
			case let typed as MarkerTrack:
				__addTrackMarker(using: newTrack, track: typed)
				
			default:
				print("Unhandled track type while building XML file for track named:", (track.name ?? "").quoted)
			}
			
			// Track Device
			// ***** not sure what this block is for, but Cubase will refuse to open the XML if it's absent
			let TrackDevice = XMLElement(name: "obj",
										 attributes: [("class", "MTrack"),
													  ("name", "Track Device"),
													  ("ID", getNewID().string)])
			TrackDevice.addChild(XMLElement(name: "int",
											attributes: [("name", "Connection Type"),
														 ("value", "2")]))
			newTrack.addChild(TrackDevice)
			
			listNode.addChild(newTrack)
			
		}
		
		root.addChild(listNode)
		
	}
	
	// MARK: __addTrackMarker
	
	@discardableResult
	fileprivate func __addTrackMarker(using newTrack: XMLElement, track: MarkerTrack) -> XMLElement {
		
		var markerIDCounter = 0
		
		newTrack.name = "obj"
		newTrack.addAttributes([("class", "MMarkerTrackEvent"),
								 ("ID", getNewID().string)])
		
		// MListNode
		let mlistNode = newTrack.children?
			.filter(elementName: "obj")
			.filter(attribute: "class", value: "MListNode")
			.filter(attribute: "name", value: "Node")
			.first as? XMLElement
		
		// MListNode.Events
		let eventsNode = XMLElement(name: "list",
								   attributes: [("name","Events"),
												("type", "obj")])
		
		for event in track.events {
			
			let newNode = XMLElement(name: "obj")
			
			// add length as real time if present, otherwise convert the timecode object to real time
			if event.startRealTime != nil {
				newNode.addChild(XMLElement(name: "float",
											attributes: [("name", "Start"),
														 ("value", event.startRealTime!
															.seconds
															.stringValueHighPrecision)]))
			} else {
				newNode.addChild(XMLElement(name: "float",
											attributes: [("name", "Start"),
														 ("value", event.startTimecode
															.realTime.seconds
															.stringValueHighPrecision)]))
			}
			
			switch event {
			case is Marker: // MMarkerEvent
				newNode.addAttribute(withName: "class", value: "MMarkerEvent")
				
			case let marker as CycleMarker: // MRangeMarkerEvent
				newNode.addAttribute(withName: "class", value: "MRangeMarkerEvent")
				
				// add length as real time if present, otherwise convert the timecode object to real time
				if marker.lengthRealTime != nil {
					newNode.addChild(XMLElement(name: "float",
												attributes: [("name", "Length"),
															 ("value", marker.lengthRealTime!
																.seconds
																.stringValueHighPrecision)]))
				} else {
					newNode.addChild(XMLElement(name: "float",
												attributes: [("name", "Length"),
															 ("value", marker.lengthTimecode
																.realTime.seconds
																.stringValueHighPrecision)]))
				}
				
			default:
				print("Unhandled marker event type while building XML file.")
				continue
			}
			
			newNode.addChild(XMLElement(name: "string", attributes: [("name", "Name"),
																	 ("value", event.name)]))
			
			markerIDCounter += 1
			newNode.addChild(XMLElement(name: "int", attributes: [("name", "ID"),
																  ("value", markerIDCounter.string)]))
			
			newNode.addAttribute(withName: "ID", value: getNewID().string)
			
			eventsNode.addChild(newNode)
			
		}
		
		mlistNode?.addChild(eventsNode)
		
		return newTrack
		
	}
	
}


// MARK: - ID Counter

fileprivate var IDcounter = 0

fileprivate func resetIDcounter() {
	IDcounter = 0
}

fileprivate func getNewID() -> Int {
	
	IDcounter += 1
	
	return IDcounter
	
}
