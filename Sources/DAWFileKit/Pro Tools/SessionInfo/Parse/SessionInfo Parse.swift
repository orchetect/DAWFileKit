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
    ///
    /// - Parameters:
    ///   - fileContent: Raw text file content.
    ///   - timeValueFormat: If the time format is known, supply it. Otherwise pass `nil` to automatically detect the format.
    /// - Returns: Parsed session info.
    internal static func parse(
        fileContent: String,
        timeValueFormat knownTimeFormat: TimeValueFormat? = nil
    ) throws -> (
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
        
        let parsedMain = ParsedHeader(lines: getHeader)
        info.main = parsedMain.main
        messages.append(contentsOf: parsedMain.messages)
        
        // MARK: - Parse into major sections
        
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
        
        let timeValueFormat: TimeValueFormat
        if let knownTimeFormat = knownTimeFormat {
            // use user-supplied time format
            timeValueFormat = knownTimeFormat
        } else if let detectedFormat = detectTimeFormat(
            from: &sections,
            mainFrameRate: info.main.frameRate
        ) {
            // employ a heuristic to determine the main time format
            // selected while exporting the text file from Pro tools
            timeValueFormat = detectedFormat.format
            
            if detectedFormat.hasMixedFormats {
                addParseMessage(.error(
                    "More than one primary time value format was detected from examining the file contents. This means either 1) the file is malformed, 2) there is a bug in the parser, or 3) a new time format previously unknown is being used by Pro Tools and the parser needs updating to add support for it. Using \(detectedFormat.format)."
                ))
            }
        } else {
            timeValueFormat = .timecode
            addParseMessage(.error(
                "Primary time value format could not be determined from examining the file contents. Defaulting to Timecode."
            ))
        }
        
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
}
