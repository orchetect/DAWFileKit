//
//  SRTFile.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

/// SRT Text (SubRip Subtitles) file.
///
/// A SRT file contains a sequential list of subtitles, each with a timestamp indicating when it should appear and
/// disappear on the screen.
///
/// SRT files are widely supported by media players and video software, making them a popular choice for adding captions
/// to videos.
///
/// The file is, at its basic form, a human-readable text file with a repeating text structure format for each subtitle,
/// and each subtitle block is separated by a blank line.
/// The subtitle block begins with a sequence number on the first line, a timestamp range (in and out) on the second
/// line, and the text content string on the third line.
///
/// The timestamp format is `HH:MM:SS:mls` where `mls` is milliseconds (1/1000th fractions of a second).
///
/// The time units are fixed to two zero-padded digits and fractions fixed to three zero-padded digits.
///
/// Example:
///
/// ```
/// 1
/// 00:00:05,217 --> 00:00:10,854
/// This is the first subtitle.
///
/// 2
/// 00:00:12,072 --> 00:00:15,647
/// This is the second subtitle.
///
/// 3
/// 00:00:18,210 --> 00:00:22,341
/// This is the third subtitle.
/// ```
///
/// ## Markup
///
/// Unofficially the format has very basic text formatting, which can be either interpreted or passed through for
/// rendering depending on the processing application. Formatting is derived from HTML tags for bold, italic, underline
/// and color:
///
/// - Bold – `<b> ... </b>`
/// - Italic – `<i> ... </i>`
/// - Underline – `<u> ... </u>`
/// - Font color – `<font color="color name or #code"> ... </font>`
/// - Nested tags are allowed; some implementations prefer whole-line formatting only.
///
/// Also unofficially, text coordinates can be specified at the end of the timestamp line as `X1:… X2:… Y1:… Y2:…`.
///
/// See [SubRip on Wikipedia](https://en.wikipedia.org/wiki/SubRip)
///
/// ## Encoding
///
/// SubRip's default output encoding is configured as Windows-1252. However, output options are also given for many
/// Windows code pages as well as Unicode encodings, such as UTF-8 and UTF-16, with or without byte order mark (BOM).
/// Therefore, there is no official character encoding standard for `.srt` files, which means that any SubRip file
/// parser must attempt to use charset detection. Unicode BOMs are typically used to aid detection.
///
/// YouTube only supports UTF-8. The default encoding for subtitle files in FFmpeg is UTF-8. All text in a
/// Matroska file is encoded in UTF-8.
public struct SRTFile {
    /// File text encoding.
    ///
    /// SubRip's default output encoding is configured as Windows-1252. However, output options are also given for many
    /// Windows code pages as well as Unicode encodings, such as UTF-8 and UTF-16, with or without byte order mark
    /// (BOM). Therefore, there is no official character encoding standard for `.srt` files.
    ///
    /// YouTube only supports UTF-8. The default encoding for subtitle files in FFmpeg is UTF-8. All text in a
    /// Matroska file is encoded in UTF-8.
    public var encoding: String.Encoding
    
    /// Subtitles (captions) contained in the SRT file.
    public var subtitles: [Subtitle]
    
    public init(encoding: String.Encoding = .windowsCP1252, subtitles: [Subtitle]) {
        self.encoding = encoding
        self.subtitles = subtitles
    }
}

extension SRTFile: Equatable { }

extension SRTFile: Hashable { }

extension SRTFile: Sendable { }

// MARK: - Raw Data

extension SRTFile {
    /// Initialize by loading the contents of a file on disk.
    public init(url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(fileContent: data)
    }
    
    /// Initialize by loading raw file contents.
    public init(fileContent data: Data) throws {
        // must use charset detection since there is no standard text encoding for SRT files.
        var usedLossyConversion: ObjCBool = false // TODO: not used
        var nsString: NSString?
        guard case let rawValue = NSString.stringEncoding(
            for: data,
            encodingOptions: nil /*[
                .suggestedEncodingsKey: [
                    NSUTF8StringEncoding,
                    NSUTF16StringEncoding,
                    NSUTF32StringEncoding,
                    NSUnicodeStringEncoding,
                    NSWindowsCP1252StringEncoding
                ],
                .useOnlySuggestedEncodingsKey: true as NSNumber
            ]*/,
            convertedString: &nsString,
            usedLossyConversion: &usedLossyConversion
        ),
            rawValue != 0,
            let rawText = nsString as? String
        else {
            throw DecodeError.unrecognizedTextEncoding
        }
        let encoding = String.Encoding(rawValue: rawValue)
        
        try self.init(fileContent: rawText, encoding: encoding)
    }
    
    /// Initialize by loading raw file contents.
    public init(fileContent: String, encoding: String.Encoding = .windowsCP1252) throws {
        self.encoding = encoding
        
        let blocks = fileContent
            .trimmingCharacters(in: .newlines)
            .replacingOccurrences(of: "\r\n", with: "\n") // TODO: hacky line-endings conversion
            .components(separatedBy: "\n\n")
            .filter { !$0.isEmpty }
        
        // parse subtitles into a dictionary keyed by sequence number
        let subtitlesDict: [Int: Subtitle] = try blocks
            .mapDictionary { element in
                let (sequenceNumber, subtitle) = try Subtitle.parse(string: element)
                return (key: sequenceNumber, value: subtitle)
            }
        
        // sort by sequence number
        subtitles = subtitlesDict
            .sorted(by: { $0.key < $1.key })
            .map(\.value)
            
    }
    
    /// Returns the raw SRT file contents.
    public func rawString() throws -> String {
        guard !subtitles.isEmpty,
              let lastIndex = subtitles.indices.last
        else { return "" }
        
        var output = ""
        
        for (index, subtitle) in self.subtitles.enumerated() {
            let sequenceNumber = index + 1
            let subtitleBlockString = subtitle.rawData(sequenceNumber: sequenceNumber)
            output.append(subtitleBlockString)
            
            if index < lastIndex {
                output.append("\n\n")
            }
        }
        
        return output
    }
    
    /// Returns the raw SRT file contents using the encoding as set in the ``encoding`` property.
    public func rawData() throws -> Data {
        let output = try rawString()
        
        // encode string
        guard let data = output.toData(using: encoding) else {
            throw EncodeError.encodeError
        }
        
        return data
    }
}
