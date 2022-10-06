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
