//
//  SessionInfo Parse Sections.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

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
                
                let columnData = line.split(separator: "\t")
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
                
                let columnData = line.split(separator: "\t")
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
                
                let columnData = line.split(separator: "\t")
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
                addParseMessage(
                    .info("Successfully parsed \(actualItemCount) \(debugSectionName) from text file.")
                )
            } else {
                addParseMessage(.error(
                    "Actual parsed \(debugSectionName) item count differs from estimated count. Expected \(estimatedItemCount) items but only successfully parsed \(actualItemCount)."
                ))
            }
            
            // fill in empty manufacturer names
            // PT only lists a manufacturer once if there are multiple plugins in use from that manufacturer
            
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
        let debugSectionName: String = "Tracks"
        
        private(set) var messages: [ParseMessage] = []
        
        private mutating func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        private(set) var tracks: [Track] = []
        
        init(
            lines section: [String],
            timeValueFormat: TimeValueFormat,
            mainFrameRate: Timecode.FrameRate?,
            expectedAudioTrackCount: Int?
        ) {
            addParseMessage(.info(
                "Found \(debugSectionName) in text file. (\(section.count) lines)"
            ))
            
            // split into each track
            
            var tracksLines: [[String]] = []
            var hopper: [String] = []
            section.forEach {
                if $0.hasPrefix(caseInsensitive: "TRACK NAME:") {
                    if !hopper.isEmpty { tracksLines.append(hopper) }
                    hopper.removeAll()
                }
                let lineToAdd = $0.trimmingCharacters(in: .newlines)
                if !$0.isEmpty { hopper.append(lineToAdd) }
            }
            if !hopper.isEmpty { tracksLines.append(hopper) }
            
            // parse each track's contents
            
            for trackLines in tracksLines {
                var track = Track()
                
                // basic validation
                
                guard trackLines.count >= 6 else { // track header has 6 rows, then regions are listed
                    addParseMessage(.error(
                        "Error: text file contains a track listing but format is not as expected. Aborting marker parsing."
                    ))
                    return
                }
                
                // check params
                
                let paramsRegex =
                #"(?-i)^TRACK NAME:\t(.*)\nCOMMENTS:\t(.*(?:(?:\n*.)*))\nUSER DELAY:\t(.*)\nSTATE:\s(.*)\nPLUG-INS:\s(?:\t{0,1})(.*)\n(?:CHANNEL.*STATE)((?:\n.*)*)"#
                
                let getParams = trackLines
                    .joined(separator: "\n")
                    .regexMatches(captureGroupsFromPattern: paramsRegex)
                    .dropFirst()
                    .map { $0 ?? "<<NIL>>" }
                
                guard getParams.count == 6 else {
                    addParseMessage(.error(
                        "Parse: \(debugSectionName) listing block: Text does not contain parameter block, or parameter block is not formatted as expected."
                    ))
                    
                    continue
                }
                
                // populate params
                
                // TRACK NAME
                track.name = getParams[0]
                
                // COMMENTS (note: may contain new-line characters)
                track.comments = getParams[1]
                
                // USER DELAY
                track.userDelay = Int(getParams[2].components(separatedBy: " ").first ?? "0") ?? 0
                
                // STATE (flags)
                let stateFlagsStrings = getParams[3].trimmed.components(separatedBy: " ")
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
                            "Parse: \(debugSectionName) listing for track \"\(track.name)\": Unexpected track STATE value: \"\(str)\". Dev needs to add this to the State enum."
                        ))
                    }
                }
                track.state = stateFlags
                
                // PLUG-INS
                track.plugins = getParams[4]
                    .components(separatedBy: "\t")                // split by tab character
                    .compactMap { $0.trimmed.isEmpty ? nil : $0 } // remove empty strings
                
                // clip list
                
                let clipList = getParams[5].trimmingCharacters(in: .newlines)
                
                if !clipList.isEmpty { // skip if no clips are listed
                    for clip in clipList.components(separatedBy: .newlines) {
                        var newClip = Track.Clip()
                        
                        let columns = clip.components(separatedBy: "\t").map { $0.trimmed }
                        
                        guard columns.count == 7 else {
                            addParseMessage(.error(
                                "Parse: \(debugSectionName) listing for track \"\(track.name)\": Did not find expected number of tabular columns. Found \(columns.count) columns but expected 7. This clip cannot be parsed: [\(columns.map { $0.quoted }.joined(separator: ", "))]"
                            ))
                            
                            continue
                        }
                        
                        // CHANNEL
                        newClip.channel = Int(columns[0]) ?? 1
                        
                        // EVENT
                        newClip.event = Int(columns[1]) ?? 1
                        
                        // CLIP NAME
                        newClip.name = columns[2]
                        
                        // START TIME
                        newClip.startTime = try? ProTools.SessionInfo.formTimeValue(
                            source: columns[3],
                            at: mainFrameRate,
                            format: timeValueFormat
                        )
                        
                        // END TIME
                        newClip.endTime = try? ProTools.SessionInfo.formTimeValue(
                            source: columns[4],
                            at: mainFrameRate,
                            format: timeValueFormat
                        )
                        
                        // DURATION
                        newClip.duration = try? ProTools.SessionInfo.formTimeValue(
                            source: columns[5],
                            at: mainFrameRate,
                            format: timeValueFormat
                        )
                        
                        // STATE
                        switch columns[6].trimmed {
                        case "Unmuted": newClip.state = .unmuted
                        case "Muted": newClip.state = .muted
                        default:
                            newClip.state = .unmuted
                            addParseMessage(.error(
                                "Unexpected track listing clip STATE value: \"\(columns[6])\". Defaulting to \"Unmuted\""
                            ))
                        }
                        
                        track.clips.append(newClip)
                    }
                }
                
                tracks.append(track)
            }
            
            let parsedTrackCount = tracks.count
            if let expectedAudioTrackCount = expectedAudioTrackCount {
                if expectedAudioTrackCount == parsedTrackCount {
                    addParseMessage(.info(
                        "Parsed \(parsedTrackCount) tracks from text file."
                    ))
                } else {
                    addParseMessage(.error(
                        "Parsed track count differs from expected count. Expected \(expectedAudioTrackCount) items but only successfully parsed \(parsedTrackCount)."
                    ))
                }
            } else {
                addParseMessage(.error(
                    "Parsed \(parsedTrackCount) tracks from text file. Expected track count was not readable from the file header however so it is not possible to validate if this is the correct number of tracks."
                ))
            }
        }
    }
}
