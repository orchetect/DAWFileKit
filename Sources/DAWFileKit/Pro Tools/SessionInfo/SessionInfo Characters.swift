//
//  SessionInfo Characters.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

// MARK: Fix extended characters (Pro Tools ASCII issues)

private let fixPTExtendedCharacters_Chars = [
    "É": "...",
    "Ñ": "--"
]

// TODO: this is experimental and in progress

// extension ProTools.SessionInfo {
//
//  /// Workaround for extended unicode characters used in Pro Tools markers or marker comments that get converted to random ASCII characters when exporting session info as a text file.
//  public static func fixPTExtendedCharacters(_ string: String) -> NSAttributedString {
//      let text = NSMutableAttributedString(string: string)
//
//      for findChar in fixPTExtendedCharacters_Chars {
//          // (This is the best way to do this, since we can't access .replacingOccurances(...) on an attributed string)
//
//          // Get range of text to replace
//          guard let range = text.string.range(of: findChar.key) else { continue }
//          let nsRange = NSRange(range, in: text.string)
//
//          // Replace content in range with the new content
//          text.replaceCharacters(in: nsRange, with: findChar.value)   // mutates class
//      }
//
//      return text
//  }
//
// }
