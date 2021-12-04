//
//  Log.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

@_implementationOnly import OTCore

let logger = OSLogger {
    $0.defaultTemplate = .withEmoji()
}
