//
//  ProTools SessionText Tests.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class DAWFileKit_ProTools_SessionText_Tests: XCTestCase {
    
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_EmptySession() {
        
        // load file
        
        let filename = "SessionText_EmptySession_23-976fps_DefaultExportOptions_PT2020.3"
        guard let rawData = loadFileContents(forResource: filename,
                                             withExtension: "txt",
                                             subFolder: .ptSessionTextExports)
        else { XCTFail("Could not form URL, possibly could not find file.") ; return }
        
        // parse
        
        let sessionInfo = ProTools.SessionInfo(fromData: rawData)
        
        // main header
        
        XCTAssertEqual(sessionInfo?.main.name,				"SessionText_EmptySession")
        XCTAssertEqual(sessionInfo?.main.sampleRate,		48000.0)
        XCTAssertEqual(sessionInfo?.main.bitDepth,			"24-bit")
        XCTAssertEqual(sessionInfo?.main.startTimecode,	    ProTools.kTimecode(TCC(h: 0, m: 59, s: 55, f: 00), at: ._23_976))
        XCTAssertEqual(sessionInfo?.main.frameRate, 		._23_976)
        XCTAssertEqual(sessionInfo?.main.audioTrackCount, 	0)
        XCTAssertEqual(sessionInfo?.main.audioClipCount, 	0)
        XCTAssertEqual(sessionInfo?.main.audioFileCount, 	0)
        
        // files - online
        
        XCTAssertNil(sessionInfo?.onlineFiles)	// empty
        
        // files - offline
        
        XCTAssertNil(sessionInfo?.offlineFiles)	// empty
        
        // clips - online
        
        XCTAssertNil(sessionInfo?.onlineClips)	// empty
        
        // clips - offline
        
        XCTAssertNil(sessionInfo?.offlineClips)	// empty
        
        // plug-ins
        
        XCTAssertNil(sessionInfo?.plugins)		// empty
        
        // tracks
        
        XCTAssertNil(sessionInfo?.tracks)		// empty
        
        // markers
        
        XCTAssertNil(sessionInfo?.markers)		// empty
        
        // orphan data
        
        XCTAssertNil(sessionInfo?.orphanData)	// empty
        
    }
    
    func testSessionText_SimpleTest() {
        
        // load file
        
        let filename = "SessionText_SimpleTest_23-976fps_DefaultExportOptions_PT2020.3"
        guard let rawData = loadFileContents(forResource: filename,
                                             withExtension: "txt",
                                             subFolder: .ptSessionTextExports)
        else { XCTFail("Could not form URL, possibly could not find file.") ; return }
        
        // parse
        
        let sessionInfo = ProTools.SessionInfo(fromData: rawData)
        
        // main header
        
        XCTAssertEqual(sessionInfo?.main.name,				"SessionText_SimpleTest")
        XCTAssertEqual(sessionInfo?.main.sampleRate,		48000.0)
        XCTAssertEqual(sessionInfo?.main.bitDepth,			"24-bit")
        XCTAssertEqual(sessionInfo?.main.startTimecode,	    ProTools.kTimecode(TCC(h: 0, m: 59, s: 55, f: 00), at: ._23_976))
        XCTAssertEqual(sessionInfo?.main.frameRate, 		._23_976)
        XCTAssertEqual(sessionInfo?.main.audioTrackCount, 	1)
        XCTAssertEqual(sessionInfo?.main.audioClipCount, 	1)
        XCTAssertEqual(sessionInfo?.main.audioFileCount, 	1)
        
        // files - online
        
        XCTAssertEqual(sessionInfo?.onlineFiles?.count, 1)
        
        let file1 = sessionInfo?.onlineFiles?.first
        
        XCTAssertEqual(file1?.filename,		"Audio 1_01.wav")
        XCTAssertEqual(file1?.path,			"Macintosh HD:Users:stef:Desktop:SessionText_SimpleTest:Audio Files:")
        
        // files - offline
        
        XCTAssertNil(sessionInfo?.offlineFiles)	// empty
        
        // clips - online
        
        let onlineClips = sessionInfo?.onlineClips
        
        XCTAssertEqual(onlineClips?.count, 1)
        
        let clip1 = onlineClips?.first
        XCTAssertEqual(clip1?.name,					"Audio 1_01")
        XCTAssertEqual(clip1?.sourceFile,			"Audio 1_01.wav")
        XCTAssertEqual(clip1?.channel,				nil)
        
        // clips - offline
        
        XCTAssertNil(sessionInfo?.offlineClips)	// empty
        
        // plug-ins
        
        XCTAssertNil(sessionInfo?.plugins)		// empty
        
        // tracks
        
        let tracks = sessionInfo?.tracks
        
        XCTAssertEqual(tracks?.count, 1)
        
        let track1 = tracks?.first
        XCTAssertEqual(track1?.name,				"Audio 1")
        XCTAssertEqual(track1?.comments,			"")
        XCTAssertEqual(track1?.userDelay,			0)
        XCTAssertEqual(track1?.state,				[])
        XCTAssertEqual(track1?.plugins,				[])
        
        XCTAssertEqual(track1?.clips.count,			1)
        
        let track1clip1 = track1?.clips.first
        XCTAssertEqual(track1clip1?.channel,		1)
        XCTAssertEqual(track1clip1?.event,			1)
        XCTAssertEqual(track1clip1?.name,			"Audio 1_01")
        XCTAssertEqual(track1clip1?.startTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 00, f: 00), at: ._23_976))
        XCTAssertEqual(track1clip1?.endTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 05, f: 00), at: ._23_976))
        XCTAssertEqual(track1clip1?.duration,	    ProTools.kTimecode(TCC(h: 00, m: 00, s: 05, f: 00), at: ._23_976))
        XCTAssertEqual(track1clip1?.state,			.unmuted)
        
        // markers
        
        XCTAssertNil(sessionInfo?.markers)		// empty
        
        // orphan data
        
        XCTAssertNil(sessionInfo?.orphanData)	// empty
        
    }
    
    func testSessionText_OneOfEverything() {
        
        // load file
        
        let filename = "SessionText_OneOfEverything_23-976fps_DefaultExportOptions_PT2020.3"
        guard let rawData = loadFileContents(forResource: filename,
                                             withExtension: "txt",
                                             subFolder: .ptSessionTextExports)
        else { XCTFail("Could not form URL, possibly could not find file.") ; return }
        
        // parse
        
        let sessionInfo = ProTools.SessionInfo(fromData: rawData)
        
        // main header
        
        XCTAssertEqual(sessionInfo?.main.name,				"SessionText_OneOfEverything")
        XCTAssertEqual(sessionInfo?.main.sampleRate,		48000.0)
        XCTAssertEqual(sessionInfo?.main.bitDepth,			"24-bit")
        XCTAssertEqual(sessionInfo?.main.startTimecode,	    ProTools.kTimecode(TCC(h: 0, m: 59, s: 55, f: 00), at: ._23_976))
        XCTAssertEqual(sessionInfo?.main.frameRate, 		._23_976)
        XCTAssertEqual(sessionInfo?.main.audioTrackCount, 	5)
        XCTAssertEqual(sessionInfo?.main.audioClipCount, 	11)
        XCTAssertEqual(sessionInfo?.main.audioFileCount, 	7)
        
        // files - online
        
        let onlineAudioFilesPath = "Macintosh HD:Users:stef:Dropbox:coding:XCode Projects:Shared:DAWFileKit:_Materials:SessionText_OneOfEverything:Audio Files:"
        
        XCTAssertEqual(sessionInfo?.onlineFiles?.count, 6)
        
        let file1 = sessionInfo?.onlineFiles?[0]
        
        XCTAssertEqual(file1?.filename,		"Unused Clip.wav")
        XCTAssertEqual(file1?.path,			onlineAudioFilesPath)
        
        let file2 = sessionInfo?.onlineFiles?[1]
        
        XCTAssertEqual(file2?.filename,		"Audio 1 Clip1.wav")
        XCTAssertEqual(file2?.path,			onlineAudioFilesPath)
        
        let file3 = sessionInfo?.onlineFiles?[2]
        
        XCTAssertEqual(file3?.filename,		"Audio 2 Clip1.wav")
        XCTAssertEqual(file3?.path,			onlineAudioFilesPath)
        
        let file4 = sessionInfo?.onlineFiles?[3]
        
        XCTAssertEqual(file4?.filename,		"Audio 3 Clip1.wav")
        XCTAssertEqual(file4?.path,			onlineAudioFilesPath)
        
        let file5 = sessionInfo?.onlineFiles?[4]
        
        XCTAssertEqual(file5?.filename,		"Audio 3 Clip2.wav")
        XCTAssertEqual(file5?.path,			onlineAudioFilesPath)
        
        let file6 = sessionInfo?.onlineFiles?[5]
        
        XCTAssertEqual(file6?.filename,		"Audio 4 Clip1.wav")
        XCTAssertEqual(file6?.path,			onlineAudioFilesPath)
        
        // files - offline
        
        XCTAssertEqual(sessionInfo?.offlineFiles?.count, 1)
        
        let file7 = sessionInfo?.offlineFiles?[0]
        
        XCTAssertEqual(file7?.filename,		"Audio 5 Offline Clip1.wav")
        XCTAssertEqual(file7?.path,			"Macintosh HD:Users:stef:Desktop:SessionText_PT2020.3:Audio Files:")
        
        // clips - online
        
        let onlineClips = sessionInfo?.onlineClips
        
        XCTAssertEqual(onlineClips?.count, 9)
        
        XCTAssertEqual(onlineClips?[0].name,		"Audio 1 Clip1")
        XCTAssertEqual(onlineClips?[0].sourceFile,	"Audio 1 Clip1.wav")
        XCTAssertEqual(onlineClips?[0].channel,		nil)
        
        XCTAssertEqual(onlineClips?[1].name,		"Audio 2 Clip1")
        XCTAssertEqual(onlineClips?[1].sourceFile,	"Audio 2 Clip1.wav")
        XCTAssertEqual(onlineClips?[1].channel,		nil)
        
        XCTAssertEqual(onlineClips?[2].name,		"Audio 3 Clip1.L")
        XCTAssertEqual(onlineClips?[2].sourceFile,	"Audio 3 Clip1.wav")
        XCTAssertEqual(onlineClips?[2].channel,		"[1]")
        
        XCTAssertEqual(onlineClips?[3].name,		"Audio 3 Clip1.R")
        XCTAssertEqual(onlineClips?[3].sourceFile,	"Audio 3 Clip1.wav")
        XCTAssertEqual(onlineClips?[3].channel,		"[2]")
        
        XCTAssertEqual(onlineClips?[4].name,		"Audio 3 Clip2.L")
        XCTAssertEqual(onlineClips?[4].sourceFile,	"Audio 3 Clip2.wav")
        XCTAssertEqual(onlineClips?[4].channel,		"[1]")
        
        XCTAssertEqual(onlineClips?[5].name,		"Audio 3 Clip2.R")
        XCTAssertEqual(onlineClips?[5].sourceFile,	"Audio 3 Clip2.wav")
        XCTAssertEqual(onlineClips?[5].channel,		"[2]")
        
        XCTAssertEqual(onlineClips?[6].name,		"Audio 4 Clip1.L")
        XCTAssertEqual(onlineClips?[6].sourceFile,	"Audio 4 Clip1.wav")
        XCTAssertEqual(onlineClips?[6].channel,		"[1]")
        
        XCTAssertEqual(onlineClips?[7].name,		"Audio 4 Clip1.R")
        XCTAssertEqual(onlineClips?[7].sourceFile,	"Audio 4 Clip1.wav")
        XCTAssertEqual(onlineClips?[7].channel,		"[2]")
        
        XCTAssertEqual(onlineClips?[8].name,		"Unused Clip")
        XCTAssertEqual(onlineClips?[8].sourceFile,	"Unused Clip.wav")
        XCTAssertEqual(onlineClips?[8].channel,		nil)
        
        // clips - offline
        
        let offlineClips = sessionInfo?.offlineClips
        
        XCTAssertEqual(offlineClips?.count, 2)
        
        XCTAssertEqual(offlineClips?[0].name,		"Audio 5 Offline Clip1.L")
        XCTAssertEqual(offlineClips?[0].sourceFile,	"Audio 5 Offline Clip1.wav")
        XCTAssertEqual(offlineClips?[0].channel,	"[1]")
        
        XCTAssertEqual(offlineClips?[1].name,		"Audio 5 Offline Clip1.R")
        XCTAssertEqual(offlineClips?[1].sourceFile,	"Audio 5 Offline Clip1.wav")
        XCTAssertEqual(offlineClips?[1].channel,	"[2]")
        
        // plug-ins
        
        let plugins = sessionInfo?.plugins
        
        XCTAssertEqual(plugins?.count, 3)
        
        XCTAssertEqual(plugins?[0].manufacturer,	"Avid")
        XCTAssertEqual(plugins?[0].name,			"EQ3 1-Band")
        XCTAssertEqual(plugins?[0].version,			"20.3.0d163")
        XCTAssertEqual(plugins?[0].format,			"AAX Native")
        XCTAssertEqual(plugins?[0].stems,			"Mono / Mono")
        XCTAssertEqual(plugins?[0].numberOfInstances,"2 active")
        
        XCTAssertEqual(plugins?[1].manufacturer,	"Avid")
        XCTAssertEqual(plugins?[1].name,			"EQ3 7-Band")
        XCTAssertEqual(plugins?[1].version,			"20.3.0d163")
        XCTAssertEqual(plugins?[1].format,			"AAX Native")
        XCTAssertEqual(plugins?[1].stems,			"Mono / Mono")
        XCTAssertEqual(plugins?[1].numberOfInstances,"1 active")
        
        XCTAssertEqual(plugins?[2].manufacturer,	"Avid")
        XCTAssertEqual(plugins?[2].name,			"Trim")
        XCTAssertEqual(plugins?[2].version,			"20.3.0d163")
        XCTAssertEqual(plugins?[2].format,			"AAX Native")
        XCTAssertEqual(plugins?[2].stems,			"Mono / Mono")
        XCTAssertEqual(plugins?[2].numberOfInstances,"1 active")
        
        // tracks
        
        let tracks = sessionInfo?.tracks
        
        XCTAssertEqual(tracks?.count, 5)
        
        let track1 = tracks?[0]
        
        XCTAssertEqual(track1?.name,				"Audio 1")
        XCTAssertEqual(track1?.comments,			"Comments here.")
        XCTAssertEqual(track1?.userDelay,			0)
        XCTAssertEqual(track1?.state,				[])
        XCTAssertEqual(track1?.plugins,				["EQ3 1-Band (mono)"])
        
        XCTAssertEqual(track1?.clips.count,			1)
        
        let track1clip1 = track1?.clips[0]
        XCTAssertEqual(track1clip1?.channel,		1)
        XCTAssertEqual(track1clip1?.event,			1)
        XCTAssertEqual(track1clip1?.name,			"Audio 1 Clip1")
        XCTAssertEqual(track1clip1?.startTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 00, f: 00), at: ._23_976))
        XCTAssertEqual(track1clip1?.endTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 05, f: 00), at: ._23_976))
        XCTAssertEqual(track1clip1?.duration,	    ProTools.kTimecode(TCC(h: 00, m: 00, s: 05, f: 00), at: ._23_976))
        XCTAssertEqual(track1clip1?.state,			.unmuted)
        
        let track2 = tracks?[1]
        
        XCTAssertEqual(track2?.name,				"Audio 2")
        XCTAssertEqual(track2?.comments,			"")
        XCTAssertEqual(track2?.userDelay,			0)
        XCTAssertEqual(track2?.state,				[])
        XCTAssertEqual(track2?.plugins,				["EQ3 7-Band (mono)", "Trim (mono)"])
        
        XCTAssertEqual(track2?.clips.count,			1)
        
        let track2clip1 = track2?.clips[0]
        XCTAssertEqual(track2clip1?.channel,		1)
        XCTAssertEqual(track2clip1?.event,			1)
        XCTAssertEqual(track2clip1?.name,			"Audio 2 Clip1")
        XCTAssertEqual(track2clip1?.startTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 06, f: 15), at: ._23_976))
        XCTAssertEqual(track2clip1?.endTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 10, f: 03), at: ._23_976))
        XCTAssertEqual(track2clip1?.duration,	    ProTools.kTimecode(TCC(h: 00, m: 00, s: 03, f: 12), at: ._23_976))
        XCTAssertEqual(track2clip1?.state,			.unmuted)
        
        let track3 = tracks?[2]
        
        XCTAssertEqual(track3?.name,				"Audio 3 (Stereo)")
        XCTAssertEqual(track3?.comments,			"")
        XCTAssertEqual(track3?.userDelay,			0)
        XCTAssertEqual(track3?.state,				[])
        XCTAssertEqual(track3?.plugins,				[])
        
        XCTAssertEqual(track3?.clips.count,			4)
        
        let track3clip1 = track3?.clips[0]
        XCTAssertEqual(track3clip1?.channel,		1)
        XCTAssertEqual(track3clip1?.event,			1)
        XCTAssertEqual(track3clip1?.name,			"Audio 3 Clip1.L")
        XCTAssertEqual(track3clip1?.startTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 12, f: 18), at: ._23_976))
        XCTAssertEqual(track3clip1?.endTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 17, f: 08), at: ._23_976))
        XCTAssertEqual(track3clip1?.duration,	    ProTools.kTimecode(TCC(h: 00, m: 00, s: 04, f: 14), at: ._23_976))
        XCTAssertEqual(track3clip1?.state,			.unmuted)
        
        let track3clip2 = track3?.clips[1]
        XCTAssertEqual(track3clip2?.channel,		1)
        XCTAssertEqual(track3clip2?.event,			2)
        XCTAssertEqual(track3clip2?.name,			"Audio 3 Clip2.L")
        XCTAssertEqual(track3clip2?.startTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 18, f: 17), at: ._23_976))
        XCTAssertEqual(track3clip2?.endTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 21, f: 19), at: ._23_976))
        XCTAssertEqual(track3clip2?.duration,	    ProTools.kTimecode(TCC(h: 00, m: 00, s: 03, f: 02), at: ._23_976))
        XCTAssertEqual(track3clip2?.state,			.muted)
        
        let track3clip3 = track3?.clips[2]
        XCTAssertEqual(track3clip3?.channel,		2)
        XCTAssertEqual(track3clip3?.event,			1)
        XCTAssertEqual(track3clip3?.name,			"Audio 3 Clip1.R")
        XCTAssertEqual(track3clip3?.startTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 12, f: 18), at: ._23_976))
        XCTAssertEqual(track3clip3?.endTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 17, f: 08), at: ._23_976))
        XCTAssertEqual(track3clip3?.duration,	    ProTools.kTimecode(TCC(h: 00, m: 00, s: 04, f: 14), at: ._23_976))
        XCTAssertEqual(track3clip3?.state,			.unmuted)
        
        let track3clip4 = track3?.clips[3]
        XCTAssertEqual(track3clip4?.channel,		2)
        XCTAssertEqual(track3clip4?.event,			2)
        XCTAssertEqual(track3clip4?.name,			"Audio 3 Clip2.R")
        XCTAssertEqual(track3clip4?.startTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 18, f: 17), at: ._23_976))
        XCTAssertEqual(track3clip4?.endTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 21, f: 19), at: ._23_976))
        XCTAssertEqual(track3clip4?.duration,	    ProTools.kTimecode(TCC(h: 00, m: 00, s: 03, f: 02), at: ._23_976))
        XCTAssertEqual(track3clip4?.state,			.muted)
        
        let track4 = tracks?[3]
        
        _ = track4
        // ***** track 4 contains fades on a clip - may want to abstract that in a certain way in the future
        
        let track5 = tracks?[4]
        
        XCTAssertEqual(track5?.name,				"Audio 5 (Stereo)")
        XCTAssertEqual(track5?.comments,			"")
        XCTAssertEqual(track5?.userDelay,			0)
        XCTAssertEqual(track5?.state,				[.inactive])
        XCTAssertEqual(track5?.plugins,				[])
        
        XCTAssertEqual(track5?.clips.count,			2)
        
        let track5clip1 = track5?.clips[0]
        XCTAssertEqual(track5clip1?.channel,		1)
        XCTAssertEqual(track5clip1?.event,			1)
        XCTAssertEqual(track5clip1?.name,			"Audio 5 Offline Clip1.L")
        XCTAssertEqual(track5clip1?.startTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 05, f: 14), at: ._23_976))
        XCTAssertEqual(track5clip1?.endTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 11, f: 10), at: ._23_976))
        XCTAssertEqual(track5clip1?.duration,	    ProTools.kTimecode(TCC(h: 00, m: 00, s: 05, f: 20), at: ._23_976))
        XCTAssertEqual(track5clip1?.state,			.unmuted)
        
        let track5clip2 = track5?.clips[1]
        XCTAssertEqual(track5clip2?.channel,		2)
        XCTAssertEqual(track5clip2?.event,			1)
        XCTAssertEqual(track5clip2?.name,			"Audio 5 Offline Clip1.R")
        XCTAssertEqual(track5clip2?.startTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 05, f: 14), at: ._23_976))
        XCTAssertEqual(track5clip2?.endTimecode,    ProTools.kTimecode(TCC(h: 01, m: 00, s: 11, f: 10), at: ._23_976))
        XCTAssertEqual(track5clip2?.duration,	    ProTools.kTimecode(TCC(h: 00, m: 00, s: 05, f: 20), at: ._23_976))
        XCTAssertEqual(track5clip2?.state,			.unmuted)
        
        // markers
        
        let markers = sessionInfo?.markers
        
        XCTAssertEqual(markers?.count,				2)
        
        let marker1 = markers?[0]
        XCTAssertEqual(marker1?.number,				1)
        XCTAssertEqual(marker1?.timecode,		    ProTools.kTimecode(TCC(h: 00, m: 59, s: 58, f: 00), at: ._23_976))
        XCTAssertEqual(marker1?.timeReference,		"144144")
        XCTAssertEqual(marker1?.units,				.samples)
        XCTAssertEqual(marker1?.name,				"Marker 1")
        XCTAssertEqual(marker1?.comment,			nil)
        
        let marker2 = markers?[1]
        XCTAssertEqual(marker2?.number,				2)
        XCTAssertEqual(marker2?.timecode,		    ProTools.kTimecode(TCC(h: 01, m: 00, s: 00, f: 00), at: ._23_976))
        XCTAssertEqual(marker2?.timeReference,		"3|3")
        XCTAssertEqual(marker2?.units,				.ticks)
        XCTAssertEqual(marker2?.name,				"Marker 2")
        XCTAssertEqual(marker2?.comment,			"This marker has comments.")
        
        // orphan data
        
        XCTAssertNil(sessionInfo?.orphanData)	// empty
        
    }
    
    func testSessionText_Plugins() {
        
        // load file
        
        let filename = "SessionText_Plugins_23-976fps_DefaultExportOptions_PT2020.3"
        guard let rawData = loadFileContents(forResource: filename,
                                             withExtension: "txt",
                                             subFolder: .ptSessionTextExports)
        else { XCTFail("Could not form URL, possibly could not find file.") ; return }
        
        // parse
        
        let sessionInfo = ProTools.SessionInfo(fromData: rawData)
        
        // plug-ins
        
        let plugins = sessionInfo?.plugins
        
        XCTAssertEqual(plugins?.count, 15)
        
        XCTAssertEqual(plugins?[ 0].manufacturer,	"AIR Music Technology")
        XCTAssertEqual(plugins?[ 0].name,			"AIR Kill EQ")
        
        XCTAssertEqual(plugins?[ 1].manufacturer,	"AIR Music Technology")
        XCTAssertEqual(plugins?[ 1].name,			"AIR Non-Linear Reverb")
        
        XCTAssertEqual(plugins?[ 2].manufacturer,	"Avid")
        XCTAssertEqual(plugins?[ 2].name,			"Dither")
        
        XCTAssertEqual(plugins?[ 3].manufacturer,	"Blue Cat Audio")
        XCTAssertEqual(plugins?[ 3].name,			"BCPatchWorkSynth")
        
        XCTAssertEqual(plugins?[ 4].manufacturer,	"FabFilter")
        XCTAssertEqual(plugins?[ 4].name,			"FabFilter Saturn")
        
        XCTAssertEqual(plugins?[ 5].manufacturer,	"FabFilter")
        XCTAssertEqual(plugins?[ 5].name,			"FabFilter Timeless 2")
        
        XCTAssertEqual(plugins?[ 6].manufacturer,	"Native Instruments")
        XCTAssertEqual(plugins?[ 6].name,			"Kontakt")
        
        XCTAssertEqual(plugins?[ 7].manufacturer,	"Plogue Art et Technologie, Inc")
        XCTAssertEqual(plugins?[ 7].name,			"chipsounds")
        
        XCTAssertEqual(plugins?[ 8].manufacturer,	"Plugin Alliance")
        XCTAssertEqual(plugins?[ 8].name,			"Schoeps Mono Upmix 1to2")
        
        XCTAssertEqual(plugins?[ 9].manufacturer,	"Plugin Alliance")
        XCTAssertEqual(plugins?[ 9].name,			"Unfiltered Audio Byome")
        
        XCTAssertEqual(plugins?[10].manufacturer,	"Plugin Alliance")
        XCTAssertEqual(plugins?[10].name,			"Vertigo VSM-3")
        
        XCTAssertEqual(plugins?[11].manufacturer,	"Plugin Alliance")
        XCTAssertEqual(plugins?[11].name,			"bx_boom")
        
        XCTAssertEqual(plugins?[12].manufacturer,	"Plugin Alliance")
        XCTAssertEqual(plugins?[12].name,			"bx_rooMS")
        
        XCTAssertEqual(plugins?[13].manufacturer,	"accusonus")
        XCTAssertEqual(plugins?[13].name,			"ERA 4 Voice Leveler")
        
        XCTAssertEqual(plugins?[14].manufacturer,	"oeksound")
        XCTAssertEqual(plugins?[14].name,			"soothe2")
        
    }
    
    func testSessionText_FPPFinal() {
        
        // load file
        
        let filename = "SessionText_FPPFinal_23-976fps_DefaultExportOptions_PT2020.3"
        guard let rawData = loadFileContents(forResource: filename,
                                             withExtension: "txt",
                                             subFolder: .ptSessionTextExports)
        else { XCTFail("Could not form URL, possibly could not find file.") ; return }
        
        // parse
        
        let sessionInfo = ProTools.SessionInfo(fromData: rawData)
        
        // main header
        
        XCTAssertEqual(sessionInfo?.main.name,				"FPP Edit 15 A1.4 A2.2 A3.2 A4.2 A5.2 A6.2 A7.2 A8.2 A9.2 Intl.1")
        XCTAssertEqual(sessionInfo?.main.sampleRate,		48000.0)
        XCTAssertEqual(sessionInfo?.main.bitDepth,			"24-bit")
        XCTAssertEqual(sessionInfo?.main.startTimecode,	    ProTools.kTimecode(TCC(h: 0, m: 59, s: 55, f: 00), at: ._23_976))
        XCTAssertEqual(sessionInfo?.main.frameRate, 		._23_976)
        XCTAssertEqual(sessionInfo?.main.audioTrackCount, 	51)
        XCTAssertEqual(sessionInfo?.main.audioClipCount, 	765)
        XCTAssertEqual(sessionInfo?.main.audioFileCount, 	142)
        
        // files - online
        
        XCTAssertEqual(sessionInfo?.onlineFiles?.count, 142)
        
        // files - offline
        
        XCTAssertNil(sessionInfo?.offlineFiles)	// empty
        
        // clips - online
        
        XCTAssertEqual(sessionInfo?.onlineClips?.count, 753)
        
        // clips - offline
        
        XCTAssertNil(sessionInfo?.offlineClips)	// empty
        
        // plug-ins
        
        XCTAssertEqual(sessionInfo?.plugins?.count, 7)
        
        // tracks
        
        XCTAssertEqual(sessionInfo?.tracks?.first?.name,	"DLG")
        XCTAssertEqual(sessionInfo?.tracks?.first?.state,	[.muted])
        XCTAssertEqual(sessionInfo?.tracks?.first?.clips.count, 65)
        
        XCTAssertEqual(sessionInfo?.tracks?.last?.name,		"Master Bounce (Stereo)")
        XCTAssertEqual(sessionInfo?.tracks?.last?.state,	[.hidden, .inactive, .soloSafe])
        XCTAssertEqual(sessionInfo?.tracks?.last?.clips.count, 0)
        
        // markers
        
        XCTAssertEqual(sessionInfo?.markers?.count, 294)
        
        //print(sessionInfo!.markers!
        //	.map { "\($0.number, ifNil: "nil")\t\($0.timecode, ifNil: "nil")\t\($0.name, ifNil: "nil")\t\($0.comment, ifNil: "nil")" }
        //	.joined(separator: "\n")
        //)
        
        // orphan data
        
        XCTAssertNil(sessionInfo?.orphanData)
        
    }
    
    func testSessionText_OrphanData() {
        
        // load file
        
        let filename = "SessionText_UnrecognizedSection_23-976fps_DefaultExportOptions_PT2020.3"
        guard let rawData = loadFileContents(forResource: filename,
                                             withExtension: "txt",
                                             subFolder: .ptSessionTextExports)
        else { XCTFail("Could not form URL, possibly could not find file.") ; return }
        
        // parse
        
        let sessionInfo = ProTools.SessionInfo(fromData: rawData)
        
        // orphan data
        // just test for orphan sections (unrecognized - a hypothetical in case new sections get added to Pro Tools in the future)
        
        XCTAssertEqual(sessionInfo?.orphanData?.count, 1)
        
        XCTAssertEqual(sessionInfo?.orphanData?.first?.heading, "U N R E C O G N I Z E D  S E C T I O N")
        XCTAssertEqual(sessionInfo?.orphanData?.first?.content, [])
        
    }
}
