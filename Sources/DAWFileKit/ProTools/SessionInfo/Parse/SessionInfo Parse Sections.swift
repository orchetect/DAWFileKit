//
//  SessionInfo Parse Sections.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import OTCore
import TimecodeKit

extension ProTools.SessionInfo {
    struct ParsedHeader {
        var debugSectionName: String { "Header" }
        
        private(set) var messages: [ParseMessage] = []
        
        private mutating func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        private(set) var main = Main()
        
        init(lines section: [Substring]) {
            guard section.count >= 8 else { return }
            
            // SESSION NAME
            main.name = String(section[0])
            
            // SAMPLE RATE
            if let val = Double(section[1]) {
                main.sampleRate = val
            } else {
                addParseMessage(.error(
                    "Parse: Header block: Found sample rate info but encountered an error while trying to convert string \"\(section[1])\" to a number."
                ))
            }
            
            // BIT DEPTH
            main.bitDepth = String(section[2])
            
            // SESSION START TIMECODE
            let tempStartTimecode = String(section[3])
            
            #warning(
                "> TODO: (Not all PT frame rates have been tested to be recognized from PT text files but in theory they should work. Need to individually test each frame rate by exporting a text file from Pro Tools at each frame rate to ensure they are correct.)"
            )
            
            // TIMECODE FORMAT
            switch section[4] {
            case "23.976 Frame":      main.frameRate = .fps23_976
            case "24 Frame":          main.frameRate = .fps24
            case "25 Frame":          main.frameRate = .fps25
            case "29.97 Frame":       main.frameRate = .fps29_97
            case "29.97 Drop Frame":  main.frameRate = .fps29_97d
            case "30 Frame":          main.frameRate = .fps30
            case "30 Drop Frame":     main.frameRate = .fps30d
            case "47.952 Frame":      main.frameRate = .fps47_952
            case "48 Frame":          main.frameRate = .fps48
            case "50 Frame":          main.frameRate = .fps50
            case "59.94 Frame":       main.frameRate = .fps59_94
            case "59.94 Drop Frame":  main.frameRate = .fps59_94d
            case "60 Frame":          main.frameRate = .fps60
            case "60 Drop Frame":     main.frameRate = .fps60d
            case "100 Frame":         main.frameRate = .fps100
            case "119.88 Frame":      main.frameRate = .fps119_88
            case "119.88 Drop Frame": main.frameRate = .fps119_88d
            case "120 Frame":         main.frameRate = .fps120
            case "120 Drop Frame":    main.frameRate = .fps120d
            default:
                addParseMessage(.error(
                    "Parse: Header block: Found frame rate but not handled/recognized: \(section[4]). Parsing frame rate property as 'undefined'."
                ))
            }
            
            // # OF AUDIO TRACKS
            if let val = Int(section[5]) {
                main.audioTrackCount = val
            } else {
                addParseMessage(.error(
                    "Parse: Header block: Found # OF AUDIO TRACKS info but encountered an error while trying to convert string \"\(section[5])\" to a number."
                ))
            }
            
            // # OF AUDIO CLIPS
            if let val = Int(section[6]) {
                main.audioClipCount = val
            } else {
                addParseMessage(.error(
                    "Parse: Header block: Found # OF AUDIO CLIPS info but encountered an error while trying to convert string \"\(section[6])\" to a number."
                ))
            }
            
            // # OF AUDIO FILES
            if let val = Int(section[7]) {
                main.audioFileCount = val
            } else {
                addParseMessage(.error(
                    "Parse: Header block: Found # OF AUDIO FILES info but encountered an error while trying to convert string \"\(section[7])\" to a number."
                ))
            }
            
            // process timecode with previously acquired frame rate
            if let fRate = main.frameRate {
                main.startTimecode = try? ProTools.formTimecode(tempStartTimecode, at: fRate)
            }
        }
    }
    
    /// Analyze raw string data to attempt to detect the primary time format in the text file.
    /// Only Tracks and Markers contain time values that can be examined.
    /// If a text file has no clips on tracks and no markers, it is not possible to determine the
    /// time format.
    ///
    /// - Parameters:
    ///   - sections: Raw sections text lines. Will not be mutated, only read from.
    ///   - mainFrameRate: Frame rate derived from the text file.
    static func detectTimeFormat(
        from sections: inout [FileSection: [String]],
        mainFrameRate: TimecodeFrameRate?
    ) -> (format: TimeValueFormat, hasMixedFormats: Bool)? {
        // TODO: this is probably overkill
        // this examines EVERY time value in the entire file and then
        // returns the most common time format
        
        var counts: [TimeValueFormat: Int] = [:]
        
        func updateCounts(fmts: [TimeValueFormat]) {
            fmts.forEach {
                counts[$0] = (counts[$0] ?? 0) + 1
            }
        }
        
        if let lines = sections[.trackList] {
            let tracksLines = ParsedTracks
                .tracksLines(lines: lines)
            let tracksComponents = ParsedTracks
                .tracksComponents(tracksLines: tracksLines.tracksLines)
            let timeFormats = tracksComponents.components.flatMap {
                $0.clips.flatMap {
                    [$0.startTime, $0.endTime, $0.duration].compactMap {
                        try? formTimeValue(heuristic: $0, at: mainFrameRate).format
                    }
                }
            }
            updateCounts(fmts: timeFormats)
        }
        
        if let lines = sections[.markers] {
            let markerComponents = ParsedMarkers
                .markersComponents(lines: lines)
            let timeFormats = markerComponents.components.compactMap {
                try? formTimeValue(heuristic: $0.location, at: mainFrameRate).format
            }
            updateCounts(fmts: timeFormats)
        }
        
        let hasMixedFormats = counts.count > 1
        
        if let mostCommonFormat = counts
            .sorted(by: { $0.value > $1.value })
            .map({ $0.key })
            .first
        {
            return (format: mostCommonFormat, hasMixedFormats: hasMixedFormats)
        }
        
        return nil
    }
}

extension ProTools.SessionInfo {
    struct ParsedFiles {
        var debugSectionName: String { "\(isOnline ? "Online" : "Offline") Files" }
        
        private(set) var messages: [ParseMessage] = []
        
        private mutating func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        let isOnline: Bool
        
        private(set) var files: [File] = []
        
        init(lines section: [String], isOnline: Bool) {
            self.isOnline = isOnline
            
            addParseMessage(.info(
                "Found \(debugSectionName) listing in text file. (\(section.count) lines)"
            ))
            
            guard section.count > 1 else {
                addParseMessage(.info(
                    "Text file contains \(debugSectionName) listing but no files were found."
                ))
                return
            }
            
            if !section[0].contains(caseInsensitive: "Filename") ||
                !section[0].contains(caseInsensitive: "Location")
            {
                addParseMessage(.error(
                    "Error: text file does not appear to contain \(debugSectionName) listing. Columns header is not formatted as expected. Aborting parsing this section."
                ))
                return
            }
            
            let lines = section.suffix(from: 1) // remove header row
            
            guard !lines.isEmpty else {
                addParseMessage(.error(
                    "Error: text file contains \(debugSectionName) listing but no entries were found."
                ))
                return
            }
            
            let estimatedItemCount = lines.count
            
            for line in lines {
                if line.isEmpty { break }
                
                let columnData = line
                    .split(separator: "\t")
                    .map { String($0) } // split into array by tab character
                
                guard let strFilename = columnData[safe: 0]?.trimmed,
                      let strLocation = columnData[safe: 1]?.trimmed
                else {
                    // if these are nil, the text file could be malformed
                    addParseMessage(.error(
                        "One or more \(debugSectionName) item elements were nil. Text file may be malformed."
                    ))
                    break
                }
                
                let newItem = File(
                    filename: strFilename,
                    path: strLocation,
                    online: isOnline
                )
                
                files.append(newItem)
            }
            
            // error check
            
            let actualItemCount = files.count
            
            if estimatedItemCount == actualItemCount {
                addParseMessage(.info(
                    "Successfully parsed \(actualItemCount) \(debugSectionName) from text file."
                ))
            } else {
                addParseMessage(.error(
                    "Actual parsed \(debugSectionName) item count differs from estimated count. Expected \(estimatedItemCount) items but only successfully parsed \(actualItemCount)."
                ))
            }
        }
    }
}

extension ProTools.SessionInfo {
    struct ParsedClips {
        var debugSectionName: String { "\(isOnline ? "Online" : "Offline") Clips" }
        
        private(set) var messages: [ParseMessage] = []
        
        private mutating func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        let isOnline: Bool
        
        private(set) var clips: [Clip] = []
        
        init(lines section: [String], isOnline: Bool) {
            self.isOnline = isOnline
            
            addParseMessage(.info(
                "Found \(debugSectionName) listing in text file. (\(section.count) lines)"
            ))
            
            guard section.count > 1 else {
                addParseMessage(.info(
                    "Text file contains \(debugSectionName) listing but no files were found."
                ))
                return
            }
            
            if !section[0].contains(caseInsensitive: "CLIP NAME") ||
                !section[0].contains(caseInsensitive: "Source File")
            {
                addParseMessage(.error(
                    "Error: text file does not appear to contain \(debugSectionName) listing. Columns header is not formatted as expected. Aborting parsing this section."
                ))
                return
            }
            
            let lines = section.suffix(from: 1) // remove header row
            
            guard !lines.isEmpty else {
                addParseMessage(.error(
                    "Error: text file contains \(debugSectionName) listing but no entries were found."
                ))
                return
            }
            
            let estimatedItemCount = lines.count
            
            for line in lines {
                if line.isEmpty { break }
                
                let columnData = line
                    .split(separator: "\t")
                    .map { String($0) } // split into array by tab character
                
                guard let name = columnData[safe: 0]?.trimmed,
                      let sourceFile = columnData[safe: 1]?.trimmed
                else {
                    // if these are nil, the text file could be malformed
                    addParseMessage(
                        .error("One or more item elements were nil. Text file may be malformed.")
                    )
                    break
                }
                
                let channel = columnData[safe: 2]?.trimmed                    // nil if not found
                
                let newItem = Clip(
                    name: name,
                    sourceFile: sourceFile,
                    channel: channel,
                    online: true
                )
                
                clips.append(newItem)
            }
            
            // error check
            
            let actualItemCount = clips.count
            
            if estimatedItemCount == actualItemCount {
                addParseMessage(.info(
                    "Successfully parsed \(actualItemCount) \(debugSectionName) from text file."
                ))
            } else {
                addParseMessage(.error(
                    "Actual parsed \(debugSectionName) count differs from estimated count. Expected \(estimatedItemCount) but only successfully parsed \(actualItemCount)."
                ))
            }
        }
    }
}

extension ProTools.SessionInfo {
    struct ParsedPlugins {
        let debugSectionName: String = "Plug-Ins"
        
        private(set) var messages: [ParseMessage] = []
        
        private mutating func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        private(set) var plugins: [Plugin] = []
        
        init(lines section: [String]) {
            addParseMessage(.info(
                "Found \(debugSectionName) listing in text file. (\(section.count) lines)"
            ))
            
            guard section.count > 1 else {
                addParseMessage(.info(
                    "Text file contains \(debugSectionName) listing but no files were found."
                ))
                return
            }
            
            if !section[0].contains(caseInsensitive: "MANUFACTURER") ||
                !section[0].contains(caseInsensitive: "PLUG-IN NAME") ||
                !section[0].contains(caseInsensitive: "VERSION") ||
                !section[0].contains(caseInsensitive: "FORMAT") ||
                !section[0].contains(caseInsensitive: "STEMS") ||
                !section[0].contains(caseInsensitive: "NUMBER OF INSTANCES")
            {
                addParseMessage(.error(
                    "Error: text file does not appear to contain \(debugSectionName) listing. Columns header is not formatted as expected. Aborting parsing this section."
                ))
                return
            }
            
            let lines = section.suffix(from: 1) // remove header row
            
            guard !lines.isEmpty else {
                addParseMessage(.error(
                    "Error: text file contains \(debugSectionName) listing but no entries were found."
                ))
                return
            }
            
            let estimatedItemCount = lines.count
            
            for line in lines {
                if line.isEmpty { break }
                
                let columnData = line
                    .split(separator: "\t")
                    .map { String($0) } // split into array by tab character
                
                guard let manufacturer = columnData[safe: 0]?.trimmed,
                      let name = columnData[safe: 1]?.trimmed,
                      let version = columnData[safe: 2]?.trimmed,
                      let format = columnData[safe: 3]?.trimmed,
                      let stems = columnData[safe: 4]?.trimmed,
                      let numberOfInstances = columnData[safe: 5]?.trimmed
                else {
                    // if these are nil, the text file could be malformed
                    addParseMessage(.error(
                        "One or more item elements were nil. Text file may be malformed."
                    ))
                    break
                }
                
                let newItem = Plugin(
                    manufacturer: manufacturer,
                    name: name,
                    version: version,
                    format: format,
                    stems: stems,
                    numberOfInstances: numberOfInstances
                )
                
                plugins.append(newItem)
            }
            
            // error check
            
            let actualItemCount = plugins.count
            
            if estimatedItemCount == actualItemCount {
                addParseMessage(.info(
                    "Successfully parsed \(actualItemCount) \(debugSectionName) from text file."
                ))
            } else {
                addParseMessage(.error(
                    "Actual parsed \(debugSectionName) item count differs from estimated count. Expected \(estimatedItemCount) items but only successfully parsed \(actualItemCount)."
                ))
            }
            
            // fill in empty manufacturer names
            // PT only lists a manufacturer once if there are multiple plugins in use from that
            // manufacturer
            
            var lastFoundManufacturer = ""
            for idx in plugins.indices {
                let itemManufacturer = plugins[idx].manufacturer
                
                if itemManufacturer != "" {
                    lastFoundManufacturer = itemManufacturer
                } else {
                    plugins[idx].manufacturer = lastFoundManufacturer
                }
            }
        }
    }
}

extension ProTools.SessionInfo {
    struct ParsedTracks {
        static let debugSectionName: String = "Tracks"
        
        private(set) var messages: [ParseMessage] = []
        
        private mutating func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        private(set) var tracks: [Track] = []
        
        init(
            lines: [String],
            timeValueFormat: TimeValueFormat,
            mainFrameRate: TimecodeFrameRate?,
            expectedAudioTrackCount: Int?
        ) {
            let tracksLines = Self.tracksLines(lines: lines)
            messages.append(contentsOf: tracksLines.messages)
            
            let tracksComponents = Self.tracksComponents(
                tracksLines: tracksLines.tracksLines
            )
            messages.append(contentsOf: tracksComponents.messages)
            
            let processed = Self.process(
                tracksComponents: tracksComponents.components,
                timeValueFormat: timeValueFormat,
                mainFrameRate: mainFrameRate,
                expectedAudioTrackCount: expectedAudioTrackCount
            )
            messages.append(contentsOf: processed.messages)
            tracks = processed.tracks
        }
        
        struct TrackComponents {
            public var name: String
            public var comments: String
            public var userDelay: String
            public var state: String
            public var plugins: String
            public var clips: [ClipComponents] = []
            
            public init(
                name: String,
                comments: String,
                userDelay: String,
                state: String,
                plugins: String,
                clips: [ClipComponents]
            ) {
                self.name = name
                self.comments = comments
                self.userDelay = userDelay
                self.state = state
                self.plugins = plugins
                self.clips = clips
            }
            
            public init(
                name: Substring,
                comments: Substring,
                userDelay: Substring,
                state: Substring,
                plugins: Substring,
                clips: [ClipComponents]
            ) {
                self.name = String(name)
                self.comments = String(comments)
                self.userDelay = String(userDelay)
                self.state = String(state)
                self.plugins = String(plugins)
                self.clips = clips
            }
            
            struct ClipComponents {
                let channel: String
                let event: String
                let name: String
                let startTime: String
                let endTime: String
                let duration: String
                let state: String
            }
        }
        
        /// Takes raw lines for entire tracks section and breaks into individual tracks.
        static func tracksLines(
            lines: [String]
        ) -> (tracksLines: [[String]], messages: [ParseMessage]) {
            var messages: [ParseMessage] = []
            func addParseMessage(_ msg: ParseMessage) {
                messages.append(msg)
            }
            
            addParseMessage(.info(
                "Found \(debugSectionName) in text file. (\(lines.count) lines)"
            ))
            
            // split into each track
            
            var tracksLines: [[String]] = []
            var hopper: [String] = []
            lines.forEach {
                if $0.hasPrefix(caseInsensitive: "TRACK NAME:") {
                    if !hopper.isEmpty { tracksLines.append(hopper) }
                    hopper.removeAll()
                }
                let lineToAdd = $0.trimmingCharacters(in: .newlines)
                if !$0.isEmpty { hopper.append(lineToAdd) }
            }
            if !hopper.isEmpty { tracksLines.append(hopper) }
            
            return (tracksLines: tracksLines, messages: messages)
        }
        
        /// Takes raw lines of each track and produces abstracted component types containing atomic
        /// string values.
        static func tracksComponents(
            tracksLines: [[String]]
        ) -> (components: [TrackComponents], messages: [ParseMessage]) {
            var messages: [ParseMessage] = []
            let components: [TrackComponents] = tracksLines.compactMap {
                let c = Self.trackComponents(trackLines: $0)
                messages.append(contentsOf: c.messages)
                return c.components
            }
            return (components: components, messages: messages)
        }
        
        /// Takes raw lines of a single track and produces abstracted component types containing
        /// atomic string values.
        static func trackComponents(
            trackLines: [String]
        ) -> (components: TrackComponents?, messages: [ParseMessage]) {
            var messages: [ParseMessage] = []
            func addParseMessage(_ msg: ParseMessage) {
                messages.append(msg)
            }
            
            // parse each track's contents
            
            // basic validation
            
            guard trackLines.count >= 5
            else { // track header has 6 rows, then regions are listed
                addParseMessage(.error(
                    "Error: text file contains a track listing but format is not as expected. Aborting marker parsing."
                ))
                return (nil, messages)
            }
            
            // check params
            
            // NOTE:
            // the PLUG-INS line may legitimately be missing if user opted out of exporting plug-in information from Pro Tools
            
            let paramsRegex =
                #"(?-i)^TRACK NAME:\t(.*)\nCOMMENTS:\t(.*(?:(?:\n*.)*))\nUSER DELAY:\t(.*)\nSTATE:\s(.*)(?:\nPLUG-INS:\s(?:\t{0,1})(.*)){0,1}\n(?:CHANNEL.*STATE)((?:\n.*)*)"#
            
            let getParams = trackLines
                .joined(separator: "\n")
                .regexMatches(captureGroupsFromPattern: paramsRegex)
                .dropFirst()
                .map { $0 ?? "" }
            
            guard getParams.count == 6 else {
                addParseMessage(.error(
                    "Parse: \(debugSectionName) listing block: Text does not contain parameter block, or parameter block is not formatted as expected."
                ))
                
                return (nil, messages)
            }
            
            let trackName = getParams[0]
            let trackComments = getParams[1]
            let trackUserDelay = getParams[2]
            let trackState = getParams[3]
            let trackPlugins = getParams[4]
            
            // clips
            
            let clipList = getParams[5].trimmingCharacters(in: .newlines)
            
            let clips: [TrackComponents.ClipComponents] = clipList
                .components(separatedBy: .newlines)
                .reduce(into: []) { base, clip in
                    let columns = clip
                        .components(separatedBy: "\t")
                        .map { $0.trimmed }
                    
                    // check for empty line
                    if columns.count == 1 { return }
                    
                    guard columns.count == 7 else {
                        let clipDetail = columns.map { $0.quoted }.joined(separator: ", ")
                        addParseMessage(.error(
                            "Parse: \(debugSectionName) listing for track \"\(trackName)\": Did not find expected number of tabular columns. Found \(columns.count) columns but expected 7. This clip cannot be parsed: [\(clipDetail)]"
                        ))
                        
                        return // continue loop
                    }
                    
                    let clip = TrackComponents.ClipComponents(
                        channel: columns[0],
                        event: columns[1],
                        name: columns[2],
                        startTime: columns[3],
                        endTime: columns[4],
                        duration: columns[5],
                        state: columns[6].trimmed
                    )
                    
                    base.append(clip)
                }
                
            // return
            
            let components = TrackComponents(
                name: trackName,
                comments: trackComments,
                userDelay: trackUserDelay,
                state: trackState,
                plugins: trackPlugins,
                clips: clips
            )
            
            return (components: components, messages: messages)
        }
        
        static func process(
            tracksComponents: [TrackComponents],
            timeValueFormat: TimeValueFormat,
            mainFrameRate: TimecodeFrameRate?,
            expectedAudioTrackCount: Int?
        ) -> (tracks: [Track], messages: [ParseMessage]) {
            var messages: [ParseMessage] = []
            func addParseMessage(_ msg: ParseMessage) {
                messages.append(msg)
            }
            
            let tracks: [Track] = tracksComponents.reduce(into: []) { tracks, trackComponents in
                var newTrack = Track()
                
                // populate params
                
                // TRACK NAME
                newTrack.name = trackComponents.name
                
                // COMMENTS (note: may contain new-line characters)
                newTrack.comments = trackComponents.comments
                
                // USER DELAY
                newTrack.userDelay = Int(
                    trackComponents.userDelay.components(separatedBy: " ").first ?? "0"
                ) ?? 0
                
                // STATE (flags)
                let stateFlagsStrings = trackComponents.state.trimmed.components(separatedBy: " ")
                var stateFlags: Set<Track.State> = []
                for str in stateFlagsStrings {
                    switch str {
                    case "Inactive": stateFlags.insert(.inactive)
                    case "Hidden":   stateFlags.insert(.hidden)
                    case "Solo":     stateFlags.insert(.solo)
                    case "SoloSafe": stateFlags.insert(.soloSafe)
                    case "Muted":    stateFlags.insert(.muted)
                    case "": break
                    default:
                        addParseMessage(.error(
                            "Parse: \(debugSectionName) listing for track \"\(newTrack.name)\": Unexpected track STATE value: \"\(str)\". Dev needs to add this to the State enum."
                        ))
                    }
                }
                newTrack.state = stateFlags
                
                // PLUG-INS
                newTrack.plugins = trackComponents.plugins
                    .components(separatedBy: "\t")                // split by tab character
                    .compactMap { $0.trimmed.isEmpty ? nil : $0 } // remove empty strings
                
                // clip list
                newTrack.clips = trackComponents.clips.reduce(into: []) { clips, clipComponents in
                    var newClip = Track.Clip()

                    // CHANNEL
                    newClip.channel = Int(clipComponents.channel) ?? 1

                    // EVENT
                    newClip.event = Int(clipComponents.event) ?? 1

                    // CLIP NAME
                    newClip.name = clipComponents.name

                    // START TIME
                    newClip.startTime = try? ProTools.SessionInfo.formTimeValue(
                        source: clipComponents.startTime,
                        at: mainFrameRate,
                        format: timeValueFormat
                    )

                    // END TIME
                    newClip.endTime = try? ProTools.SessionInfo.formTimeValue(
                        source: clipComponents.endTime,
                        at: mainFrameRate,
                        format: timeValueFormat
                    )

                    // DURATION
                    newClip.duration = try? ProTools.SessionInfo.formTimeValue(
                        source: clipComponents.duration,
                        at: mainFrameRate,
                        format: timeValueFormat
                    )

                    // STATE
                    switch clipComponents.state {
                    case "Unmuted": newClip.state = .unmuted
                    case "Muted": newClip.state = .muted
                    default:
                        newClip.state = .unmuted
                        addParseMessage(.error(
                            "Unexpected track listing clip STATE value: \"\(clipComponents.state)\". Defaulting to \"Unmuted\""
                        ))
                    }

                    clips.append(newClip)
                }
                
                tracks.append(newTrack)
            }
            
            let parsedTrackCount = tracks.count
            if let expectedAudioTrackCount = expectedAudioTrackCount {
                if expectedAudioTrackCount == parsedTrackCount {
                    addParseMessage(.info(
                        "Parsed \(parsedTrackCount) tracks from text file."
                    ))
                } else {
                    addParseMessage(.info(
                        "Parsed track count differs from header track count. Header specifies \(expectedAudioTrackCount) tracks but only \(parsedTrackCount) tracks were parsed from the file. One possible reason is that the session info text file may have been exported using 'Selected Tracks Only'. The text file header will still contain the total number of tracks in the session. But it is also possible this is the result of a parsing error or a malformed file."
                    ))
                }
            } else {
                addParseMessage(.error(
                    "Parsed \(parsedTrackCount) tracks from text file. Expected track count was not readable from the file header however so it is not possible to validate if this is the correct number of tracks."
                ))
            }
            
            return (tracks: tracks, messages: messages)
        }
    }
}

extension ProTools.SessionInfo {
    /// Only 'Marker' memory locations (Absolute or Bar|Beat) get exported to the text file.
    /// 'Selection' memory locations and window-recalls are not listed in the text file.
    struct ParsedMarkers {
        static let debugSectionName: String = "Markers"
        
        private(set) var messages: [ParseMessage] = []
        
        private mutating func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        private(set) var markers: [Marker] = []
        
        init(
            lines: [String],
            timeValueFormat: TimeValueFormat,
            mainFrameRate: TimecodeFrameRate?
        ) {
            let markersComponents = Self.markersComponents(lines: lines)
            messages.append(contentsOf: markersComponents.messages)
            
            let processed = Self.process(
                lineComponents: markersComponents.components,
                timeValueFormat: timeValueFormat,
                mainFrameRate: mainFrameRate
            )
            messages.append(contentsOf: processed.messages)
            markers = processed.markers
        }
        
        static func markersComponents(
            lines section: [String]
        ) -> (components: [MarkerComponents], messages: [ParseMessage]) {
            var messages: [ParseMessage] = []
            func addParseMessage(_ msg: ParseMessage) {
                messages.append(msg)
            }
            
            addParseMessage(.info(
                "Found \(debugSectionName) in text file. (\(section.count) lines)"
            ))
            
            // basic validation
            
            guard section.count > 1 else {
                addParseMessage(.info(
                    "Text file contains \(debugSectionName) listing but no markers were found."
                ))
                return ([], messages)
            }
            
            let sectionVersion: ProTools.SessionInfo.MarkersListingVersion
            
            let legacyHeaderLinePattern = ##"\#[\s]+LOCATION[\s]+TIME REFERENCE[\s]+UNITS[\s]+NAME[\s]+COMMENTS"##
            let pt2023_12_HeaderLinePattern = ##"\#[\s]+LOCATION[\s]+TIME REFERENCE[\s]+UNITS[\s]+NAME[\s]+TRACK NAME[\s]+TRACK TYPE[\s]+COMMENTS"##
            
            if section[0].regexMatches(pattern: legacyHeaderLinePattern).count == 1 {
                sectionVersion = .legacy
            } else if section[0].regexMatches(pattern: pt2023_12_HeaderLinePattern).count == 1 {
                sectionVersion = .pt2023_12
            } else {
                addParseMessage(.error(
                    "Error: text file does not appear to contain \(debugSectionName) listing. Columns header is not formatted as expected. Aborting parsing this section."
                ))
                return ([], messages)
            }
            
            let lines = section.suffix(from: 1) // remove header row
            
            guard !lines.isEmpty else {
                addParseMessage(.info(
                    "Text file contains \(debugSectionName) listing but no entries were found."
                ))
                return ([], messages)
            }
            
            // break markers list into raw text of individual markers so we can further parse then
            
            // due to the fact that newline and tab characters can exist within the NAME and COMMENTS,
            // we have to implement a more nuanced parser to accommodate.
            // - if line starts with #, LOCATION, TIME REFERENCE, UNITS, and NAME with expected contents,
            //   we can reasonably assume it's the start of a marker
            // - if the next line does not match, assume it's part of the currently parsed marker
            
            // this pattern is designed to detect if a line is the start of a marker
            // (works for all session info text file versions)
            let markerPrefixPattern = #"^(\d+)\s+\t([^\t\n]+)\s*\t([^\t\n]+)\s+\t(Samples|Ticks)\s+\t([\s\S]*?)$"#
            
            var rawMarkers: [String] = []
            var currentLineContent: String?
            
            func finalizeRawMarker() {
                if let cl = currentLineContent {
                    rawMarkers.append(cl)
                    currentLineContent = nil
                }
            }
            
            for lineIndex in lines.indices {
                let lineContent = lines[lineIndex]
                let markerPrefixMatches = lineContent.regexMatches(pattern: markerPrefixPattern)
                if markerPrefixMatches.count == 1 {
                    // finalize previous line
                    finalizeRawMarker()
                    // start new marker
                    currentLineContent = lineContent
                } else {
                    // assume line is an additional line belonging to current marker
                    
                    // failsafe to report parse failure
                    if currentLineContent == nil {
                        addParseMessage(.error(
                            "\(debugSectionName) section listing line \(lineIndex) was not parsable. Text file may be malformed."
                        ))
                    }
                    
                    currentLineContent? += "\n\(lineContent)"
                }
            }
            
            // finalize last marker
            finalizeRawMarker()
            
            // parse each marker into its components
            
            let linesComponents: [MarkerComponents] = rawMarkers.reduce(into: []) { base, rawMarker in
                if rawMarker.isEmpty { return }
                
                var rawMarker = rawMarker
                
                // consolidate whitespaces for COMMENTS newlines.
                // as long as the NAME does not contain newlines, Pro Tools will align the start of each
                // newline in the COMMENTS with the COMMENTS column offset by essentially inserting a blank marker
                // formatted in the same tab-delimited layout but using empty spaces.
                let commentNewLinePrefix: String
                switch sectionVersion {
                case .legacy:
                    commentNewLinePrefix = "    \t             \t                  \t           \t                                 \t"
                case .pt2023_12:
                    commentNewLinePrefix = "    \t             \t                  \t           \t                                 \t                                 \t                                 \t"
                }
                
                var commentsSuffix: String? = nil
                if let firstCommentNewLineOffset = rawMarker.firstIndex(of: commentNewLinePrefix) {
                    commentsSuffix = rawMarker[firstCommentNewLineOffset...]
                        .replacingOccurrences(of: commentNewLinePrefix, with: "")
                    rawMarker = String(rawMarker[..<firstCommentNewLineOffset])
                }
                
                let columnData = rawMarker
                    .split(separator: "\t")
                    .map { String($0).trimmed } // split into array by tab character
                
                guard let strNumber = columnData[safe: 0], // always index 0
                      let strLocation = columnData[safe: 1],// always index 1
                      let strTimeReference = columnData[safe: 2],// always index 2
                      let strTimeReferenceBase = columnData[safe: 3] // always index 3
                else {
                    // if these are nil, the text file could be malformed
                    addParseMessage(.error(
                        "One or more \(debugSectionName) item elements were nil. Text file may be malformed."
                    ))
                    return
                }
                
                // marker name
                // always starts at index 4. will be self-contained if no tab characters are within the name.
                let strName: String
                
                // track name
                // (PT 2023.12 and later only)
                var strTrackName: String? = nil
                switch sectionVersion {
                case .legacy: 
                    break
                case .pt2023_12:
                    guard let tn = columnData[safe: 5] else {
                        addParseMessage(.error(
                            "Could not determine marker's track name. Text file may be malformed."
                        ))
                        return
                    }
                    strTrackName = tn
                }
                
                // track type
                // (PT 2023.12 and later only)
                var strTrackType: String? = nil
                switch sectionVersion {
                case .legacy:
                    break
                case .pt2023_12:
                    guard let tt = columnData[safe: 6] else {
                        addParseMessage(.error(
                            "Could not determine marker's track name. Text file may be malformed."
                        ))
                        return
                    }
                    strTrackType = tt
                }
                
                // marker comment
                // legacy: always index 5
                // PT 2023.12 and later: always index 7
                var strComment: String?
                if let commentsSuffix {
                    guard columnData.count >= sectionVersion.columnCount,
                          let lastComponent = columnData.last
                    else {
                        addParseMessage(.error(
                            "One or more \(debugSectionName) item elements failed to parse. Text file may be malformed."
                        ))
                        return
                    }
                    
                    // assume if there are more than one remaining component, there are tab characters in the name
                    
                    let dropLastCount: Int
                    switch sectionVersion {
                    case .legacy: dropLastCount = 1
                    case .pt2023_12: dropLastCount = 3
                    }
                    
                    strName = columnData
                        .dropFirst(4)
                        .dropLast(dropLastCount)
                        .joined(separator: "\t")
                    
                    // add the last component to the partial trailing comments
                    strComment = lastComponent + "\n" + commentsSuffix
                } else {
                    // no newlines in the comments
                    strName = columnData[safe: 4] ?? ""
                    strComment = columnData[safe: sectionVersion.commentColumnIndex...]?
                        .joined(separator: "\t")
                }
                
                if strComment?.isEmpty == true { strComment = nil }
                
                base.append(
                    MarkerComponents(
                        number: strNumber,
                        location: strLocation,
                        timeReference: strTimeReference,
                        timeReferenceFormat: strTimeReferenceBase,
                        name: strName,
                        trackName: strTrackName,
                        trackType: strTrackType,
                        comment: strComment
                    )
                )
            }
            
            // summary
            
            let actualItemCount = linesComponents.count
            
            addParseMessage(.info(
                "Parsed \(actualItemCount) \(debugSectionName) from text file."
            ))
            
            return (linesComponents, messages)
        }
        
        struct MarkerComponents {
            let number: String
            let location: String
            let timeReference: String
            let timeReferenceFormat: String
            let name: String
            let trackName: String?
            let trackType: String?
            let comment: String?
        }
        
        static func process(
            lineComponents: [MarkerComponents],
            timeValueFormat: TimeValueFormat,
            mainFrameRate: TimecodeFrameRate?
        ) -> (markers: [Marker], messages: [ParseMessage]) {
            var messages: [ParseMessage] = []
            func addParseMessage(_ msg: ParseMessage) {
                messages.append(msg)
            }
            
            var markers: [Marker] = []
            
            for line in lineComponents {
                // marker number
                let number: Int
                if let numberInt = line.number.int {
                    number = numberInt
                } else {
                    number = 0
                    addParseMessage(.error(
                        "Marker at \(line.location) had a Memory Location number value that could not be converted to an integer: \(line.number.quoted). Defaulting to 0."
                    ))
                }
                
                // location
                var location: TimeValue?
                do {
                    switch timeValueFormat {
                    case .timecode: // special handling for timecode to offer fallback solutions
                        // file frame rate should reasonably be non-nil but we should still provide
                        // error handling cases for when it may be nil
                        if let mainFrameRate = mainFrameRate {
                            do {
                                let timecodeLoc = try ProTools.SessionInfo.formTimeValue(
                                    timecodeString: line.location,
                                    at: mainFrameRate
                                )
                                location = timecodeLoc
                            } catch {
                                location = nil
                                addParseMessage(.error(
                                    "FYI: Validation for timecode \(line.location.quoted) at text file frame rate of \(mainFrameRate) failed with error: \(error)."
                                ))
                            }
                        } else {
                            // attempt to salvage the data by assuming a default frame rate of 30fps
                            if let timecode = try? Timecode(.string(line.location), at: .fps30, by: .allowingInvalid) {
                                location = .timecode(timecode)
                                addParseMessage(.error(
                                    "FYI: Could not validate timecode \(line.location.quoted) because file frame rate could not be determined."
                                ))
                            } else {
                                location = nil
                                addParseMessage(.error(
                                    "Could not validate timecode \(line.location.quoted) because file frame rate could not be determined and the string is malformed."
                                ))
                            }
                        }
                        
                    default:
                        location = try ProTools.SessionInfo.formTimeValue(
                            source: line.location,
                            at: mainFrameRate,
                            format: timeValueFormat
                        )
                    }
                } catch {
                    addParseMessage(.error(
                        "FYI: Validation for \(timeValueFormat.name) value \(line.location.quoted) failed with error: \(error)."
                    ))
                }
                
                // time reference format
                var timeRefFormat: TimeValueFormat
                switch line.timeReferenceFormat {
                case "Samples":
                    timeRefFormat = .samples
                case "Ticks":
                    timeRefFormat = .barsAndBeats
                default:
                    timeRefFormat = .samples
                    addParseMessage(.error(
                        "Marker at \(line.location) had a Time Reference type that was not recognized: \(line.timeReferenceFormat.quoted). Defaulting to Samples value of 0."
                    ))
                }
                
                // time reference value
                var timeRef: TimeValue
                do {
                    timeRef = try ProTools.SessionInfo.formTimeValue(
                        source: line.timeReference,
                        at: mainFrameRate,
                        format: timeRefFormat
                    )
                } catch {
                    timeRef = .samples(0)
                    addParseMessage(.error(
                        "Marker at \(line.location) had a Time Reference but its format could not be determined: \(error) Value: \(line.timeReference.quoted). Defaulting to Samples value of 0."
                    ))
                }
                
                // check time ref format against the format stated in the file
                if timeRef.format != timeRefFormat {
                    addParseMessage(.error(
                        "Marker at \(line.location) had a Time Reference format of \(line.timeReferenceFormat.quoted) (interpreted as \(timeRef.format.name)) but the time value format does not match. Value: \(line.timeReference.quoted)."
                    ))
                }
                
                // track type
                let trackType: ProTools.SessionInfo.Marker.TrackType
                if let trackTypeString = line.trackType {
                    if let tt = ProTools.SessionInfo.Marker.TrackType(rawValue: trackTypeString) {
                        trackType = tt
                    } else {
                        addParseMessage(.error(
                            "Marker at \(line.location) had an unrecognized Track Type of \(trackTypeString.quoted). Defaulting to Ruler (legacy default)."
                        ))
                        trackType = .ruler
                    }
                } else {
                    // legacy is always marker ruler
                    trackType = .ruler
                }
                
                // add new marker
                let newItem = Marker(
                    number: number,
                    location: location,
                    timeReference: timeRef,
                    name: line.name,
                    trackName: line.trackName,
                    trackType: trackType,
                    comment: line.comment
                )
                markers.append(newItem)
            }
            
            return (markers: markers, messages: messages)
        }
    }
}
