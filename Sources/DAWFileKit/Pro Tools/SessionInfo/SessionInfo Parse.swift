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
    internal static func parse(string: String) throws -> (
        sessionInfo: Self,
        messages: [ParseMessage]
    ) {
        // prep variables
        
        var messages: [ParseMessage] = []
        
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        var remainingTextBlock = string
        
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
        
        // SESSION NAME
        info.main.name = getHeader[0]
        
        // SAMPLE RATE
        if let val = Double(getHeader[1]) {
            info.main.sampleRate = val
        } else {
            addParseMessage(
                .error(
                    "Parse: Header block: Found sample rate info but encountered an error while trying to convert string \"\(getHeader[1])\" to a number."
                )
            )
        }
        
        // BIT DEPTH
        info.main.bitDepth = getHeader[2]
        
        // SESSION START TIMECODE
        let tempStartTimecode: String = getHeader[3]
        
        #warning(
            "> TODO: (Not all PT frame rates have been tested to be recognized from PT text files but in theory they should work. Need to individually test each frame rate by exporting a text file from Pro Tools at each frame rate to ensure they are correct.)"
        )
        
        // TIMECODE FORMAT
        switch getHeader[4] {
        case "23.976 Frame":      info.main.frameRate = ._23_976
        case "24 Frame":          info.main.frameRate = ._24
        case "25 Frame":          info.main.frameRate = ._25
        case "29.97 Frame":       info.main.frameRate = ._29_97
        case "29.97 Drop Frame":  info.main.frameRate = ._29_97_drop
        case "30 Frame":          info.main.frameRate = ._30
        case "30 Drop Frame":     info.main.frameRate = ._30_drop
        case "47.952 Frame":      info.main.frameRate = ._47_952
        case "48 Frame":          info.main.frameRate = ._48
        case "50 Frame":          info.main.frameRate = ._50
        case "59.94 Frame":       info.main.frameRate = ._59_94
        case "59.94 Drop Frame":  info.main.frameRate = ._59_94_drop
        case "60 Frame":          info.main.frameRate = ._60
        case "60 Drop Frame":     info.main.frameRate = ._60_drop
        case "100 Frame":         info.main.frameRate = ._100
        case "119.88 Frame":      info.main.frameRate = ._119_88
        case "119.88 Drop Frame": info.main.frameRate = ._119_88_drop
        case "120 Frame":         info.main.frameRate = ._120
        case "120 Drop Frame":    info.main.frameRate = ._120_drop
        default:
            addParseMessage(
                .error(
                    "Parse: Header block: Found frame rate but not handled/recognized: \(getHeader[4]). Parsing frame rate property as 'undefined'."
                )
            )
        }
        
        // # OF AUDIO TRACKS
        if let val = Int(getHeader[5]) {
            info.main.audioTrackCount = val
        } else {
            addParseMessage(
                .error(
                    "Parse: Header block: Found # OF AUDIO TRACKS info but encountered an error while trying to convert string \"\(getHeader[5])\" to a number."
                )
            )
        }
        
        // # OF AUDIO CLIPS
        if let val = Int(getHeader[6]) {
            info.main.audioClipCount = val
        } else {
            addParseMessage(
                .error(
                    "Parse: Header block: Found # OF AUDIO CLIPS info but encountered an error while trying to convert string \"\(getHeader[6])\" to a number."
                )
            )
        }
        
        // # OF AUDIO FILES
        if let val = Int(getHeader[7]) {
            info.main.audioFileCount = val
        } else {
            addParseMessage(
                .error(
                    "Parse: Header block: Found # OF AUDIO FILES info but encountered an error while trying to convert string \"\(getHeader[7])\" to a number."
                )
            )
        }
        
        // process timecode with previously acquired frame rate
        if let fRate = info.main.frameRate {
            info.main.startTimecode = ProTools.kTimecode(tempStartTimecode, at: fRate)
        }
        
        // MARK: - Parse into major sections
        
        enum FileSection: Hashable {
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
        
        // MARK: - Run section parsers
        
        if let section = sections[.onlineFiles] {
            info._parseOnlineFiles(
                section: section,
                messages: &messages
            )
        }
        
        if let section = sections[.offlineFiles] {
            info._parseOfflineFiles(
                section: section,
                messages: &messages
            )
        }
        
        if let section = sections[.onlineClips] {
            info._parseOnlineClips(
                section: section,
                messages: &messages
            )
        }
        
        if let section = sections[.offlineClips] {
            info._parseOfflineClips(
                section: section,
                messages: &messages
            )
        }
        
        if let section = sections[.plugins] {
            info._parsePlugins(
                section: section,
                messages: &messages
            )
        }
        
        if let section = sections[.trackList] {
            info._parseTracks(
                section: section,
                expectedAudioTrackCount: info.main.audioTrackCount,
                messages: &messages
            )
        }
        
        if let section = sections[.markers] {
            info._parseMarkers(
                section: section,
                messages: &messages
            )
        }
        
        // MARK: - Orphan data
        
        for item in sections {
            switch item.key {
            case let .orphan(name):
                if info.orphanData == nil { info.orphanData = [] }
                
                info.orphanData?.append((heading: name, content: item.value))
                
            default:
                break
            }
        }
        
        // return
        
        return (sessionInfo: info, messages: messages)
    }
}

extension ProTools.SessionInfo {
    // MARK: - File Listing block (online)
    
    fileprivate mutating func _parseOnlineFiles(
        section: [String],
        messages: inout [ParseMessage]
    ) {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        let debugSectionName = "Online Files"
        addParseMessage(
            .info("Found \(debugSectionName) listing in text file. (\(section.count) lines)")
        )
        
        guard section.count > 1 else {
            addParseMessage(
                .info("Text file contains \(debugSectionName) listing but no files were found.")
            )
            return
        }
        
        if !section[0].contains(caseInsensitive: "Filename") ||
            !section[0].contains(caseInsensitive: "Location")
        {
            addParseMessage(
                .error(
                    "Error: text file does not appear to contain \(debugSectionName) listing. Columns header is not formatted as expected. Aborting parsing this section."
                )
            )
            return
        }
        
        let lines = section.suffix(from: 1) // remove header row
        
        guard !lines.isEmpty else {
            addParseMessage(
                .error(
                    "Error: text file contains \(debugSectionName) listing but no entries were found."
                )
            )
            return
        }
        
        let estimatedItemCount = lines.count
        
        // init array so we can append to it
        onlineFiles = []
        
        for line in lines {
            if line.isEmpty { break }
            
            let columnData = line.split(separator: "\t")
                .map { String($0) } // split into array by tab character
            
            guard let strFilename = columnData[safe: 0]?.trimmed,
                  let strLocation = columnData[safe: 1]?.trimmed
            else {
                // if these are nil, the text file could be malformed
                addParseMessage(
                    .error(
                        "One or more \(debugSectionName) item elements were nil. Text file may be malformed."
                    )
                )
                break
            }
            
            let newItem = File(
                filename: strFilename,
                path: strLocation,
                online: true
            )
            
            onlineFiles?.append(newItem)
        }
        
        // error check
        
        let actualItemCount = onlineFiles?.count ?? 0
        
        if estimatedItemCount == actualItemCount {
            addParseMessage(
                .info("Successfully parsed \(actualItemCount) \(debugSectionName) from text file.")
            )
        } else {
            addParseMessage(
                .error(
                    "Actual parsed \(debugSectionName) item count differs from estimated count. Expected \(estimatedItemCount) items but only successfully parsed \(actualItemCount)."
                )
            )
        }
    }
    
    // MARK: - File Listing block (offline)
    
    fileprivate mutating func _parseOfflineFiles(
        section: [String],
        messages: inout [ParseMessage]
    ) {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        let debugSectionName = "Offline Files"
        // addParseMessage("Found \(debugSectionName) listing in text file. (\(section.count) lines)")
        
        guard section.count > 1 else {
            addParseMessage(
                .info("Text file contains \(debugSectionName) listing but no files were found.")
            )
            return
        }
        
        if !section[0].contains(caseInsensitive: "Filename") ||
            !section[0].contains(caseInsensitive: "Location")
        {
            addParseMessage(
                .error(
                    "Error: text file does not appear to contain \(debugSectionName) listing. Columns header is not formatted as expected. Aborting parsing this section."
                )
            )
            return
        }
        
        let lines = section.suffix(from: 1) // remove header row
        
        guard !lines.isEmpty else {
            addParseMessage(
                .error(
                    "Error: text file contains \(debugSectionName) listing but no entries were found."
                )
            )
            return
        }
        
        let estimatedItemCount = lines.count
        
        // init array so we can append to it
        offlineFiles = []
        
        for line in lines {
            if line.isEmpty { break }
            
            let columnData = line.split(separator: "\t")
                .map { String($0) } // split into array by tab character
            
            guard let strFilename = columnData[safe: 0]?.trimmed,
                  let strLocation = columnData[safe: 1]?.trimmed
            else {
                // if these are nil, the text file could be malformed
                addParseMessage(
                    .error(
                        "One or more \(debugSectionName) item elements were nil. Text file may be malformed."
                    )
                )
                break
            }
            
            let newItem = File(
                filename: strFilename,
                path: strLocation,
                online: false
            )
            
            offlineFiles?.append(newItem)
        }
        
        // error check
        
        let actualItemCount = offlineFiles?.count ?? 0
        
        if estimatedItemCount == actualItemCount {
            // addParseMessage("Successfully parsed \(actualItemCount) \(debugSectionName) from text file.")
        } else {
            addParseMessage(
                .error(
                    "Actual parsed \(debugSectionName) item count differs from estimated count. Expected \(estimatedItemCount) items but only successfully parsed \(actualItemCount)."
                )
            )
        }
    }
    
    // MARK: - Clips Listing block (online)
    
    fileprivate mutating func _parseOnlineClips(
        section: [String],
        messages: inout [ParseMessage]
    ) {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        let debugSectionName = "Online Clips"
        addParseMessage(
            .info("Found \(debugSectionName) listing in text file. (\(section.count) lines)")
        )
        
        guard section.count > 1 else {
            addParseMessage(
                .info("Text file contains \(debugSectionName) listing but no files were found.")
            )
            return
        }
        
        if !section[0].contains(caseInsensitive: "CLIP NAME") ||
            !section[0].contains(caseInsensitive: "Source File")
        {
            addParseMessage(
                .error(
                    "Error: text file does not appear to contain \(debugSectionName) listing. Columns header is not formatted as expected. Aborting parsing this section."
                )
            )
            return
        }
        
        let lines = section.suffix(from: 1) // remove header row
        
        guard !lines.isEmpty else {
            addParseMessage(
                .error(
                    "Error: text file contains \(debugSectionName) listing but no entries were found."
                )
            )
            return
        }
        
        let estimatedItemCount = lines.count
        
        // init array so we can append to it
        onlineClips = []
        
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
            
            onlineClips?.append(newItem)
        }
        
        // error check
        
        let actualItemCount = onlineClips?.count ?? 0
        
        if estimatedItemCount == actualItemCount {
            addParseMessage(
                .info("Successfully parsed \(actualItemCount) \(debugSectionName) from text file.")
            )
        } else {
            addParseMessage(
                .error(
                    "Actual parsed \(debugSectionName) count differs from estimated count. Expected \(estimatedItemCount) but only successfully parsed \(actualItemCount)."
                )
            )
        }
    }
    
    // MARK: - Clips Listing block (offline)
    
    fileprivate mutating func _parseOfflineClips(
        section: [String],
        messages: inout [ParseMessage]
    ) {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        let debugSectionName = "Offline Clips"
        addParseMessage(
            .info("Found \(debugSectionName) listing in text file. (\(section.count) lines)")
        )
        
        guard section.count > 1 else {
            addParseMessage(
                .info("Text file contains \(debugSectionName) listing but no files were found.")
            )
            return
        }
        
        if !section[0].contains(caseInsensitive: "CLIP NAME") ||
            !section[0].contains(caseInsensitive: "Source File")
        {
            addParseMessage(
                .error(
                    "Error: text file does not appear to contain \(debugSectionName) listing. Columns header is not formatted as expected. Aborting parsing this section."
                )
            )
            return
        }
        
        let lines = section.suffix(from: 1) // remove header row
        
        guard !lines.isEmpty else {
            addParseMessage(
                .error(
                    "Error: text file contains \(debugSectionName) listing but no entries were found."
                )
            )
            return
        }
        
        let estimatedItemCount = lines.count
        
        // init array so we can append to it
        offlineClips = []
        
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
            
            let channel = columnData[safe: 2]?.trimmed
            
            let newItem = Clip(
                name: name,
                sourceFile: sourceFile,
                channel: channel,
                online: false
            )
            
            offlineClips?.append(newItem)
        }
        
        // error check
        
        let actualItemCount = offlineClips?.count ?? 0
        
        if estimatedItemCount == actualItemCount {
            addParseMessage(
                .info("Successfully parsed \(actualItemCount) \(debugSectionName) from text file.")
            )
        } else {
            addParseMessage(
                .error(
                    "Actual parsed \(debugSectionName) item count differs from estimated count. Expected \(estimatedItemCount) items but only successfully parsed \(actualItemCount)."
                )
            )
        }
    }
    
    // MARK: - Plug-ins Listing block
    
    fileprivate mutating func _parsePlugins(
        section: [String],
        messages: inout [ParseMessage]
    ) {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        let debugSectionName = "Plug-Ins"
        addParseMessage(
            .info("Found \(debugSectionName) listing in text file. (\(section.count) lines)")
        )
        
        guard section.count > 1 else {
            addParseMessage(
                .info("Text file contains \(debugSectionName) listing but no files were found.")
            )
            return
        }
        
        if !section[0].contains(caseInsensitive: "MANUFACTURER") ||
            !section[0].contains(caseInsensitive: "PLUG-IN NAME") ||
            !section[0].contains(caseInsensitive: "VERSION") ||
            !section[0].contains(caseInsensitive: "FORMAT") ||
            !section[0].contains(caseInsensitive: "STEMS") ||
            !section[0].contains(caseInsensitive: "NUMBER OF INSTANCES")
        {
            addParseMessage(
                .error(
                    "Error: text file does not appear to contain \(debugSectionName) listing. Columns header is not formatted as expected. Aborting parsing this section."
                )
            )
            return
        }
        
        let lines = section.suffix(from: 1) // remove header row
        
        guard !lines.isEmpty else {
            addParseMessage(
                .error(
                    "Error: text file contains \(debugSectionName) listing but no entries were found."
                )
            )
            return
        }
        
        let estimatedItemCount = lines.count
        
        // init array so we can append to it
        plugins = []
        
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
                addParseMessage(
                    .error("One or more item elements were nil. Text file may be malformed.")
                )
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
            
            plugins?.append(newItem)
        }
        
        // error check
        
        let actualItemCount = plugins?.count ?? 0
        
        if estimatedItemCount == actualItemCount {
            addParseMessage(
                .info("Successfully parsed \(actualItemCount) \(debugSectionName) from text file.")
            )
        } else {
            addParseMessage(
                .error(
                    "Actual parsed \(debugSectionName) item count differs from estimated count. Expected \(estimatedItemCount) items but only successfully parsed \(actualItemCount)."
                )
            )
        }
        
        // fill in empty manufacturer names
        // PT only lists a manufacturer once if there are multiple plugins in use from that manufacturer
        
        var lastFoundManufacturer = ""
        for idx in (plugins?.startIndex ?? 0) ..< (plugins?.endIndex ?? 0) {
            let itemManufacturer = plugins![idx].manufacturer
            
            if itemManufacturer != "" {
                lastFoundManufacturer = itemManufacturer
            } else {
                plugins![idx].manufacturer = lastFoundManufacturer
            }
        }
    }
    
    // MARK: - Track Listing block
    
    fileprivate mutating func _parseTracks(
        section: [String],
        expectedAudioTrackCount: Int?,
        messages: inout [ParseMessage]
    ) {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        let debugSectionName = "Tracks"
        addParseMessage(.info("Found \(debugSectionName) in text file. (\(section.count) lines)"))
        
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
                addParseMessage(
                    .error(
                        "Error: text file contains a track listing but format is not as expected. Aborting marker parsing."
                    )
                )
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
                addParseMessage(
                    .error(
                        "Parse: \(debugSectionName) listing block: Text does not contain parameter block, or parameter block is not formatted as expected."
                    )
                )
                
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
                    addParseMessage(
                        .error(
                            "Parse: \(debugSectionName) listing for track \"\(track.name)\": Unexpected track STATE value: \"\(str)\". Dev needs to add this to the State enum."
                        )
                    )
                }
            }
            track.state = stateFlags
            
            // PLUG-INS
            track.plugins = getParams[4]
                .components(separatedBy: "\t")                    // split by tab character
                .compactMap { $0.trimmed.isEmpty ? nil : $0 }    // remove empty strings
            
            // clip list
            
            let clipList = getParams[5].trimmingCharacters(in: .newlines)
            
            if !clipList.isEmpty { // skip if no clips are listed
                for clip in clipList.components(separatedBy: .newlines) {
                    var newClip = Track.Clip()
                    
                    let columns = clip.components(separatedBy: "\t").map { $0.trimmed }
                    
                    guard columns.count == 7 else {
                        addParseMessage(
                            .error(
                                "Parse: \(debugSectionName) listing for track \"\(track.name)\": Did not find expected number of tabular columns. Found \(columns.count) columns but expected 7. This clip cannot be parsed: [\(columns.map { $0.quoted }.joined(separator: ", "))]"
                            )
                        )
                        
                        continue
                    }
                    
                    // CHANNEL
                    newClip.channel = Int(columns[0]) ?? 1
                    
                    // EVENT
                    newClip.event = Int(columns[1]) ?? 1
                    
                    // CLIP NAME
                    newClip.name = columns[2]
                    
                    if let frameRate = main.frameRate {
                        // START TIME (assuming text file was exported from Pro Tools with Timecode time type)
                        newClip.startTimecode = ProTools.kTimecode(columns[3], at: frameRate)
                        
                        // END TIME (assuming text file was exported from Pro Tools with Timecode time type)
                        newClip.endTimecode = ProTools.kTimecode(columns[4], at: frameRate)
                        
                        // DURATION (assuming text file was exported from Pro Tools with Timecode time type)
                        newClip.duration = ProTools.kTimecode(columns[5], at: frameRate)
                    }
                    
                    // STATE
                    switch columns[6].trimmed {
                    case "Unmuted": newClip.state = .unmuted
                    case "Muted": newClip.state = .muted
                    default:
                        newClip.state = .unmuted
                        addParseMessage(
                            .error(
                                "Unexpected track listing clip STATE value: \"\(columns[6])\". Defaulting to \"Unmuted\""
                            )
                        )
                    }
                    
                    // add clip to track
                    
                    track.clips.append(newClip)
                }
            }
            
            // add track
            
            if tracks == nil { tracks = [] }
            tracks?.append(track)
        }
        
        let parsedTrackCount = tracks?.count ?? 0
        if let expectedAudioTrackCount = expectedAudioTrackCount {
            if expectedAudioTrackCount == parsedTrackCount {
                addParseMessage(.info("Parsed \(parsedTrackCount) tracks from text file."))
            } else {
                addParseMessage(
                    .error(
                        "Parsed track count differs from expected count. Expected \(expectedAudioTrackCount) items but only successfully parsed \(parsedTrackCount)."
                    )
                )
            }
        } else {
            addParseMessage(
                .error(
                    "Parsed \(parsedTrackCount) tracks from text file. Expected track count was not readable from the file header however so it is not possible to validate if this is the correct number of tracks."
                )
            )
        }
    }
    
    // MARK: - Markers block
    
    // only 'Marker' memory locations (Absolute or Bar|Beat) get exported to the text file
    // 'Selection' memory locations and window-recalls are not listed in the text file
    
    fileprivate mutating func _parseMarkers(
        section: [String],
        messages: inout [ParseMessage]
    ) {
        func addParseMessage(_ msg: ParseMessage) {
            messages.append(msg)
        }
        
        let debugSectionName = "Markers"
        addParseMessage(.info("Found \(debugSectionName) in text file. (\(section.count) lines)"))
        
        // basic validation
        
        guard section.count > 1 else {
            addParseMessage(
                .info("Text file contains \(debugSectionName) listing but no markers were found.")
            )
            return
        }
        
        if !section[0].contains(caseInsensitive: "LOCATION") ||
            !section[0].contains(caseInsensitive: "TIME REFERENCE") ||
            !section[0].contains(caseInsensitive: "UNITS") ||
            !section[0].contains(caseInsensitive: "NAME") ||
            !section[0].contains(caseInsensitive: "COMMENTS")
        {
            addParseMessage(
                .error(
                    "Error: text file does not appear to contain \(debugSectionName) listing. Columns header is not formatted as expected. Aborting parsing this section."
                )
            )
            return
        }
        
        let lines = section.suffix(from: 1) // remove header row
        
        guard !lines.isEmpty else {
            addParseMessage(
                .error(
                    "Error: text file contains \(debugSectionName) listing but no entries were found."
                )
            )
            return
        }
        
        let estimatedItemCount = lines.count
        
        // init array so we can append to it
        markers = []
        
        for line in lines {
            if line.isEmpty { break }
            
            let columnData = line.split(separator: "\t")
                .map { String($0) } // split into array by tab character
            
            #warning(
                "> TODO: may need to add logic to detect what format the 'Location' value is in - whether it's frames (timecode), samples, etc."
            )
            
            guard let strTimecode = columnData[safe: 1]?.trimmed,
                  let strTimeReference = columnData[safe: 2]?.trimmed,
                  let strUnits = columnData[safe: 3]?.trimmed,
                  let strName = columnData[safe: 4]?.trimmed
            else {
                // if these are nil, the text file could be malformed
                addParseMessage(
                    .error(
                        "One or more \(debugSectionName) item elements were nil. Text file may be malformed."
                    )
                )
                break
            }
            
            let strNumber = columnData[safe: 0]?.trimmed
            let strComment = columnData[safe: 5]?.trimmed
            
            let number: Int? = strNumber?.int
            
            let units: Marker.Units
            switch strUnits {
            case "Samples": units = .samples
            case "Ticks": units = .ticks
            default:
                units = .samples
                addParseMessage(
                    .error(
                        "A marker had a Units type that was not recognized : \(strUnits.quoted). Defaulting to Samples."
                    )
                )
            }
            
            var newItem = Marker(
                number: number,
                timeReference: strTimeReference,
                units: units,
                name: strName,
                comment: strComment
            )
            
            if let mainFrameRate = main.frameRate,
               !newItem.validate(timecodeString: strTimecode, at: mainFrameRate)
            {
                // populate timecode object and verify
                addParseMessage(
                    .error(
                        "FYI: Validation for timecode \(strTimecode) at text file frame rate of \(mainFrameRate) failed."
                    )
                )
            }
            
            markers?.append(newItem)
        }
        
        // error check
        
        let actualItemCount = markers?.count ?? 0
        
        if estimatedItemCount == actualItemCount {
            addParseMessage(
                .info("Successfully parsed \(actualItemCount) \(debugSectionName) from text file.")
            )
        } else {
            addParseMessage(
                .error(
                    "Actual parsed \(debugSectionName) count differs from estimated count. Expected \(estimatedItemCount) but only successfully parsed \(actualItemCount)."
                )
            )
        }
    }
}
