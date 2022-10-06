//
//  SessionInfo Parse.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

extension ProTools.SessionInfo {
    /// Internal: Parse raw file content and return a new `SessionInfo` instance.
    internal static func parse(fileContent: String) throws -> (
        sessionInfo: Self,
        messages: [ParseMessage]
    ) {
        // prep variables
        
        var messages: [ParseMessage] = []
        
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        var remainingTextBlock = fileContent
        
        var info = Self()
        
        // MARK: - Header block
        
        let headerRegex =
            #"(?-i)^SESSION NAME:\t(.*)\nSAMPLE RATE:\t(.*)\nBIT DEPTH:\t(.*)\nSESSION START TIMECODE:\t(.*)\nTIMECODE FORMAT:\t(.*)\n# OF AUDIO TRACKS:\t(.*)\n# OF AUDIO CLIPS:\t(.*)\n# OF AUDIO FILES:\t(.*)\n((?:.*\n)*$)"#
        
        let getHeader = remainingTextBlock
            .regexMatches(captureGroupsFromPattern: headerRegex)
            .dropFirst()
            .map { $0 ?? "<<NIL>>" }
        
        guard getHeader.count == 9 else {
            throw ParseError.general(
                "Parse: Header block: Text does not contain header block, or header block is not formatted as expected."
            )
        }
        
        remainingTextBlock = getHeader[8].trimmingCharacters(in: .newlines)
        
        info.main = try info._parseHeader(section: getHeader, messages: &messages)
        
        // MARK: - Parse into major sections
        
        enum FileSection: Hashable {
            //case header
            
            case onlineFiles
            case offlineFiles
            
            case onlineClips
            case offlineClips
            
            case plugins
            
            case trackList
            
            case markers
            
            case orphan(name: String)
        }
        
        // regex matching lines such as
        // "S E C T I O N  H E A D E R"
        // or
        // "P L U G - I N S  L I S T I N G"
        let sectionNameRegEx = #"^(([A-Z\-])(\s)+){3,}([A-Z\-])$"#
        
        var sections: [FileSection: [String]] = [:]
        
        var lastSectionFound: FileSection?
        
        for block in remainingTextBlock.components(separatedBy: "\n") {
            var lineIsSectionHeader = false
            
            // run a heuristic to test if line appears to be a section heading
            if !block.regexMatches(pattern: sectionNameRegEx).isEmpty {
                //                logger.debug(level: .info, "Section found:", $0)
                lineIsSectionHeader = true
            }
            
            switch lineIsSectionHeader {
            case true:
                switch block {
                case "F I L E S  I N  S E S S I O N",
                     // old file format did not have online/offline
                     "O N L I N E  F I L E S  I N  S E S S I O N":
                    lastSectionFound = .onlineFiles
                case "O F F L I N E  F I L E S  I N  S E S S I O N":
                    lastSectionFound = .offlineFiles
                case "O N L I N E  C L I P S  I N  S E S S I O N":
                    lastSectionFound = .onlineClips
                case "O F F L I N E  C L I P S  I N  S E S S I O N":
                    lastSectionFound = .offlineClips
                case "P L U G - I N S  L I S T I N G":
                    lastSectionFound = .plugins
                case "T R A C K  L I S T I N G":
                    lastSectionFound = .trackList
                case "M A R K E R S  L I S T I N G":
                    lastSectionFound = .markers
                default:
                    lastSectionFound = .orphan(name: block) // unrecognized
                }
                
                if let lastSectionFound = lastSectionFound {
                    if sections[lastSectionFound] == nil { sections[lastSectionFound] = [] }
                }
                
            case false:
                if let lastSectionFound = lastSectionFound {
                    sections[lastSectionFound]?.append(block)
                }
            }
        }
        
        // trim empty lines from end of each section
        
        for section in sections {
            var lines = section.value
            
            if lines.isEmpty { continue }
            
            var idx = lines.count - 1
            var done = false
            repeat {
                if lines[idx].trimmed.isEmpty {
                    lines.remove(at: idx)
                    idx -= 1
                } else {
                    done = true
                }
                if idx < 0 { done = true }
            } while !done
            
            sections[section.key] = lines
        }
        
        // MARK: - Location Time Format Heuristic
        
        // employ a heuristic to determine the main time format
        // selected while exporting the text file from Pro tools
        
        
        let timeValueFormat: TimeValueFormat = .timecode
        
        // MARK: - Run section parsers
        
        for (section, lines) in sections {
            switch section {
            case .onlineFiles:
                let parsed = ParsedFiles(lines: lines, isOnline: true)
                info.onlineFiles = parsed.files
                messages.append(contentsOf: parsed.messages)
                
            case .offlineFiles:
                let parsed = ParsedFiles(lines: lines, isOnline: false)
                info.offlineFiles = parsed.files
                messages.append(contentsOf: parsed.messages)
                
            case .onlineClips:
                let parsed = ParsedClips(lines: lines, isOnline: true)
                info.onlineClips = parsed.clips
                messages.append(contentsOf: parsed.messages)
                
            case .offlineClips:
                let parsed = ParsedClips(lines: lines, isOnline: false)
                info.offlineClips = parsed.clips
                messages.append(contentsOf: parsed.messages)
                
            case .plugins:
                let parsed = ParsedPlugins(lines: lines)
                info.plugins = parsed.plugins
                messages.append(contentsOf: parsed.messages)
                
            case .trackList:
                let parsed = ParsedTracks(
                    lines: lines,
                    timeValueFormat: timeValueFormat,
                    mainFrameRate: info.main.frameRate,
                    expectedAudioTrackCount: info.main.audioTrackCount
                )
                info.tracks = parsed.tracks
                messages.append(contentsOf: parsed.messages)
                
            case .markers:
                let parsed = ParsedMarkers(
                    lines: lines,
                    timeValueFormat: timeValueFormat,
                    mainFrameRate: info.main.frameRate
                )
                info.markers = parsed.markers
                messages.append(contentsOf: parsed.messages)
                
            case let .orphan(name: name):
                if info.orphanData == nil { info.orphanData = [] }
                info.orphanData?.append(OrphanData(heading: name, content: lines))
            }
        }
        
        return (sessionInfo: info, messages: messages)
    }
}

extension ProTools.SessionInfo {
    // MARK: - Header
    
    fileprivate func _parseHeader(
        section: [String],
        messages: inout [ParseMessage]
    ) throws -> Main {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        var main = Main()
        
        // SESSION NAME
        main.name = section[0]
        
        // SAMPLE RATE
        if let val = Double(section[1]) {
            main.sampleRate = val
        } else {
            addParseMessage(.error(
                "Parse: Header block: Found sample rate info but encountered an error while trying to convert string \"\(section[1])\" to a number."
            ))
        }
        
        // BIT DEPTH
        main.bitDepth = section[2]
        
        // SESSION START TIMECODE
        let tempStartTimecode: String = section[3]
        
        #warning(
            "> TODO: (Not all PT frame rates have been tested to be recognized from PT text files but in theory they should work. Need to individually test each frame rate by exporting a text file from Pro Tools at each frame rate to ensure they are correct.)"
        )
        
        // TIMECODE FORMAT
        switch section[4] {
        case "23.976 Frame":      main.frameRate = ._23_976
        case "24 Frame":          main.frameRate = ._24
        case "25 Frame":          main.frameRate = ._25
        case "29.97 Frame":       main.frameRate = ._29_97
        case "29.97 Drop Frame":  main.frameRate = ._29_97_drop
        case "30 Frame":          main.frameRate = ._30
        case "30 Drop Frame":     main.frameRate = ._30_drop
        case "47.952 Frame":      main.frameRate = ._47_952
        case "48 Frame":          main.frameRate = ._48
        case "50 Frame":          main.frameRate = ._50
        case "59.94 Frame":       main.frameRate = ._59_94
        case "59.94 Drop Frame":  main.frameRate = ._59_94_drop
        case "60 Frame":          main.frameRate = ._60
        case "60 Drop Frame":     main.frameRate = ._60_drop
        case "100 Frame":         main.frameRate = ._100
        case "119.88 Frame":      main.frameRate = ._119_88
        case "119.88 Drop Frame": main.frameRate = ._119_88_drop
        case "120 Frame":         main.frameRate = ._120
        case "120 Drop Frame":    main.frameRate = ._120_drop
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
        
        return main
    }
    
    // MARK: - Markers block
    
    // only 'Marker' memory locations (Absolute or Bar|Beat) get exported to the text file
    // 'Selection' memory locations and window-recalls are not listed in the text file
    
    fileprivate mutating func _parseMarkers(
        section: [String],
        timeLocationFormat: TimeValueFormat,
        messages: inout [ParseMessage]
    ) {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        let debugSectionName = "Markers"
//        addParseMessage(.info(
//            "Found \(debugSectionName) in text file. (\(section.count) lines)"
//        ))
//
//        // basic validation
//
//        guard section.count > 1 else {
//            addParseMessage(.info(
//                "Text file contains \(debugSectionName) listing but no markers were found."
//            ))
//            return
//        }
//
//        if !section[0].contains(caseInsensitive: "LOCATION") ||
//            !section[0].contains(caseInsensitive: "TIME REFERENCE") ||
//            !section[0].contains(caseInsensitive: "UNITS") ||
//            !section[0].contains(caseInsensitive: "NAME") ||
//            !section[0].contains(caseInsensitive: "COMMENTS")
//        {
//            addParseMessage(.error(
//                "Error: text file does not appear to contain \(debugSectionName) listing. Columns header is not formatted as expected. Aborting parsing this section."
//            ))
//            return
//        }
//
//        let lines = section.suffix(from: 1) // remove header row
//
//        guard !lines.isEmpty else {
//            addParseMessage(.error(
//                "Error: text file contains \(debugSectionName) listing but no entries were found."
//            ))
//            return
//        }
//
//        let estimatedItemCount = lines.count
//
//        // init array so we can append to it
//        markers = []
//
//        for line in lines {
//            if line.isEmpty { break }
//
//            let columnData = line.split(separator: "\t")
//                .map { String($0).trimmed } // split into array by tab character
//
//            guard let strNumber = columnData[safe: 0],
//                  let strLocation = columnData[safe: 1],
//                  let strTimeReference = columnData[safe: 2],
//                  let strTimeReferenceBase = columnData[safe: 3],
//                  let strName = columnData[safe: 4]
//            else {
//                // if these are nil, the text file could be malformed
//                addParseMessage(.error(
//                    "One or more \(debugSectionName) item elements were nil. Text file may be malformed."
//                ))
//                break
//            }
//
//            // marker number
//            let number: Int
//            if let numberInt = strNumber.int {
//                number = numberInt
//            } else {
//                number = 0
//                addParseMessage(.error(
//                    "Marker at \(strLocation) had a Memory Location number value that could not be converted to an integer: \(strNumber.quoted). Defaulting to 0."
//                ))
//            }
//
//            // location
//            var location: TimeValue?
//            switch timeLocationFormat {
//            case .timecode:
//                // file frame rate should reasonably be non-nil but we should still provide
//                // error handling cases for when it may be nil
//                if let mainFrameRate = main.frameRate {
//                    do {
//                        let timecodeLoc = try Self.formTimeValue(
//                            timecodeString: strLocation,
//                            at: mainFrameRate
//                        )
//                        location = timecodeLoc
//                    } catch {
//                        location = nil
//                        addParseMessage(.error(
//                            "FYI: Validation for timecode \(strLocation.quoted) at text file frame rate of \(mainFrameRate) failed with error: \(error)."
//                        ))
//                    }
//                } else {
//                    // attempt to salvage the data by assuming a default frame rate of 30fps
//                    if let timecode = try? Timecode(rawValues: strLocation, at: ._30) {
//                        location = .timecode(timecode)
//                        addParseMessage(.error(
//                            "FYI: Could not validate timecode \(strLocation.quoted) because file frame rate could not be determined."
//                        ))
//                    } else {
//                        location = nil
//                        addParseMessage(.error(
//                            "Could not validate timecode \(strLocation.quoted) because file frame rate could not be determined and the string is malformed."
//                        ))
//                    }
//
//                }
//
//            case .minSecs:
//                do {
//                    let minSecsLoc = try Self.formTimeValue(minSecsString: strLocation)
//                    location = minSecsLoc
//                } catch {
//                    location = nil
//                    addParseMessage(.error(
//                        "FYI: Validation for Min:Secs value \(strLocation.quoted) failed with error: \(error)."
//                    ))
//                }
//
//            case .samples:
//                do {
//                    let samplesLoc = try Self.formTimeValue(samplesString: strLocation)
//                    location = samplesLoc
//                } catch {
//                    location = nil
//                    addParseMessage(.error(
//                        "FYI: Validation for Samples value \(strLocation.quoted) failed with error: \(error)."
//                    ))
//                }
//
//            case .barsAndBeats:
//                do {
//                    let barsAndBeatsLoc = try Self.formTimeValue(barsAndBeatsString: strLocation)
//                    location = barsAndBeatsLoc
//                } catch {
//                    location = nil
//                    addParseMessage(.error(
//                        "FYI: Validation for Bars|Beats value \(strLocation.quoted) failed with error: \(error)."
//                    ))
//                }
//
//            case .feetAndFrames:
//                do {
//                    let feetAndFramesLoc = try Self.formTimeValue(feetAndFramesString: strLocation)
//                    location = feetAndFramesLoc
//                } catch {
//                    location = nil
//                    addParseMessage(.error(
//                        "FYI: Validation for Feet+Frames value \(strLocation.quoted) failed with error: \(error)."
//                    ))
//                }
//            }
//
//            // time reference
//            var timeRef: TimeValue
//            switch strTimeReferenceBase {
//            case "Samples":
//                do {
//                    let samplesRef = try Self.formTimeValue(samplesString: strTimeReference)
//                    timeRef = samplesRef
//                } catch {
//                    timeRef = .samples(0)
//                    addParseMessage(.error(
//                        "Marker at \(strLocation) had a Time Reference type of Samples but an error occurred: \(error) Value: \(strTimeReference.quoted). Defaulting to Samples value of 0."
//                    ))
//                }
//
//            case "Ticks":
//                do {
//                    let barsAndBeatsRef = try Self.formTimeValue(barsAndBeatsString: strTimeReference)
//                    timeRef = barsAndBeatsRef
//                } catch {
//                    timeRef = .samples(0)
//                    addParseMessage(.error(
//                        "Marker at \(strLocation) had a Time Reference type of Ticks but an error occurred: \(error) Value: \(strTimeReference.quoted). Defaulting to 0|0."
//                    ))
//                }
//
//            default:
//                timeRef = .samples(0)
//                addParseMessage(.error(
//                    "Marker at \(strLocation) had a Time Reference type that was not recognized: \(strTimeReferenceBase.quoted). Defaulting to Samples value of 0."
//                ))
//            }
//
//            // marker comment
//            let strComment = columnData[safe: 5]
//
//            // add new marker
//            let newItem = Marker(
//                number: number,
//                location: location,
//                timeReference: timeRef,
//                name: strName,
//                comment: strComment
//            )
//            markers?.append(newItem)
//        }
//
//        // error check
//
//        let actualItemCount = markers?.count ?? 0
//
//        if estimatedItemCount == actualItemCount {
//            addParseMessage(.info(
//                "Successfully parsed \(actualItemCount) \(debugSectionName) from text file."
//            ))
//        } else {
//            addParseMessage(.error(
//                "Actual parsed \(debugSectionName) count differs from estimated count. Expected \(estimatedItemCount) but only successfully parsed \(actualItemCount)."
//            ))
//        }
    }
}

// MARK: - Time Format Heuristic

extension ProTools.SessionInfo {
    /// Analyze the text file content using a heuristic to determine the primary time format being used.
    ///
    /// Pro Tools does not explicitly include the file's time format type in the file header so we need
    /// to detect it manually by analyzing the file's content.
    ///
    /// - Parameters:
    ///   - string: Full text file contents. The contents will not be mutated, only read.
    /// - Returns: Detected primary time value format.
    internal static func timeValueFormats(
        fileContent: inout String
    ) throws -> [TimeValueFormat: Int] {
        #warning("> finish this")
        fatalError("Not yet implemented.")
    }
}
